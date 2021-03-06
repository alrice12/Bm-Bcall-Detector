function ck_ltsaparams
%
% check user defined ltsa parameters and adjusts/gives suggestions of
% better parameters so that there is integer number of averages per xwav
% file and
%
% called by mk_ltsa
%
% 060802 smw
% 060914 smw modified for wav files
%
global PARAMS


% get sample rate - only the first file sr for now.....
if PARAMS.ltsa.ftype == 1   % wav
    [y, PARAMS.ltsa.fs, nBits, OPTS] = wavread( fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(1,:)),10);
elseif PARAMS.ltsa.ftype == 2   % xwav
    fid = fopen(fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(1,:)),'r');
    fseek(fid,24,'bof');
    PARAMS.ltsa.fs = fread(fid,1,'uint32');          % Sampling Rate (samples/second)
    fclose(fid);
end

% check that all sample rates match first file
I = [];
I = find(PARAMS.ltsahd.sample_rate ~= PARAMS.ltsa.fs);
if ~isempty(I)
    disp_msg('different sample rates')
    disp_msg(num2str(PARAMS.ltsahd.sample_rate(I)))
    disp_msg(num2str(I))
    return
end

% check to see if header times are in correct order based on file names
tf = issorted(PARAMS.ltsahd.dnumStart);
if ~tf
    [B,IX] = sort(PARAMS.ltsahd.dnumStart);
    seq = 1:1:length(B);
    IY = find(IX ~= seq);
    disp_msg('Raw files out of sequence are : ')
    disp_msg(num2str(IX(IY)))
    disp_msg('header times are NOT sequential')
    % return
end

% number of samples per data 'block' HARP=1sector(512bytes), ARP=64kB
if PARAMS.ltsa.dtype == 1       % HARP data => 12 byte header
    if PARAMS.ltsa.nch == 1
        PARAMS.ltsa.blksz = (512 - 12)/2;
    elseif PARAMS.ltsa.nch == 4
        PARAMS.ltsa.blksz = (512 - 12 - 4)/2;
    else
        disp_msg('ERROR -- number of channels not 1 nor 4')
        disp_msg(['nchan = ',num2str(PARAMS.ltsa.nch)])
    end
elseif PARAMS.ltsa.dtype == 2   % ARP data => 32 byte header + 2 byte tailer
    PARAMS.ltsa.blksz = (65536 - 34)/2;
elseif PARAMS.ltsa.dtype == 3   % OBS data => 128 samples per block
    PARAMS.ltsa.blksz = 128;
elseif PARAMS.ltsa.dtype == 4   % Ishmael data => wave files from sonobuoy/arrays
    % don't worry about it for this type...
else
    disp_msg('Error - non-supported data type')
    disp_msg(['PARAMS.ltsa.dtype = ',num2str(PARAMS.ltsa.dtype)])
    return
end

% check to see if tave is too big, if so, set to max length
%
% maxTave = (PARAMS.ltsahd.write_length(1) * 250) / PARAMS.ltsa.fs;
if PARAMS.ltsa.ftype ~= 1
    maxTave = (PARAMS.ltsahd.write_length(1) * PARAMS.ltsa.blksz) / PARAMS.ltsa.fs;
    if PARAMS.ltsa.tave > maxTave
        PARAMS.ltsa.tave = maxTave;
        disp_msg('Averaging time too long, set to maximum')
        disp_msg(['Tave = ',num2str(PARAMS.ltsa.tave)])
    end
end
% number of samples for fft - make sure it is an integer
% PARAMS.ltsa.nfft = ceil(PARAMS.ltsa.fs / PARAMS.ltsa.dfreq);
PARAMS.ltsa.nfft = floor(PARAMS.ltsa.fs / PARAMS.ltsa.dfreq);
disp_msg(['Number of samples for fft: ', num2str(PARAMS.ltsa.nfft)])

% compression factor
PARAMS.ltsa.cfact = PARAMS.ltsa.tave * PARAMS.ltsa.fs / PARAMS.ltsa.nfft;
disp_msg(['XWAV to LTSA Compression Factor: ',num2str(PARAMS.ltsa.cfact)])
disp_msg(' ')

% number of frequencies in each spectral average:
if mod(PARAMS.ltsa.nfft,2) % odd
    PARAMS.ltsa.nfreq = (PARAMS.ltsa.nfft + 1)/2;
else        % even
    PARAMS.ltsa.nfreq = PARAMS.ltsa.nfft/2 + 1;
end
% PARAMS.ltsa.nfreq = PARAMS.ltsa.nfft/2 + 1;
% make sure the number of frequencies is an integer
% PARAMS.ltsa.nfreq = floor(PARAMS.ltsa.nfft/2 + 1);
% PARAMS.ltsa.nfreq = floor(PARAMS.ltsa.nfft/2) + 1;

