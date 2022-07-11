function plot_timeseries
%
%
% 060205 smw modified to include red line
% for RawFile boundaries
%
% 060211-060227 smw individual plots for v1.60
%
%
% Do not modify the following line, maintained by CVS
% $Id: plot_timeseries.m,v 1.1.1.1 2006/09/23 22:31:55 msoldevilla Exp $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global DATA HANDLES PARAMS

% get which figures plotted
savalue = get(HANDLES.display.ltsa,'Value');
tsvalue = get(HANDLES.display.timeseries,'Value');
spvalue = get(HANDLES.display.spectra,'Value');
sgvalue = get(HANDLES.display.specgram,'Value');

% total number of plots in window
m = savalue + tsvalue + spvalue + sgvalue;

% ellipical filter
if PARAMS.filter
    [b,a] = ellip(4,0.1,40,[PARAMS.ff1 PARAMS.ff2]*2/PARAMS.fs);
    DATA = filter(b,a,DATA);
end

% DATA length
len = length(DATA);

% calculate delimiting line for RawFiles
rflag = 0;

% rtime = (PARAMS.raw.dnumEnd(PARAMS.raw.currentIndex) - PARAMS.plot.dnum)...

if ~isempty(PARAMS.xhd.byte_length)
    numr = 0;
    %timer = 0;
    c=1;
    timer = PARAMS.plot.bytelength;
    t = PARAMS.raw.currentIndex;
    %while timer < PARAMS.tseg.sec*PARAMS.xhd.ByteRate(1) && numr <= length(PARAMS.xhd.byte_length)
 
    while (PARAMS.xhd.byte_loc(t)+PARAMS.xhd.byte_length(t)) <= PARAMS.plot.bytelength + PARAMS.tseg.sec*PARAMS.xhd.ByteRate(1) && t <= PARAMS.xhd.NumOfRawFiles
        %timer = PARAMS.xhd.byte_length(numr) + timer;
        if timer > PARAMS.xhd.byte_loc(t)+PARAMS.xhd.byte_length(t)
            t= t+1;
        
        elseif timer == PARAMS.xhd.byte_loc(t)+PARAMS.xhd.byte_length(t)
            rflag = 1;
            rtime = (timer - PARAMS.plot.bytelength)/PARAMS.xhd.ByteRate(1);
            t= t+1;
            x{c} = [rtime,rtime];
            c=c+1;
            timer = timer + PARAMS.xhd.ByteRate(1);
            numr = numr + 1;

        else
            timer = timer + PARAMS.xhd.ByteRate(1);
            numr = numr + 1;

        end
    end

else
    rint = 1;
    rtime = (PARAMS.raw.dnumEnd(PARAMS.raw.currentIndex) - PARAMS.plot.dnum)...
    * 60 *60 * 24;
    while rtime < PARAMS.tseg.sec
        rflag = 1;
        x{rint} = [rtime,rtime];
        rtime =(PARAMS.raw.dnumEnd(PARAMS.raw.currentIndex + rint) - PARAMS.plot.dnum)...
        * 60 *60 * 24;
        rint = rint +1;
    end
end
% time series only
HANDLES.subplt.timeseries = subplot(HANDLES.plot.now);
HANDLES.plt.timeseries = plot((0:len-1)/PARAMS.fs,DATA);

% check to see if time series plot goes past end of data, if so,
% correct it
v = axis;
if PARAMS.auto
    if v(2) > (len-1)/PARAMS.fs
        v(2) = (len-1)/PARAMS.fs;
        axis(v)
    end
else
    axis([v(1) v(2) PARAMS.ts.min PARAMS.ts.max])
end

% plot red line if plot figure crosses RawFile boundary & delimit button on:
if rflag & PARAMS.delimit.value
    for r=1:length(x)
        y = [v(3),v(4)];
        HANDLES.delimit.tsline = line(x{r},y,'Color','r','LineWidth',4);
    end
end

%labels
ylabel('Amplitude [counts]')
xlabel('Time [seconds]')

% text positions
tx = [0 0.70 0.85];                 % x
ty = [-0.05 -0.125 -0.175 -0.25];  % y upper left&right
ty2 = [-0.075 -0.175 -0.25 -0.35];  % y lower right

if ~spvalue
    % put window start time on bottom plot only:
    text('Position',[0 ty(m)],'Units','normalized',...
        'String',timestr(PARAMS.plot.dnum,1));
end

% plot title on top plot
if ~sgvalue
    if PARAMS.filter == 1
        title([PARAMS.inpath,PARAMS.infile,' CH=',num2str(PARAMS.ch),...
            '      Band Pass Filter ',num2str(PARAMS.ff1),' Hz to ',...
            num2str(PARAMS.ff2),' Hz'])
    else
        title([PARAMS.inpath,PARAMS.infile,' CH=',num2str(PARAMS.ch)])
    end
end

% update control window with time info
set(HANDLES.time.edtxt1,'String',timestr(PARAMS.plot.dnum,3));
set(HANDLES.time.edtxt2,'String',timestr(PARAMS.plot.dnum,4));
set(HANDLES.time.edtxt3,'String',timestr(PARAMS.plot.dnum,5));
set(HANDLES.time.edtxt4,'String',num2str(PARAMS.tseg.sec));
