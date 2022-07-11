function initparams
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% initparams.m
% 
% initialize parameters
%
% 5/5/04 smw
% updated 060203 - 060227 smw
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global PARAMS HANDLES

defaultparamfile = ['C:\','default.prm'];
%defaultparamfile = [dpath,'junk.prm'];

% get matlab version for differences and backwards capatibility
PARAMS.mver = version;

% Set the defaults first
PARAMS.inpath='C:'; 			% works for all machines
PARAMS.infile='';           % no default file
PARAMS.netpath=[];          % no netpath
PARAMS.run_mat='';        % matlab script to run
PARAMS.ptype = 1;				% first display type 
PARAMS.fax = 0;                  % linear or log freq axis
PARAMS.aptime = 0;			%  pause time (typically CPU speed dependent?
PARAMS.bright = 0;				% shift in dB
PARAMS.contrast = 100;			% amplify in % dB
PARAMS.freq0 = 0;				% set frequency PARAMS lower limit
PARAMS.freq1 = -1;         % set frequency PARAMS upper limit
PARAMS.nfft = 1000;			% length of fft
PARAMS.overlap = 0;			% %overlap
PARAMS.cmap = 'jet';			% color map for spectrogramn
PARAMS.tseg.step = -1;      % Step size (== dur by default)
PARAMS.ttype = 'seg';        % Time reference type
PARAMS.pspeed = 1;         % Playback speed factor
PARAMS.fPARAMS = 1;         % At first, automatically try to load PARAMS when over
PARAMS.last.sec = -1;       % To stop infinite recursion on unavailable PARAMS

PARAMS.hT = 'x';            % User defined transfer function for time series
PARAMS.df=1;            %added default decimation factor=1 (not decimated?) LMM 11/17/2009
PARAMS.ch = 1;               % channel number for wav PARAMS
PARAMS.nch = 1;              % total number of channels in wav file

% Values for Image Output
PARAMS.ioft = 'tif';			% TIF default filetype
PARAMS.iobd = 8;				% 8 bits per pixel default bit depth
PARAMS.iocq = 80;				% 80% default quality on compression
PARAMS.ioct = 'packbits';	% packbits default compression type

% filter parameters
PARAMS.filter = 0;
PARAMS.ff1 = 2000;
PARAMS.ff2 = 10000;

PARAMS.gainflag = 1;         % do pre amp gain on obs data (1=yes,0=no)

PARAMS.tseg.sec = 1;         % initial window time segment duration

PARAMS.blk.max = 1;          % max number of blocks (not used anymore?)

% Overwrite any defaults with those in the user's file
if exist(defaultparamfile) == 2
    % open data file
    PARAMS.paramfid = fopen(defaultparamfile,'r');
    if PARAMS.paramfid == -1
        disp_msg('Error: no such file')
        return
    end
    nparam = str2num(fgets(PARAMS.paramfid));
    if nparam < 1
        disp_msg('Error: no data in defaults file')
    else
        for i = 1 : nparam
            line = fgets(PARAMS.paramfid);
            %  junk=evalc(line);
        end
        %    echo on
    end
    fclose(PARAMS.paramfid);
end

% ARP stuff:
PARAMS.c2p.db = 63.4;
PARAMS.c2p.lin = 1.491e-3;
PARAMS.secday = 24*60*60;	% seconds per day

PARAMS.start.dnum = datenum([0 1 1 0 0 0]);
PARAMS.plot.dnum = [];
PARAMS.cancel = 0;

PARAMS.auto = 1; % auto scale power spectra
PARAMS.sp.min = -30;    % min spl dB
PARAMS.sp.max = 80;     % max spl dB
PARAMS.ts.min = -2^15;  % min amp counts
PARAMS.ts.max = 2^15;   % max amp counts

PARAMS.window = 'hanning';

PARAMS.xgain = 2;

PARAMS.speedFactor = 1;
PARAMS.sndVol = 0.25;

PARAMS.delimit.value = 1;
HANDLES.delimit.tsline = 0;
HANDLES.delimit.sgline = 0;
PARAMS.pick.button.value = 0;
PARAMS.expand.button.value = 0;
PARAMS.button.down = 0;

PARAMS.ltsa.start.dnum = datenum([0 1 1 0 0 0]);

PARAMS.tf.freq = [10 100000];   % freq [Hz]
PARAMS.tf.uppc = [0 0];   % uPa/count [dB]
PARAMS.tf.flag = 0;
PARAMS.tf.filename = [];    % start with an empty filename

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initial parameter for LTSA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the defaults first
PARAMS.ltsa.inpath='C:'; 			% works for all machines
PARAMS.ltsa.infile='';           % no default
PARAMS.ltsa.tseg.step = -1;      % Step size (== dur by default)
PARAMS.ltsa.tseg.hr = 2;
PARAMS.ltsa.tseg.sec = PARAMS.ltsa.tseg.hr * 60 * 60;         % initial window time segment duration

PARAMS.ltsa.ftype = 1;
PARAMS.ltsa.freq0 = 0;				% set frequency PARAMS.ltsa lower limit
PARAMS.ltsa.freq1 = -1;         % set frequency PARAMS.ltsa.ltsa upper limit
PARAMS.ltsa.bright = 0;				% shift in dB
PARAMS.ltsa.contrast = 100;			% amplify in % dB
PARAMS.ltsa.fax = 0;                  % linear or log freq axis
PARAMS.ltsa.cmap = 'jet';			% color map for spectrogram
PARAMS.ltsa.start.yr = 0;
PARAMS.ltsa.start.str = '0000';
PARAMS.ltsa.aptime = 0;			%  pause time (typically CPU speed dependent?
PARAMS.ltsa.cancel = 0;
PARAMS.ltsa.delimit.value = 0;  %  delimit value is off at first
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% initialize recording params
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PARAMS.rec.sr = 200;
PARAMS.rec.int = 0;
PARAMS.rec.dur = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% logger
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PARAMS.log.pick = [];  % time/freq selection is not processed by logger

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initial parameters for detectors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Default LTSA Detection Parameters
% if ~isfield(PARAMS.ltsa, 'dt')
%     PARAMS.ltsa.dt.ignore_periodic = 1;
%     PARAMS.ltsa.dt.LowPeriod_s = 3*60;
%     PARAMS.ltsa.dt.HighPeriod_s = 7*60;
% 
%     % find places where signals are likely.
%     PARAMS.ltsa.dt.HzRange = [5000 90000];
% 
%     PARAMS.ltsa.dt.MeanAve_hr = 4;  % Spectral subtraction window
%     PARAMS.ltsa.dt.Threshold_dB = 2;
% 
%     PARAMS.ltsa.dt.mean_selection = 0;  % Information for means
%     PARAMS.ltsa.dt.selections = zeros(1,2);
%     PARAMS.ltsa.dt.mean_enabled = false;
% end
% 
% % Default spectrogram detection parameters
% PARAMS.dt.WhistlePos = 1;
% PARAMS.dt.ClickPos = 2;
% PARAMS.dt.Ranges = [5500 22000          % whistles
%     10000 100000];      % clicks
% PARAMS.dt.MinClickBandwidth = 10000; 
% PARAMS.dt.WhistleMinLength_s = .25;
% PARAMS.dt.WhistleMinSep_s = .0256;
% PARAMS.dt.Thresholds = [12,12];
% PARAMS.dt.MeanAve_s = Inf;
