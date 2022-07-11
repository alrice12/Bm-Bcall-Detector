function pickxyz(varargin)
% pickxyz - Time-frequency selector
%
% Called with each mouse button click
% ie. WindowButtonDownFcn callback for HANDLES.fig.main
%
% Selections are used for:
%   expanding LTSAs
%   selecting items in the logger
%   displaying points the message window
% When multiple items are possible, only the first one is done.
%
%
% pulled out of toolpd
%
% 060221 - 060227 smw
%
% 060612 smw v1.61

global HANDLES PARAMS

selectiontype = get(HANDLES.fig.main,'SelectionType');
PARAMS.pick.button.value = get(HANDLES.pick.button,'Value');
PARAMS.expand.button.value = get(HANDLES.ltsa.expand.button,'Value');

% turn on/off cross hairs
if PARAMS.pick.button.value || PARAMS.expand.button.value || ~isempty(PARAMS.log.pick)
    set_pointer(HANDLES.fig.main, 'fullcross');
else
    set_pointer(HANDLES.fig.main, 'arrow');
end

if (nargin == 1 && varargin{1} == true) || ...
        (nargin == 3 && ishandle(varargin{1}) && varargin{3} == true)
    % Not a callback, the use just wanted the cursor set
    return
end

% if strcmp(selectiontype,'normal' & ~PARAMS.zoomin.button.value) ...
% if strcmp(selectiontype,'normal') ...
%         | (strcmp(selectiontype,'alt') & ~PARAMS.pick.button.value)
%     set(HANDLES.fig.main,'SelectionType','normal')
%     return
% elseif PARAMS.pick.button.value & strcmp(selectiontype,'alt')
%     set(HANDLES.fig.main,'SelectionType','normal')

if strcmp(selectiontype, 'alt')
    % Alternate selection - shift click
    return  % We are not doing anything with alternate selections yet
end

% LTSA active?
savalue = get(HANDLES.display.ltsa,'Value');

% Is this an LTSA expansion?
if PARAMS.expand.button.value && savalue && ...
        (gco == HANDLES.subplt.ltsa || gco == HANDLES.plt.ltsa)
    % disp_msg('Right Click LTSA window to see coordinates of cursor')
    pickxwav

    % turn on channel changer to correct channel selection
    set(HANDLES.ch.pop,'Value',PARAMS.ch)
else
    
    if isempty(gco)
        % callback not associated with any object
        % Can reliably reproduce when clicking on colorbar label,
        % it's not clear why this happens.
        return;   
    end
    % Selection currently in window space,
    % translate to the space of the axis where the user made the pick.
    currentAx = get(HANDLES.fig.main, 'CurrentAxes');
    [x, y] = getCurrentPoint(currentAx);
    %fprintf('time %f, freq %f axis %f\n', x, y, currentAx);
    
    % Let user drag out bounding box (rubber band box)
    oldptr = set_pointer(HANDLES.fig.main, 'crosshair');
    extent = rbbox();  
    [x2, y2] = getCurrentPoint(currentAx);
    set_pointer(HANDLES.fig.main, oldptr);
    
    time = [];   % Will be mapped from x and y based on the display type
    freq = [];
    pwr = [];
    timeidx = [];
    freqidx = [];
    
    % Determine which plots are active in the display window
    tsvalue = get(HANDLES.display.timeseries,'Value');
    spvalue = get(HANDLES.display.spectra,'Value');
    sgvalue = get(HANDLES.display.specgram,'Value');

    if tsvalue  % time series
        if gco == HANDLES.subplt.timeseries ||...
                gco == HANDLES.plt.timeseries || gco == HANDLES.delimit.tsline
            [time, freq, fname] = current_timeseries(x, y);
            time(2) = current_timeseries(x2, y2);
        end
    end
    if spvalue % spectra
        if gco == HANDLES.subplt.spectra || gco == HANDLES.plt.spectra
            ctime_dvec = datevec(PARAMS.plot.dnum);
            HHMMSS = timestr(ctime_dvec,4);
            freq = round(x);
            disp_pick([HHMMSS,'    ',num2str(freq),'Hz   ',num2str(y,'%0.2f'),'dB'])
        end
    end

    if sgvalue % spectrogram
        if gco == HANDLES.subplt.specgram || gco == HANDLES.plt.specgram...
                || gco == HANDLES.delimit.sgline
            [time(1), freq(1), pwr(1), fname, timeidx(1), freqidx(1)] = current_specgram(x, y);
            [time(2), freq(2), pwr(2), dontcare, timeidx(2), freqidx(2)] = current_specgram(x2, y2);
        end
    end

    if savalue % long term spectral average (neptune)
        if gco == HANDLES.subplt.ltsa || gco == HANDLES.plt.ltsa
            [time(1), freq(1), pwr(1), fname] = current_ltsa(x, y);
            [time(2), freq(2), pwr(2)] = current_ltsa(x2, y2);
        end
    end
    
    % Only process selection if we have a valid time or frequency
    if ~isempty(time) || ~ isempty(freq)
        if ~ isempty(PARAMS.log.pick)
            if ~ isempty(time)
                log_pick(time, freq, timeidx, freqidx, fname); % inform logger of selection
            end
        end
        
        if PARAMS.pick.button.value
            timevec = datevec(time(1));
            % datevec doesn't handle usec very well, redo 
            % calculation of s
            timevec(end) = rem(rem(time(1)*24*3600, 1), 1);
            HHMMSS = timestr(timevec,4);
            mmmuuu = timestr(timevec,5);
            
            if isempty(freq)
                str = sprintf('%s.%s', HHMMSS, mmmuuu);
            elseif isempty(pwr)
                str = sprintf('%s.%s    %d', HHMMSS, mmmuuu, freq(1));
            else
                str = sprintf('%s.%s   %d Hz   %0.1f dB', ...
                    HHMMSS, mmmuuu, freq(1), pwr(1));
            end
            disp_pick(str);
        end
    end
end

% -----------------------------------------------------------------------
function [x, y] = getCurrentPoint(ax)
% [x, y] = getCurrentPoint(ax)
% Get the currently selected point within the specified axis ax.  
% If the point lies outside the axis, move it to the edge of the axis

point = get(ax,'CurrentPoint');  % get point in axis coordinates
xlim = get(ax, 'XLim');  % Find axis limits
ylim = get(ax, 'YLim');

x = boundsConstrain(point(1,1), xlim);  % Constrain to be within limit
y = boundsConstrain(point(1,2), ylim);

% -----------------------------------------------------------------------
function val = boundsConstrain(val, range)
% val = boundsConstrain(val, range)
% Constrain val such that range(1) <= val <= range(2)

%return
if val < range(1)
    val = range(1);
elseif val > range(2)
    val = range(2);
end

% -----------------------------------------------------------------------
function [time, freq, fname] = current_timeseries(x, y)
% [time, freq, fname] = current_timeseries(x, y)

global PARAMS HANDLES
freq = NaN;  % frequency does not apply to timeseries unless we want to
             % estimate the instantaneous frequency.

% Quantize to nearest sample
sample_s = 1/PARAMS.fs;
x = round(x / sample_s)*sample_s;

% Find serial date associated with time
time = get_time(x, HANDLES.subplt.timeseries);
freq = [];  % not applicable
fname = fullfile(PARAMS.inpath,PARAMS.infile);

% -----------------------------------------------------------------------
function [time, freq, pwr, fname, timeidx, freqidx] = current_specgram(x, y)
% [time, freq, pwr, fname] = current_specgram(x, y)
% Given a relative time X freq point in the spectrogram plot,
% find the current time, frequency, spectral power and filename

global PARAMS HANDLES

% quantize time and find timeidx with respect to display
[dontcare, timeidx] = min(abs(PARAMS.t - x));
quant_t = PARAMS.t(timeidx);

% Find serial date associate with time
time = get_time(quant_t, HANDLES.subplt.specgram);

% Find closest discretized frequency and its index
[dontcare, freqidx] = min(abs(PARAMS.f - y));
freq = PARAMS.f(freqidx);


% Retrieve spectrogram power
pwr = PARAMS.pwr(freqidx, timeidx);
fname = fullfile(PARAMS.inpath,PARAMS.infile);  % current file

% -----------------------------------------------------------------------
function time = get_time(x, axisH)
% Given a time in s on the current axis, convert it to a serial
% date taking into account duty cycling, etc.

global PARAMS HANDLES

% Adjust for time indices going past end of plot
% Typically happens when sweeping out a region
xrng = get(axisH, 'XLim');

x = min(max(x, min(xrng)), max(xrng));  % Make sure in range
xSer = datenum(0,0,0,0,0,x);  % Convert s to serial date offset
found = false;
% Index of current raw file at start of display
rawIdx = PARAMS.raw.currentIndex;
endTime = PARAMS.raw.dnumEnd(rawIdx);
rawDelta = endTime - PARAMS.plot.dnum;
time = xSer + PARAMS.plot.dnum;
found = time <= endTime;
while ~ found
    % Subtract off time covered by current raw file
    xSer = xSer - rawDelta;
    if rawIdx < length(PARAMS.raw.dnumEnd)
        % Find start and end of next raw file
        rawIdx = rawIdx + 1;
        startTime = PARAMS.raw.dnumStart(rawIdx);
        endTime = PARAMS.raw.dnumEnd(rawIdx);

        rawDelta = endTime - startTime;  % time covered
        time = startTime + xSer;
        found = time <= endTime;
    else
        time = endTime;  % reached end
    end
end


% -----------------------------------------------------------------------
function  [time, freq, pwr, fname] = current_ltsa(x, y)
% [time, freq, fname] = current_ltsa(x, y)
% Translate offset time (x) and freq (y) to absolute time/freq

global PARAMS HANDLES

% Time and frequency have been discretized.  Find the time/freq pair
% closest to where the user clicked

% We need the index both with respect to the start of the display
% (for power) and with respect to the start of the most recent raw
% file (for time).

% timeidx with respect to display
[dontcare, timeidx] = min(abs(PARAMS.ltsa.t - x));

% Find the index into the raw file associated with time & offfset into
% the raw file
[rawIdx, binIdx] = getIndexBin(x);
% Translate the time discretization to serial date format
binsz_dnum = datenum(0,0,0,0,0,PARAMS.ltsa.tave);
time = PARAMS.ltsa.dnumStart(rawIdx) + (binIdx - .5) * binsz_dnum;

% Find closest discretized frequency
[dontcare, freqidx] = min(abs(PARAMS.ltsa.f - y));
freq = PARAMS.ltsa.f(freqidx);
pwr = PARAMS.ltsa.pwr(freqidx, timeidx);  % Retrieve associated power

fname = fullfile(PARAMS.ltsa.inpath,PARAMS.ltsa.infile);

