function read_ltsadata
%
% read ltsa data
%
% make work with scheduled/duty-cycle data
%
% smw 070707
%
global PARAMS

check_ltsa_time

fid = fopen([PARAMS.ltsa.inpath,PARAMS.ltsa.infile],'r');

% nbin = floor(PARAMS.tseg.sec / PARAMS.psd.tlen); % number of bins to read/plot

% nbin = PARAMS.psd.b2-PARAMS.psd.b1;         % how many bins to grab
% b1 = PARAMS.psd.b1;                         % first bin

% PARAMS.ltsa.tave = [seconds/bin]
nbin = floor((PARAMS.ltsa.tseg.hr * 60 *60 ) / PARAMS.ltsa.tave); 
% disp_msg(['Number of Bins to Plot: ',num2str(nbin)])

% which raw file to start plot with
PARAMS.ltsa.plotStartRawIndex = [];
% PARAMS.ltsa.plotStartRawIndex = find(PARAMS.ltsa.plot.dnum - PARAMS.ltsa.dnumStart >= ...
%      - datenum([0 0 0 0 0 PARAMS.ltsa.tave]) & PARAMS.ltsa.plot.dnum <= PARAMS.ltsa.dnumEnd);
% find which raw file the plot start time is in
% PARAMS.ltsa.plotStartRawIndex = find(PARAMS.ltsa.plot.dnum >= PARAMS.ltsa.dnumStart ...
%      & PARAMS.ltsa.plot.dnum + datenum([0 0 0 PARAMS.ltsa.tseg.hr 0 0]) <= PARAMS.ltsa.dnumEnd );
%
% find which raw file plot start time (PARAMS.ltsa.plot.dnum) is in
% 
PARAMS.ltsa.plotStartRawIndex = find(PARAMS.ltsa.plot.dnum >= PARAMS.ltsa.dnumStart ...
     & PARAMS.ltsa.plot.dnum + datenum([0 0 0 0 0 PARAMS.ltsa.tave])  <= PARAMS.ltsa.dnumEnd );
 %
% if the plot start time is not within a raw file (i.e., non-recording time between raw files),
% find which ones it is between 
%
if isempty(PARAMS.ltsa.plotStartRawIndex)
    PARAMS.ltsa.plotStartRawIndex = min(find(PARAMS.ltsa.plot.dnum <= PARAMS.ltsa.dnumStart));
    PARAMS.ltsa.plot.dnum = PARAMS.ltsa.dnumStart(PARAMS.ltsa.plotStartRawIndex);
end

% disp_msg(['index= ',num2str(PARAMS.ltsa.plotStartRawIndex)]);
%
% time bin number at start of plot within rawfile (index)
PARAMS.ltsa.plotStartBin = floor((PARAMS.ltsa.plot.dnum - ....
    PARAMS.ltsa.dnumStart(PARAMS.ltsa.plotStartRawIndex)) * 24 * 60 * 60 ...
    / PARAMS.ltsa.tave) + 1;

% samples to skip over in ltsa file
skip = PARAMS.ltsa.byteloc(PARAMS.ltsa.plotStartRawIndex) + ....
    (PARAMS.ltsa.plotStartBin - 1) * PARAMS.ltsa.nf;

% nbin = floor(PARAMS.ltsa.tseg.sec / PARAMS.ltsa.tave);

%skip = PARAMS.ltsa.dataStartLoc + ((ai - 1) * 1 * PARAMS.ltsa.nf);
% disp_msg(['skip= ',num2str(skip)]);
fseek(fid,skip,-1);    % skip over header + other data
PARAMS.ltsa.pwr = [];
PARAMS.ltsa.pwr = fread(fid,[PARAMS.ltsa.nf,nbin],'int8');   % read data

% time bins
tbinsz = PARAMS.ltsa.tave/(60*60);
% only good for continuous data, but just used for seconds/pixel in ltsa
% plot
PARAMS.ltsa.t = [];
PARAMS.ltsa.t = [0.5*tbinsz:tbinsz:(nbin-0.5)*tbinsz];

fclose(fid);

