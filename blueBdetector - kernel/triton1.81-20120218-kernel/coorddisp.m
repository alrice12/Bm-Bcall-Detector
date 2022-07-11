function coorddisp()
%
% initdata call:
% set(HANDLES.fig.main,'WindowButtonMotionFcn','control(''coorddisp'')');
%
% 060227 smw modified for v1.60
%
% 0605025 smw ver 1.61
%
%*****************************************
global PARAMS HANDLES
%
currentaxispoint = get(get(HANDLES.fig.main,'CurrentAxes'),'CurrentPoint');
% selectiontype = get(HANDLES.fig.main,'SelectionType');
cx = currentaxispoint(1,1);
cy = currentaxispoint(1,2);
%
xlim = get(get(HANDLES.fig.main,'CurrentAxes'),'XLim');
ylim = get(get(HANDLES.fig.main,'CurrentAxes'),'YLim');
%
if cx < xlim(1) | cx > xlim(2) | cy < ylim(1) | cy > ylim(2)
    set(HANDLES.coorddisp,'Visible','off')
    set(HANDLES.ltsa.coorddisp,'Visible','off')
    return
end
%

button = get(HANDLES.fig.main, 'SelectionType');

savalue = get(HANDLES.display.ltsa,'Value');
tsvalue = get(HANDLES.display.timeseries,'Value');
spvalue = get(HANDLES.display.spectra,'Value');
sgvalue = get(HANDLES.display.specgram,'Value');
try
    if tsvalue % timeseries
        if gco == HANDLES.subplt.timeseries | gco == HANDLES.plt.timeseries ...
                | gco == HANDLES.delimit.tsline

            % time from beginning of plot to delimitor line [seconds]
            rtime{1} = (PARAMS.raw.dnumEnd(PARAMS.raw.currentIndex) - PARAMS.plot.dnum)...
                * 60 *60 * 24;
            rint = 1;
            flag = 0;
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
                        rtime{c} = (timer - PARAMS.plot.bytelength)/PARAMS.xhd.ByteRate(1);
                        t= t+1;
                        c=c+1;
                        timer = timer + PARAMS.xhd.ByteRate(1);
                        numr = numr + 1;

                    else
                        timer = timer + PARAMS.xhd.ByteRate(1);
                        numr = numr + 1;

                    end
                end
            else
                while flag == 0
                    r =(PARAMS.raw.dnumEnd(PARAMS.raw.currentIndex - 1 + rint) - PARAMS.plot.dnum)...
                    * 60 *60 * 24;
                    if r < PARAMS.tseg.sec
                        rtime{rint} = r;
                    else
                        flag = 1;
                    end
                    rint = rint +1;
                end
            end
            % convert x location into time for xwav
            if cx < rtime{1}
                ctime_dvec = datevec(PARAMS.plot.dnum) + [0 0 0 0 0 cx];
            elseif length(rtime) > 1
                
                for i=1:length(rtime)
                    if cx < rtime{i}
                        dnum = PARAMS.raw.dnumStart(PARAMS.raw.currentIndex + i-1);
                        ctime_dvec = datevec(dnum) + [0 0 0 0 0 cx-rtime{i-1}];
                        break
                    elseif i == length(rtime)
                        dnum = PARAMS.raw.dnumStart(PARAMS.raw.currentIndex + length(rtime));
                        ctime_dvec = datevec(dnum) + [0 0 0 0 0 cx-rtime{length(rtime)}];
                    end
                end
            else
                dnum = PARAMS.raw.dnumStart(PARAMS.raw.currentIndex + 1);
                ctime_dvec = datevec(dnum) + [0 0 0 0 0 cx-rtime{1}];
            end
            HHMMSS = timestr(ctime_dvec,4);
            mmmuuu = timestr(ctime_dvec,5);

            %
            set(HANDLES.coord.bg,'Visible','on');
            set(HANDLES.coord.txt1,'String',HHMMSS);
            set(HANDLES.coord.txt1b,'String',mmmuuu);
            set(HANDLES.coord.lbl1,'Visible','on');
            set(HANDLES.coord.lbl1b,'Visible','on');
            set(HANDLES.coord.txt1,'Visible','on');
            set(HANDLES.coord.txt1b,'Visible','on');
            set(HANDLES.coord.lbl2,'Visible','on');
            set(HANDLES.coord.txt2,'Visible','on');
            set(HANDLES.coord.lbl3,'Visible','off');
            set(HANDLES.coord.txt3,'Visible','off');
            set(HANDLES.coord.txt2,'String',num2str(round(cy),'%d'));
            set(HANDLES.coord.lbl2,'String','Counts');
        end
    end

    if spvalue % spectra
        if gco == HANDLES.subplt.spectra | gco == HANDLES.plt.spectra
            set(HANDLES.coord.bg,'Visible','on');
            set(HANDLES.coord.lbl1,'Visible','off');
            set(HANDLES.coord.txt1,'Visible','off');
            set(HANDLES.coord.lbl1b,'Visible','off');
            set(HANDLES.coord.txt1b,'Visible','off');
            set(HANDLES.coord.lbl2,'Visible','on');
            set(HANDLES.coord.txt2,'Visible','on');
            set(HANDLES.coord.lbl3,'Visible','on');
            set(HANDLES.coord.txt3,'Visible','on');
            set(HANDLES.coord.txt2,'String',num2str(round(cx),'%d'));
            set(HANDLES.coord.lbl2,'String',{'Freq';' [Hz] '});
            set(HANDLES.coord.txt3,'String',num2str(cy,'%0.1f'));
        end
    end

    if sgvalue% spectrogram
        if gco == HANDLES.subplt.specgram | gco == HANDLES.plt.specgram...
                | gco == HANDLES.delimit.sgline

            % time from beginning of plot to delimitor line [seconds]
            rtime{1} = (PARAMS.raw.dnumEnd(PARAMS.raw.currentIndex) - PARAMS.plot.dnum)...
                * 60 *60 * 24;
            rint = 1;
            flag = 0;
            if ~isempty(PARAMS.xhd.byte_length)
                timer = 0;
                % if multiple raw files are on screen
                while flag == 0
                    timer = PARAMS.xhd.byte_length(rint) + timer;
                    r = (timer/(PARAMS.tseg.sec*PARAMS.xhd.ByteRate(1)))*PARAMS.tseg.sec;
                    if timer < PARAMS.tseg.sec*PARAMS.xhd.ByteRate(1)
                        rtime{rint} = r;
                    else
                        flag = 1;
                    end
                    rint = rint +1;
                end
            else
                while flag == 0
                    r =(PARAMS.raw.dnumEnd(PARAMS.raw.currentIndex - 1 + rint) - PARAMS.plot.dnum)...
                    * 60 *60 * 24;
                    if r < PARAMS.tseg.sec
                        rtime{rint} = r;
                    else
                        flag = 1;
                    end
                    rint = rint +1;
                end
            end
            % convert x location into time for xwav
            if cx < rtime{1}
                ctime_dvec = datevec(PARAMS.plot.dnum) + [0 0 0 0 0 cx];
            % if there are multiple .rar files on screen then check which
            % rar file is it in between
            elseif length(rtime) > 1
                
                for i=1:length(rtime)
                    if cx < rtime{i}
                        dnum = PARAMS.raw.dnumStart(PARAMS.raw.currentIndex + i-1);
                        ctime_dvec = datevec(dnum) + [0 0 0 0 0 cx-rtime{i-1}];
                        break
                    elseif i == length(rtime)
                        dnum = PARAMS.raw.dnumStart(PARAMS.raw.currentIndex + length(rtime));
                        ctime_dvec = datevec(dnum) + [0 0 0 0 0 cx-rtime{length(rtime)}];
                    end
                end
            else
                dnum = PARAMS.raw.dnumStart(PARAMS.raw.currentIndex + 1);
                ctime_dvec = datevec(dnum) + [0 0 0 0 0 cx-rtime{1}];
            end
            HHMMSS = timestr(ctime_dvec,4);
            mmmuuu = timestr(ctime_dvec,5);


            set(HANDLES.coord.bg,'Visible','on');
            set(HANDLES.coord.txt1,'String',HHMMSS);
            set(HANDLES.coord.txt1b,'String',mmmuuu);
            set(HANDLES.coord.lbl1,'Visible','on');
            set(HANDLES.coord.lbl1b,'Visible','on');
            set(HANDLES.coord.txt1,'Visible','on');
            set(HANDLES.coord.txt1b,'Visible','on');
            set(HANDLES.coord.lbl2,'Visible','on');
            set(HANDLES.coord.txt2,'Visible','on');
            set(HANDLES.coord.lbl3,'Visible','on');
            set(HANDLES.coord.txt3,'Visible','on');
            set(HANDLES.coord.txt2,'String',num2str(round(cy),'%d'))
            set(HANDLES.coord.lbl2,'String',{'Freq';' [Hz] '});
            if length(PARAMS.t) > 1
                dt = PARAMS.t(2)-PARAMS.t(1);	%sec/pixel
                cp(1) = floor((cx+dt/2)/dt) + 1 ;
            else
                cp(1) = 1;
            end
            df = PARAMS.f(2)-PARAMS.f(1);	%hz/pixel???
            %   cp(2) = floor((cy+df/2)/df);
            cp(2) = floor((cy - PARAMS.f(1) +df/2)/df)+1;
            szpwr = size(PARAMS.pwr);
            if (cp(1)>= 1 & cp(1) <= szpwr(2)) ...
                    & (cp(2) >= 1 & cp(2) <= szpwr(1))
                pwr = PARAMS.pwr(cp(2),cp(1));
                set(HANDLES.coord.txt3,'String',num2str(pwr,'%0.1f'));
                set(HANDLES.coord.lbl3,'String','S Level [dB]');
            end
        end
    end

    if savalue % long term spectral average
        if (ishandle(HANDLES.subplt.ltsa) & gco == HANDLES.subplt.ltsa) | ...
                (ishandle(HANDLES.plt.ltsa) & gco == HANDLES.plt.ltsa)

            set(HANDLES.ltsa.coord.bg,'Visible','on');
            set(HANDLES.ltsa.coord.lbl1,'Visible','on');
            set(HANDLES.ltsa.coord.txt1,'Visible','on');
            set(HANDLES.ltsa.coord.lbl1b,'Visible','on');
            set(HANDLES.ltsa.coord.txt1b,'Visible','on');
            set(HANDLES.ltsa.coord.lbl2,'Visible','on');
            set(HANDLES.ltsa.coord.txt2,'Visible','on');
            set(HANDLES.ltsa.coord.lbl3,'Visible','on');
            set(HANDLES.ltsa.coord.txt3,'Visible','on')

            % ctime_dnum = PARAMS.ltsa.plot.dnum + cx / 24;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
            %
            % new ltsa timing stuff 060514 smw:
            [rawIndex,tBin] = getIndexBin(cx);
            % disp_msg([num2str(rawIndex),'  ',num2str(tBin)])

            tbinsz = PARAMS.ltsa.tave / (60*60);

            % cursor time in days (add one tBin to have 1st bin at zero
            ctime_dnum = PARAMS.ltsa.dnumStart(rawIndex) + (tBin - 0.5) * tbinsz /24;
            % disp_msg([num2str(ctime_dnum),'  ',num2str(tBin)])


            set(HANDLES.ltsa.coord.txt1,'String',timestr(ctime_dnum,3));
            set(HANDLES.ltsa.coord.txt1b,'String',timestr(ctime_dnum,4));

            set(HANDLES.ltsa.coord.txt2,'String',num2str(round(cy),'%d'))

            if length(PARAMS.ltsa.t) > 1
                dt = PARAMS.ltsa.t(2)-PARAMS.ltsa.t(1);	%sec/pixel
                cp(1) = floor((cx+dt/2)/dt) + 1 ;
            else
                cp(1) = 1;
            end
            df = PARAMS.ltsa.f(2)-PARAMS.ltsa.f(1);	%hz/pixel???
            %   cp(2) = floor((cy+df/2)/df);
            cp(2) = floor((cy - PARAMS.ltsa.f(1) +df/2)/df)+1;
            szpwr = size(PARAMS.ltsa.pwr);
            if (cp(1)>= 1 & cp(1) <= szpwr(2)) ...
                    & (cp(2) >= 1 & cp(2) <= szpwr(1))
                pwr = PARAMS.ltsa.pwr(cp(2),cp(1));
                set(HANDLES.ltsa.coord.txt3,'String',num2str(pwr,'%0.1f'));
            end
        end
    end

catch exception
    if strcmp(exception.identifier, 'MATLAB:nonExistentField')
        return
    else
        throw(exception);
    end
end
        

