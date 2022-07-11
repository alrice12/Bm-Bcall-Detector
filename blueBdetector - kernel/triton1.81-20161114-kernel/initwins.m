function initwins
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% initwins.m
% 
% initialize figure, control and command(display) windows
%
% 5/5/04 smw
%
% updated 060211 - 060227 smw for triton v1.60
%
% 060517 smw - ver 1.61
%
% 060725 smw = ver 1.62
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% figure window
%
global HANDLES PARAMS

% give user some info
disp(' ');
disp(' Clearing all windows to begin Triton');
disp(' Now loading Triton initial screen...');
disp(' ');
% use screen size to change plot control window layout 
PARAMS.scrnsz = get(0,'ScreenSize');
% window placement & size on screen
%	defaultPos=[0.333,0.1,0.65,0.80];
if str2num(PARAMS.mver(1:3)) ~= 7.4
    defaultPos=[0.335,0.05,0.65,0.875];
else
    defaultPos=[0.335,0.049,0.65,0.875]; % needed for bug in 7.4.0.287 (R2007a)
end
% remove following: puts new windows small and btm lft corner
% set(0,'DefaultFigurePosition',defaultPos)
% open and setup figure window
HANDLES.fig.main =figure( ...
    'NumberTitle','off', ...
    'Name',['Plot - Triton '], ...
    'Units','normalized',...
    'Position',defaultPos);

%
set(gcf,'Units','pixels');
% Tools for editing and annotating plots
% plotedit on		
% put axis in bottom left, make it tiny,
% turn it off, and save location in variable axHndl1
%set(gca,'position',[0 0 1 1]);
axis off
axHndl1=gca;

% Function for adding hotkey commands to the plot figure
% possibly more functions will be added later on for 
% the use on other figures
keypress

if exist('Triton_logo.jpg')
    image(imread('Triton_logo.jpg'))
    text('Position',[.7 .15],'Units','normalized',...
        'String',PARAMS.ver,...
        'FontSize', 14,'FontName','Times','FontWeight','Bold');
end

axis off
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% zoom tool stuff
%detect version
v=version;

%Get proper handles to zoom in and zoom out uitoggletool buttons.  Account
%for difference in tag names between version 6 and version 7

if (str2num(v(1))<7)
    HANDLES.zoom.hin = findall(HANDLES.fig.main,'tag','figToolZoomIn');
    HANDLES.zoom.hout = findall(HANDLES.fig.main,'tag','figToolZoomOut');
else
    HANDLES.zoom.hin = findall(HANDLES.fig.main,'tag','Exploration.ZoomIn');
    HANDLES.zoom.hout = findall(HANDLES.fig.main,'tag','Exploration.ZoomOut');
end

% Change the callback for the "Zoom In" toolbar button
set(HANDLES.zoom.hin,'OffCallback','zoomChangeTime')

% Change the callback for the "Zoom Out" toolbar button
set(HANDLES.zoom.hout,'OffCallback','zoomChangeTime')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% initialize control window
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% window placement & size on screen
defaultPos=[0.025,0.35,0.3,0.6];
% open and setup figure window
HANDLES.fig.ctrl =figure( ...
    'NumberTitle','off', ...
    'Name',['Control - Triton '],...
    'Units','normalized',...
    'MenuBar','none',...
    'Position',defaultPos);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% initialize message display window
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% window placement & size on screen
defaultPos=[0.025,0.05,0.3,0.25];
% open and setup figure window
HANDLES.fig.msg =figure( ...
    'NumberTitle','off', ...
    'Name',['Message - Triton '],...
    'Units','normalized',...
    'MenuBar','none',...
    'Position',defaultPos);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% When a figure is active and we change the cursor from fullcross to
% something else a trace is left.  This bug has been submitted to
% Mathworks (MAR, 2011-01-07).  We can workaround it by changing
% to another window first.  This invisible window does the trick
% Used by function set_cursor.
HANDLES.fig.fullcrossbug = figure('MenuBar', 'none', 'Visible', 'off');
