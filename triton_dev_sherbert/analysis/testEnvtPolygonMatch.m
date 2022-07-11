clear all;

site = 'R';
variable = 'ppr';

%hard-wire data you're pulling
inpath = 'H:\data\Research\SOCAL habitat modeling\Environmental Data\ERDDAP\';
infile = ['site' site variable '.mat'];
envinfile = [inpath infile];

%Pull data that decsribe the polygon of the detection ranges
secondinp = 'I:\SOCAL average Oct noise\Clean TL data\';
secondinf = ['site' site 'rangesBlue.mat'];
load([secondinp secondinf]);
detrange = [longs; lats]';
% detrange = [-120 40; -120 45; -118 45; -120 40];

[DetRangeData, NumGrid, Area] = anEnvtPolygonMatch(envinfile,detrange,'Plots','grid');