function hrp2xwav() %(~) %replace () for matlab 2010
% hrp2xwav.m
%
% 100827 smw
% clean up the code a bit, properly deal with sync loss (wrong length in
% Block Tag)
%
% loop over sectors (not Sections) for 2.02 Q and R
%
% hrp2xwav has a long history in triton
% it takes ftp or usb raw HARP file and converts into XWAV file
% need to input sample rate since not contained in raw file
%
% 110502 bjt moved decompression block to decompressRawHRP, and added
% function call
%
global PARAMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dbflag = 0;     % debug display flag
dflag = 1;  % display flag

fs = 200000;	% sample rate
ftype = 2;
nch = 1;                % number of channels
dtype = 1;

% user input dialog box
prompt={'Enter sampling frequency (Hz) : ',...
    'Enter file type (1 = USB/*.hrp, 2 = FTP) : ',...
    'Enter Number of Channels : (1 or 4) ',...
    'Enter data type (1 = standard, 2 = Q:compressed, 3 = R:compressed) : '};
def={num2str(fs),...
    num2str(ftype),...
    num2str(nch),...
    num2str(dtype)};
dlgTitle='Set Conversion Parameters';
lineNo=1;
AddOpts.Resize='on';
AddOpts.WindowStyle='normal';
AddOpts.Interpreter='tex';
in=inputdlg(prompt,dlgTitle,lineNo,def,AddOpts);
if isempty(in)	% if cancel button pushed
    return
end
%
fs = str2num(deal(in{1}));
%
ftype = str2num(deal(in{2}));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nch = str2num(deal(in{3}));
if nch ~= fix(nch)
    disp_msg('Error - need integer number of channels (eg. 1 or 4)')
    return
else
    disp_msg('Number of Channels for XWAV file :')
    disp_msg(num2str(nch))
end
dtype = str2num(deal(in{4}));
if dtype ~= 1 && dtype ~= 2 && dtype ~= 3
    disp_msg('Error - data type should be 1, 2 or 3')
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% open file stuff
inpath = PARAMS.inpath;             % some place to start
cd(inpath);                         % go there

if ftype == 1
    filterSpec1 = '*.hrp';
elseif ftype == 2
    filterSpec1 = '*.*';
end
% filterSpec1 = {'*.hrp';'*.*'};

% user interface retrieve file to open through a dialog box
boxTitle1 = 'Open Raw HARP file to convert to XWAV format';
[infile,inpath]=uigetfile(filterSpec1,boxTitle1);

disp_msg('Opened File: ')
disp_msg([inpath,infile])

% if the cancel button is pushed, then no file is loaded
% so exit this script
if infile == 0
    disp_msg('Cancel Open File')
    return
end

if ftype == 1
    fid = fopen([inpath,infile],'r','l'); %for usb file
elseif ftype == 2
    fid = fopen([inpath,infile],'r','b'); %for ftp file
end

if fid == -1
    disp_msg('Error: no such file')
    return
end

outfile = [infile,'.x.wav'];
outpath = inpath;
cd(outpath);            % go there

boxTitle2 = 'Save XWAV file';
[outfile,outpath] = uiputfile(outfile,boxTitle2);

if outfile == 0
    disp_msg('Cancel Save XWAV File')
    return
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate how many bytes -> not checking data file if correct
filesize = getfield(dir([inpath,infile]),'bytes');

% HARP data structure
byteblk = 512;	                    % bytes per head+data+null block
headblk = 12;		                    % bytes per head block
if nch == 1;
    tailblk = 0;
elseif nch == 4
    tailblk = 4;                % bytes after data and before next header
end

datablk = byteblk - headblk - tailblk;  % bytes per data block
bytesamp = 2;	                        % bytes per sample
datasamp = datablk/bytesamp;	        % number of samples per data block

% number of data blocks in input file
blkmx = floor(filesize/byteblk);    % calculate the number of sectors in the opened file
disp_msg(['Total Number of Sectors in ',infile,' : ']);
disp_msg(blkmx);
%disp('for testing purposes, make blkmx smaller')
%blkmx = 60000

% defaults
srfactor = 1;                              % sample rate factor
nfiles = 1;                                 % number of XWAV files to make
display_count = 1000;           % some feedback for the user while waiting....
gain = 1;                      % make XWAV file louder so easier to hear on

% the following was for MAWSON ARP data and outreach program
% this would allow speed up and slow down and increase in gain
% so that the file would play differently in wav reading program
% but correctly in Triton
% we haven't used it in a long time to turn off 100827 smw
if 0
    %
    % user input dialog box for XWAV file size in data blocks
    prompt={'Enter number of Sectors to read from raw file ',...
        'Enter XWAV file sample rate change factor' ,...
        'Enter number of XWAV file to generate 0 < nfile < 27 ',...
        'Enter Gain for XWAV file (0 < gain < 50)'};
    def={num2str(blkmx),...
        num2str(srfactor),...
        num2str(nfiles),...
        num2str(gain)};
    dlgTitle='Set XWAV: file size, fake sample rate factor, # of files';
    lineNo=1;
    AddOpts.Resize='on';
    AddOpts.WindowStyle='normal';
    AddOpts.Interpreter='tex';
    in=inputdlg(prompt,dlgTitle,lineNo,def,AddOpts);
    if length(in) == 0	% if cancel button pushed
        return
    else
        blkmx = str2num(deal(in{1}));
        if blkmx ~= fix(blkmx)
            disp_msg('Error - need integer number of Sectors')
            return
        else
            disp_msg('Number of Sectors used for XWAV file :')
            disp_msg(num2str(blkmx))
        end
        %%%%%%%%%%%%%%%%%%%%%%
        srfactor = str2num(deal(in{2}));
        disp_msg('Sample rate change factor for XWAV file :')
        disp_msg(num2str(srfactor))
        %%%%%%%%%%%%%%%%%%%%%%
        nfiles = str2num(deal(in{3}));
        if nfiles > 26 || nfiles < 1
            disp_msg('Error - too many or too few files to be generated')
            return
        else
            disp_msg('Number of XWAV files to generate :')
            disp_msg(num2str(nfiles))
        end
        %%%%%%%%%%%%%%%%%%%%%%%
        gain = str2num(deal(in{4}));
        if gain <= 0 || gain >= 50
            disp_msg('Error - too big or two small (0 < gain < 50')
            return
        end
    end
    
end

% wav file header parameters

% RIFF Header stuff:
%  harpsize = blkmx / byteblk * 32 + 64 - 8;% length of the harp chunk
harpsize = 1 * 32 + 64 - 8;% length of the harp chunk
wavsize = (datablk*blkmx)+36+harpsize+8;  % required for the RIFF header

% Format Chunk stuff:
fsize = 16;  % format chunk size
fcode = 1;   % compression code (PCM = 1)
% ch = 1;      % number of channels
bitps = 16;	% bits per sample

% Harp Chunk stuff:
%  harpsize = blkmx / 60000 * 32 + 64 - 8;% length of the harp chunk
harpwavversion = 0;            % harp wav header version number
if nch == 1
    harpfirmware = '1.07b     ';   % arp firmware version number, 10 chars
    if dtype == 2
        harpfirmware = '2.02Q     ';
    elseif dtype == 3
        harpfirmware = '2.02R     ';
    end
elseif nch == 4
    harpfirmware = '2.10      ';   % arp firmware version number, 10 chars
else
    disp_msg('Error - only 1 or 4 channels for HARP data')
    return
end
harpinstrument = '41  ';       % harp instrument number - 4 char
sitename = '2004';             % site name - 4 char
experimentname = 'HARP    ';   % experiment name - 8 char
diskseqnumber = 1;             % disk sequence number
diskserialnumber = '00000000'; % disk serial number - 8 char
%   numofwrites = blkmx / 60000;   % number of writes
numofwrites = 1;
longitude = 17900000;         % longitude
latitude = 8900000;          % latitude
depth = 6000;                   % depth

% HARP Write Header info (one listing per write)
byteloc = 8+4+8+16+64+32+8;

% number of data blocks in output file
%writelength = 60000;             % number of blocks per write
writelength = blkmx;            % use total number of Sectors since only one 'write' for Mawson data
bytelength = writelength * datablk;    % number of blocks of data per write

% loop over the number of file to make
for ii=1:nfiles                    % make N files
    if ftype == 1
        dvec(2) = fread(fid,1,'uint8');
        dvec(1) = fread(fid,1,'uint8');
        dvec(4) = fread(fid,1,'uint8');
        dvec(3) = fread(fid,1,'uint8');
        dvec(6) = fread(fid,1,'uint8');
        dvec(5) = fread(fid,1,'uint8');
        ticks = fread(fid,1,'uint16');
        %   msec = msec/4;      % quick fix for wrong header time
        fseek(fid,-8,0);            % rewind to start of header
    elseif ftype == 2
        dvec(1) = fread(fid,1,'uint8');
        dvec(2) = fread(fid,1,'uint8');
        dvec(3) = fread(fid,1,'uint8');
        dvec(4) = fread(fid,1,'uint8');
        dvec(5) = fread(fid,1,'uint8');
        dvec(6) = fread(fid,1,'uint8');
        ticks = fread(fid,1,'uint16');
        % msec = msec/4;      % quick fix for wrong header time
        fseek(fid,-8,0);
    end
    
    sample_rate = fs; % true sample rate
    disp_msg('true sample rate is : ')
    disp_msg(num2str(sample_rate))
    
    fs = sample_rate * srfactor;                % fake sampling rate
    %     bps	=	fs*ch*bytesamp;	                    % bytes per second for xwav header
    bps	=	fs*nch*bytesamp;	                    % bytes per second for xwav header
    disp_msg('fake sample rate is : ')
    disp_msg(num2str(fs))
    
    % open output file
    %     outfile = [outfile(1:length(outfile)-7),char(64+ii),'.x.wav'
    outfile = [outfile(1:length(outfile)-6),char(64+ii),'.x.wav'];
    fod = fopen([outpath,outfile],'w');
    
    % make global for calling programs
    PARAMS.outfile = outfile;
    PARAMS.outpath = outpath;
    
    % write xwav file header
    %
    % RIFF file header
    fprintf(fod,'%c','R');
    fprintf(fod,'%c','I');
    fprintf(fod,'%c','F');
    fprintf(fod,'%c','F');
    fwrite(fod,wavsize,'uint32');
    fprintf(fod,'%c','W');
    fprintf(fod,'%c','A');
    fprintf(fod,'%c','V');
    fprintf(fod,'%c','E');
    
    %
    % Format information
    fprintf(fod,'%c','f');
    fprintf(fod,'%c','m');
    fprintf(fod,'%c','t');
    fprintf(fod,'%c',' ');
    fwrite(fod,fsize,'uint32');
    fwrite(fod,fcode,'uint16');
    %     fwrite(fod,ch,'uint16');
    fwrite(fod,nch,'uint16');
    fwrite(fod,fs,'uint32');
    fwrite(fod,bps,'uint32');
    fwrite(fod,bytesamp,'uint16');
    fwrite(fod,bitps,'uint16');
    
    %
    % "harp" chunk
    fprintf(fod,'%c', 'h');
    fprintf(fod,'%c', 'a');
    fprintf(fod,'%c', 'r');
    fprintf(fod,'%c', 'p');
    fwrite(fod, harpsize, 'uint32');
    fwrite(fod, harpwavversion, 'uchar');
    fwrite(fod, harpfirmware, 'uchar');
    fprintf(fod, harpinstrument, 'uchar');
    fprintf(fod, sitename, 'uchar');
    fprintf(fod, experimentname, 'uchar');
    fwrite(fod, diskseqnumber, 'uchar');
    fprintf(fod, '%s', diskserialnumber);
    fwrite(fod, numofwrites, 'uint16');
    fwrite(fod, longitude, 'int32');
    fwrite(fod, latitude, 'int32');
    fwrite(fod, depth, 'int16');
    fwrite(fod, 0, 'uchar');   % padding
    fwrite(fod, 0, 'uchar');
    fwrite(fod, 0, 'uchar');
    fwrite(fod, 0, 'uchar');
    fwrite(fod, 0, 'uchar');
    fwrite(fod, 0, 'uchar');
    fwrite(fod, 0, 'uchar');
    fwrite(fod, 0, 'uchar');
    
    % "harp" write entries
    % entry 1
    fwrite(fod, dvec(1), 'uchar');
    fwrite(fod, dvec(2), 'uchar');
    fwrite(fod, dvec(3), 'uchar');
    fwrite(fod, dvec(4), 'uchar');
    fwrite(fod, dvec(5), 'uchar');
    fwrite(fod, dvec(6), 'uchar');
    fwrite(fod, ticks, 'uint16');
    fwrite(fod, byteloc, 'uint32');
    fwrite(fod, bytelength, 'uint32');
    fwrite(fod, writelength, 'uint32');
    fwrite(fod, sample_rate, 'uint32');
    fwrite(fod, gain , 'uint8');
    fwrite(fod, 0, 'uchar'); % padding
    fwrite(fod, 0, 'uchar');
    fwrite(fod, 0, 'uchar');
    fwrite(fod, 0, 'uchar');
    fwrite(fod, 0, 'uchar');
    fwrite(fod, 0, 'uchar');
    fwrite(fod, 0, 'uchar');
    
    % Data area -- variable length
    fprintf(fod,'%c','d');
    fprintf(fod,'%c','a');
    fprintf(fod,'%c','t');
    fprintf(fod,'%c','a');
    fwrite(fod,datablk*blkmx,'uint32');
    
    % standard data type, no compression, 1 or 4 channels
    if dtype == 1
        % read data blocks (Sectors) from ARP file and write to XWAV file
        count = 1;
        disp_msg('reading/writing : ')
        for i= 1:blkmx
            fseek(fid,headblk,0);	                            % skip over header
            
            if nch == 4
                fwrite(fod,gain * fread(fid,datablk/bytesamp,'uint16')-32767,'int16'); % read and write(4-channel)
            else
                fwrite(fod,gain * fread(fid,datablk/bytesamp,'int16'),'int16'); % read and write (1-channel)
            end
            
            if count == display_count
                disp_msg(['data block ',num2str(i)])    % give the user some feed back during this long process
                count = 0;
            end
            count = count + 1;
            fseek(fid,tailblk,0);
        end
        
        fclose(fod);
        disp_msg(['done with ',outpath,outfile])
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        % the following is for compressed data type
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    elseif dtype == 2 || dtype == 3
        h = 1;  % ie only one raw file
        nhrp = 1;
        bpsect = 512;       % bytes per sect
        if PARAMS.nch == 1
            datasamp = 250; % number of samples per data block
            tailblk = 0;
        elseif PARAMS.nch == 4
            datasamp = 248;   % number of samples per data block
            tailblk = 4;    % skip the last two 'samples' ie 4 bytes
        end
        nbytesPerSect = datasamp * 2;
        
        raw1head_byteloc = (8+4) + (8+16) + 64;     % start of 1st raw file header
        raw1data_byteloc = raw1head_byteloc + (32 * nhrp) + 8;  % start of 1st raw file data
 
         saveByteLoc1 = ftell(fod);        
        
        fwrite(fod,decompressRawHRP(fid,1,dtype,'ftype',ftype,'usb_ftp_flag',1,'filesize',filesize,'dvec',dvec,'ticks',ticks),'int16');  
        
        % finish off some file bookkeeping
        
        % output block count
        if dflag
            %             disp(['Number of blocks in this Raw File : ',num2str(nBlksPerRawFile)])
        end
        
        % need to modify XWAV header to correct sector values/indexing for each
        % raw file
        saveByteLoc2 = ftell(fod);      % current byte location in output XWAV file
        byte_length(h) = saveByteLoc2 - saveByteLoc1;       % number of bytes in raw file
        
        % error if total disk write is larger than 30e6 bytes (ie 60000 sectors)
        wmax = 30e6;
        if byte_length(h) > wmax
            disp(['Triton Error : ',num2str(byte_length(h)),' > 30e6 bytes in this Disk Write / Raw File'])
            %             disp([datestr(dnum),'  ',num2str(ticks)])           % debugging info
            disp(['last     datetime: ',datestr(dnum,'yy mm dd HH MM SS FFF')])
            dw = byte_length(h) - wmax; % how much larger read data is than max
            fseek(fod,dw,0);        % skip back to fill only wmax
            saveByteLoc2 = saveByteLoc2 - dw;   % move xwav file pointer back
            byte_length(h) = wmax;  % set byte length to wmax
            disp(['Set byte_length = ',num2str(wmax),' and fseek back ',num2str(dw),' bytes in xwav file'])
        end
        
        if rem(byte_length(h),nbytesPerSect) ~= 0
            disp_msg(['Triton Error : not integer number of sectors for raw file ',num2str(h)])
        end
        write_length(h) = floor(byte_length(h) / nbytesPerSect);    % number of full (uncompressed) 16-bit sectors
        if h > 1
            byte_loc(h) = raw1data_byteloc + sum(byte_length(1:h-1));
        else
            byte_loc(h) = raw1data_byteloc;
        end
        skip = raw1head_byteloc + 8 + (h-1)*32;   % skip to byte_loc in XWAV raw file header
        status = fseek(fod,skip,'bof');
        
        % write values for btye_loc, byte_length, write_length
        fwrite(fod, byte_loc(h) , 'uint32');
        fwrite(fod, byte_length(h), 'uint32');
        fwrite(fod, write_length(h), 'uint32');
        %
        status = fseek(fod,saveByteLoc2,'bof');     % go back to writing data location
        
        
%        disp(['Number of Blocks = ',num2str(nBlksPerRawFile),'  Number of
%        bytes = ',num2str(byte_length(h))]) %this info is now in
%        decompressRawHRP 4/29/11
        
        % need to modify XWAV header to correct for filesize for each XWAV file
        fsize = byte_loc(nhrp) + byte_length(nhrp) - 8;
        status = fseek(fod,4,'bof');     % go back to writing data location
        fwrite(fod,fsize,'uint32');     % wave file size - 8 bytes
        skip = raw1head_byteloc + nhrp*32 + 4;   % skip to dSubchunkSize
        status = fseek(fod,skip,'bof');     % go back to writing data location
        fwrite(fod,sum(byte_length(1:nhrp)),'uint32');
        
        % close XWAV file
        fclose(fod);
        
    end % end dtype - data type
    
end  % end ii - loop on number of files to make from this one raw file
fclose(fid);
