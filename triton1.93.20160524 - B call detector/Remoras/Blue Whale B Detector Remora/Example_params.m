% input parameters for the blue whale b detector
global REMORA

% input/output directories
REMORA.dt_bwb.indir = 'Z:\MB03\MB03_02\SanctSound_MB03_02_df100\MB03_02_disk05_df100\';
%REMORA.dt_bwb.outdir = 'F:\General LF Data Analysis\B call detector\SOCAL\';
REMORA.dt_bwb.outdir = 'C:\Users\Harp\Desktop\SanctSound Bm detector\Detector output\MB03_02\';
% kernel
REMORA.dt_bwb.startF = [44.9,43.9,43.2,43];
REMORA.dt_bwb.endF = [43.9,43.2,43,42.3];
REMORA.dt_bwb.kern = 'MB01_03';

% REMORA.dt_bwb.startF = [45.6,45,44.4,43.8];
% REMORA.dt_bwb.endF = [45,44.4,43.8,42.8];
% REMORA.dt_bwb.kern = '63N';

% threshold
REMORA.dt_bwb.thresh = 37;