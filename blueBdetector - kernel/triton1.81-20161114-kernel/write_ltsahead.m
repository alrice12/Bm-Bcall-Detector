function write_ltsahead
%
% setup values for ltsa file and write header + directories for new ltsa
% file
%
% 060509 smw
% 060914 smw modified for wav files
%
global PARAMS

disp('set up ltsa file')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get file name
%
filterSpec1 = '*.ltsa';
boxTitle1 = 'Save LTSA File';
% user interface retrieve file to open through a dialog box
PARAMS.ltsa.outdir = PARAMS.ltsa.indir;
PARAMS.ltsa.outfile = 'LTSAout.ltsa';
DefaultName = [PARAMS.ltsa.outdir,'\',PARAMS.ltsa.outfile];
[PARAMS.ltsa.outfile,PARAMS.ltsa.outdir]=uiputfile(filterSpec1,boxTitle1,DefaultName);
% outfile = [PARAMS.ltsa.outdir,'\',PARAMS.ltsa.outfile];
% if the cancel button is pushed, then no file is loaded
% so exit this script
if strcmp(num2str(PARAMS.ltsa.outfile),'0')
    PARAMS.ltsa.gen = 0;
    disp_msg('Canceled file creation')
    return
else
    PARAMS.ltsa.gen = 1;
    disp_msg('Opened File: ')
    disp_msg([PARAMS.ltsa.outdir,PARAMS.ltsa.outfile])
    %     disp(' ')
    cd(PARAMS.ltsa.outdir)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate file header values, open file and fill up header
%
% maxNrawfiles = 4999;                            % maximum number of raw files
maxNrawfiles = PARAMS.ltsa.nrftot + 100;          % maximum number of raw files + a few more

dirStartLoc = 65;                               % directory start location in bytes
dataStartLoc = 64 * (maxNrawfiles + 1);           % data start location in bytes (64 * 5000 = 320000)
% + 1 for LTSA header

% open output ltsa file
fid = fopen([PARAMS.ltsa.outdir,PARAMS.ltsa.outfile],'w');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% LTSA file Header - 64 bytes total
%
%
fwrite(fid,'LTSA','char');                  % 4 bytes - file ID type
% version 2 -> channel number ltsa'ed added
% version 3 -> ARP xwavs (from bin files) have a nave > 2^16
% if PARAMS.ltsa.dtype == 2       % dtype == 2 for ARP data
%     fwrite(fid,3,'uint8');                      % 1 byte - version number
% else
%     fwrite(fid,2,'uint8');                      % 1 byte - version number
% end
fwrite(fid,PARAMS.ltsa.ver,'uint8');                      % 1 byte - version number
fwrite(fid,'xxx','char');                   % 3 bytes - spare
fwrite(fid,dirStartLoc,'uint32');           % 4 bytes - directory start location [bytes]
fwrite(fid,dataStartLoc,'uint32');          % 4 bytes - data start location [bytes]
fwrite(fid,PARAMS.ltsa.tave,'float32');     % 4 bytes - time bin average for spectra [seconds]
fwrite(fid,PARAMS.ltsa.dfreq,'float32');    % 4 bytes - frequency bin size [Hz]
fwrite(fid,PARAMS.ltsa.fs,'uint32');        % 4 bytes - sample rate [Hz]
fwrite(fid,PARAMS.ltsa.nfft,'uint32');      % 4 bytes - number of samples per fft

if PARAMS.ltsa.ver == 1 || PARAMS.ltsa.ver == 2
    fwrite(fid,PARAMS.ltsa.nrftot,'uint16');    % 2 bytes - total number of raw files from all xwavs
    nz = 27;        % number of zeros to pad
elseif PARAMS.ltsa.ver == 3
    fwrite(fid,PARAMS.ltsa.nrftot,'uint32');    % 2 bytes - total number of raw files from all xwavs
    nz = 25;
else
    disp_msg(['Error: incorrect version number ',num2str(PARAMS.ltsa.ver)])
    return
end

fwrite(fid,PARAMS.ltsa.nxwav,'uint16');     % 2 bytes - total number of xwavs files used
% 36 bytes used, up to here
% add channel ltsa'ed 061011 smw
fwrite(fid,PARAMS.ltsa.ch,'uint8');         % 1 byte - channel number that was ltsa'ed
% pad header for future growth, but backward compatible
% fwrite(fid,zeros(27,1),'uint8');                  % 1 bytes x 27 = 27 bytes - 0 padding / spare
fwrite(fid,zeros(nz,1),'uint8');                  % 1 bytes x 27 = 27 bytes - 0 padding / spare
% 64 bytes used - up to here

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Directory - one for each raw file - 64 bytes for each directory listing
%
%
for k = 1 : PARAMS.ltsa.nrftot
    % write time values to directory
    fwrite(fid,PARAMS.ltsahd.year(k) ,'uchar');          % 1 byte - Year
    fwrite(fid,PARAMS.ltsahd.month(k) ,'uchar');         % 1 byte - Month
    fwrite(fid,PARAMS.ltsahd.day(k) ,'uchar');           % 1 byte - Day
    fwrite(fid,PARAMS.ltsahd.hour(k) ,'uchar');          % 1 byte - Hour
    fwrite(fid,PARAMS.ltsahd.minute(k) ,'uchar');        % 1 byte - Minute
    fwrite(fid,PARAMS.ltsahd.secs(k) ,'uchar');          % 1 byte - Seconds
    fwrite(fid,PARAMS.ltsahd.ticks(k) ,'uint16');        % 2 byte - Milliseconds
    % 8 bytes up to here
    %
    % calculate number of spectral averages for this raw file
    %
    % number of samples in this raw file = # sectors in rawfile * # samples/sector:
    %
    %     Nsamp = PARAMS.ltsahd.write_length(k) * 250;
    if PARAMS.ltsa.ftype ~= 1   % for HARP and ARP data
        %         Nsamp = PARAMS.ltsahd.write_length(k) * PARAMS.ltsa.blksz;
        Nsamp = (PARAMS.ltsahd.write_length(k) * PARAMS.ltsa.blksz) / PARAMS.ltsa.nch;
    else        % for wav/Ishmael type data
        Nsamp = PARAMS.ltsahd.nsamp(k);
    end
    %
    % number of spectral averages = # samples in rawfile / # samples in fft * compression factor
    % needs to be an integer
    %
    PARAMS.ltsa.nave(k) = ceil(Nsamp/(PARAMS.ltsa.nfft * PARAMS.ltsa.cfact));
    %
    % calculate byte location in ltsa file for 1st spectral
    % average of this raw file
    if k == 1
        ltsaByteLoc = dataStartLoc;
    else
        % ltsa data byte loc = previous loc + # spectral ave (of previous loc) * # freqs in each spectra * # of bytes per spectrum level value
        ltsaByteLoc = ltsaByteLoc +  PARAMS.ltsa.nave(k-1) * PARAMS.ltsa.nfreq * 1;
    end
    PARAMS.ltsa.byteloc(k) = ltsaByteLoc;
    %
    % write ltsa parameters:
    %
    fwrite(fid,PARAMS.ltsa.byteloc(k) ,'uint32');     % 4 byte - Byte location in ltsa file of the spectral averages for this rawfile
    %     if PARAMS.ltsa.dtype == 2       % dtype == 2 for ARP data, need nave larger than 2^16
    %         fwrite(fid,PARAMS.ltsa.nave(k) ,'uint32');          % 2 byte - number of spectral averages for this raw file
    %     else
    %         fwrite(fid,PARAMS.ltsa.nave(k) ,'uint16');          % 2 byte - number of spectral averages for this raw file
    %     end
    if PARAMS.ltsa.ver == 1 || PARAMS.ltsa.ver == 2       % dtype == 2 for ARP data, need nave larger than 2^16
        fwrite(fid,PARAMS.ltsa.nave(k) ,'uint16');          % 2 byte - number of spectral averages for this raw file
        nz = 9;
    elseif PARAMS.ltsa.ver == 3
        fwrite(fid,PARAMS.ltsa.nave(k) ,'uint32');          % 2 byte - number of spectral averages for this raw file
        nz = 7;
    else
        disp_msg(['Error: incorrect version number ',num2str(PARAMS.ltsa.ver)])
        return
    end
    % 14 (or 16) bytes up to here
    fwrite(fid,PARAMS.ltsahd.fname(k,:),'uchar');        % 40 byte - xwav file name for this raw file header
    fwrite(fid,PARAMS.ltsahd.rfileid(k),'uint8');       % 1 byte - raw file id / number for this xwav
    % 55 or 57 bytes up to here
    %     if PARAMS.ltsa.dtype == 2       % dtype == 2 for ARP data, need nave larger than 2^16
    %         fwrite(fid,zeros(7,1),'uint8');                    % 9 bytes zero padding / spare
    %     else
    %         fwrite(fid,zeros(9,1),'uint8');                    % 9 bytes zero padding / spare
    %     end
    fwrite(fid,zeros(nz,1),'uint8');
    % 64 bytes for each directory listing for each raw file
end

%
% fill up rest of header with zeros before data start
dndir = maxNrawfiles - PARAMS.ltsa.nrftot;              % number of directories not used - to be filled with zeros
dfill = zeros(64 * dndir,1);
fwrite(fid,dfill,'uint8');
% (64 * 5000 = 320000) bytes up to here

% close file
fclose(fid);
