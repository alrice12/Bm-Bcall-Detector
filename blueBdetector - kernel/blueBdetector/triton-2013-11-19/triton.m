function triton
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% triton.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% v 1.62.20060914 smw - ltsa for wav files
%
% v1.60 060221 - 060227 smw
% 060210 smw modified for LTSA triton v1.60
% 060203smw haven't compiled in a long time....
%
% matlab compiled triton 1.50, sometimes...
%
% initial development 5/5/04 smw
% for most recent revision date, see helppd.m
% 
% version 1.51 new control window and timing
% 
% version 1.50 smw
% add capability to use dirlist times in xwav header
% fix various bugs and add new and previously available capabilities.
%
%
% subroutines to link with main during compiling 
% because these are called via 'Callback'
% note: do NOT name these with capital letters because compiler converts
% them to small letters and Callback will point to incorrect filename.
%
% Do not modify the following line, maintained by CVS
% $Id: triton.m,v 1.11 2013/05/29 20:26:31 mroch Exp $

%#function filepd
%#function toolpd
%#function displaypd
%#function paramspd

%#function motion
%#function control
%#function logcontrol

%#function bin2xwav

%#function helppd

clear global;  % clear out old globals
clc;        % clear command window  -- not needed for compiled
%               version, gets a complaint in cmd 'display' window
close('all', 'hidden');  % close all figure windows
warning off % this is turned off for plotting messages


% Add subdirectories to search path
RootDir = fileparts(which('triton'));
addpath(genpath2(RootDir, 'ExcludeDirs', {'CVS', 'lib', 'java'}, 'ExcludeRootDir', 1));

% Set up java search path

% Add all java archives (jar) that are under RootDir/java
JavaDir = fullfile(RootDir, 'java');
java_archives = utFindFiles({'*.jar'}, {JavaDir}, 1);
if ~ isempty(java_archives);
    javaaddpath(java_archives);
end

% Treat any subdirectories of RootDir/java as packages and add them to the
% path
d = dir(JavaDir);
for idx=1:length(d)
    if d(idx).isdir
        % Directory, add to path except for current and parent directory
        % symbolic links
        if strcmp(d(idx).name, '.') || strcmp(d(idx).name, '..')
            continue  % skip
        end
        javaaddpath(fullfile(JavaDir, d(idx).name));
    end
end

global PARAMS
PARAMS.ver = 'Detector 2013-10-13 REST client (based on 1.63.20070212)';

disp(' ')
disp(['         Triton version ',PARAMS.ver])


initparams
%disp(PARAMS)

initwins

initcontrol

init_coorddisp

initpulldowns

dt_initcontrol
