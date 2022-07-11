function get_params

global REMORA
REMORA.dt_bwb.success = 1;

% color
mycolor = [.8,.8,.8];
r = 4;
c = 8;
h = 0.02*r; % panel width and height
w = 0.025*c;

bh = 1/r; % button/element width/height
bw = 1/c;

% make x and y locations in plot control window (relative units)
y = zeros(1, r);
for ri = 1:r 
    if ri == 1
        y(ri) = 0;
    else 
        y(ri) = 1/r + y(ri-1);
    end
end

x = zeros(1, r);
for ci = 1:c
    if ci == 1
        x(ci) = 0;
    else
        x(ci) = 1/c + x(ci-1);
    end
end


x = zeros(1, r);
for ci = 1:c
    if ci == 1
        x(ci) = 0;
    else
        x(ci) = 1/c + x(ci-1);
    end
end

% get input and output directories
btnPos = [0,0,w,h];

REMORA.fig.dt_bwb = figure('Name', 'Select Detector Parameters', 'Units',...
    'normalized', 'Position', btnPos, 'MenuBar', 'none', 'NumberTitle', ...
    'off', 'CloseRequestFcn', 'dt_bwb_ctrl(''close_cancel'')');
movegui(gcf, 'center');

% title
labelStr = 'Detector options';
btnPos = [x(1),y(end), 5*bw, bh];
uicontrol(REMORA.fig.dt_bwb, 'Units', 'normalized', 'BackgroundColor', ...
    mycolor, 'Position', btnPos, 'Style', 'text', 'String', labelStr);

% params file
labelStr = 'Detector params';
btnPos = [x(1), y(end-1), 2*bw, bh];
uicontrol(REMORA.fig.dt_bwb, 'Units', 'normalized', 'BackgroundColor',...
    mycolor, 'Position', btnPos, 'Style', 'text', 'String', labelStr);

labelStr = 'Browse';
btnPos = [x(7), y(end-1),2*bw,bh];
REMORA.fig.browsebois = uicontrol(REMORA.fig.dt_bwb, 'Units', ...
    'normalized', 'Position', btnPos, 'String', labelStr, ...
    'Style', 'pushbutton', 'Callback','dt_bwb_ctrl(''getfile'')');

btnPos = [x(3),y(end-1),4*bw,bh];
REMORA.fig.dir_handles = uicontrol(REMORA.fig.dt_bwb, 'Units', ...
    'normalized', 'Position', btnPos, 'Style', 'edit', ...
    'BackgroundColor', 'white', 'HorizontalAlignment','left');

% display flag
labelStr = 'Display spectrogram?';
btnPos = [x(1), y(end-2), 4*bw, bh];
REMORA.fig.dflag = uicontrol(REMORA.fig.dt_bwb, 'Units', ...
    'normalized', 'Position', btnPos, 'Style', 'radio', ...
    'String', labelStr, 'BackgroundColor', mycolor,...
    'Callback', 'dt_bwb_ctrl(''dflag'')');


% continue
labelStr = 'Continue';
btnPos = [x(4), y(1), bw*2, bh];
uicontrol(REMORA.fig.dt_bwb, 'Units', 'normalized', 'Position', btnPos, ...
'String', labelStr, 'Callback', 'dt_bwb_ctrl(''ctn'')');

uiwait;
uiresume;
end

