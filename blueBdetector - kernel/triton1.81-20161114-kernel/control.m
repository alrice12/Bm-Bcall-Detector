function control(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% control.m
%
% toggle on/off control window pull-down menus and buttons
% set and implement newtime, newtseg, newstep,coordinate display
%
% 5/5/04 smw
%
% 050513 smw heavily revised
%
% 060205 - 060227 smw modified for v1.60
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global HANDLES PARAMS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if strcmp(action,'buttoff')
    %
    % turn off buttons and menues (during picks)
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.motioncontrols,'Enable','off');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'button')
    %
    % turn on buttons and menues (after picks)
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.motioncontrols,'Enable','on');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'menuon')
    %
    % turn on  and menues (after picks)
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set([HANDLES.filemenu HANDLES.saveas HANDLES.saveasxwav HANDLES.savejpg HANDLES.savefigureas HANDLES.toolmenu  ...
        HANDLES.parametersmenu],...
        'Enable','on');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'menuoff')
    %
    % turn off buttons and menues (during picks)
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set([HANDLES.filemenu HANDLES.toolmenu HANDLES.parametersmenu],...
        'Enable','off');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % time stuff in control window
elseif strcmp(action,'timeon')
    %
    % turn on time controls
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.timecontrols,'Visible','on');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'timeoff')
    % turn off time controls
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.timecontrols,'Visible','off');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % amp stuff in control window
elseif strcmp(action,'ampon')
    % turn on amplitude controls
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.ampcontrols,'Visible','on');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'ampoff')
    % turn off amplitude controls
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.ampcontrols,'Visible','off');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % frequency stuff in control window
elseif strcmp(action,'freqon')
    % turn on frequency controls
    set(HANDLES.freqcontrols,'Visible','on');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'freqoff')
    % turn off frequency controls
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.freqcontrols,'Visible','off');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % log stuff control window
elseif strcmp(action,'logon')
    % turn on logfile radiobuttons
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    set(HANDLES.logcontrols,'Visible','on');
    set(HANDLES.logcontrols,'Value',0);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'logoff')
    % turn off logfile radiobuttons
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.logcontrols,'Visible','off');
    set(HANDLES.logcontrols,'Value',0);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'newtime1')
    %
    % plot with new time
    % mm/dd/yyyyy
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    tstr = get(HANDLES.time.edtxt1,'String');
    PARAMS.save.dnum = PARAMS.plot.dnum;
    PARAMS.save.dvec = PARAMS.plot.dvec;
    PARAMS.plot.dnum = timenum([get(HANDLES.time.edtxt1,'String'),' ',...
        get(HANDLES.time.edtxt2,'String'),'.',...
        get(HANDLES.time.edtxt3,'String')],1);
    PARAMS.plot.dvec = datevec(PARAMS.plot.dnum);
    readseg
    if ~isempty(PARAMS.xhd.byte_length)
        rtime =(PARAMS.raw.dnumEnd(PARAMS.raw.currentIndex) - PARAMS.plot.dnum)...
        * 60 *60 * 24;
        stime =(PARAMS.start.dnum - PARAMS.plot.dnum)* 60 *60 * 24;
        if rtime >= stime
            PARAMS.plot.bytelength = PARAMS.plot.bytelength + (rtime - stime)*PARAMS.xhd.ByteRate(1); 
        elseif stime < rtime
            PARAMS.plot.bytelength = PARAMS.plot.bytelength + (stime - rtime)*PARAMS.xhd.ByteRate(1);
        end
    end
    plot_triton
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    % the following give focus to the uicontrol obj just used (ver>=7.0)
    uicontrol(HANDLES.time.edtxt1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'newtime2')
    %
    % plot with new time
    % HH:MM:SS
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    tstr = get(HANDLES.time.edtxt2,'String');
    PARAMS.save.dnum = PARAMS.plot.dnum;
    PARAMS.save.dvec = PARAMS.plot.dvec;
    PARAMS.plot.dnum = timenum([get(HANDLES.time.edtxt1,'String'),' ',...
        get(HANDLES.time.edtxt2,'String'),'.',...
        get(HANDLES.time.edtxt3,'String')],1);
    PARAMS.plot.dvec = datevec(PARAMS.plot.dnum);
    readseg
    plot_triton
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    % the following give focus to the uicontrol obj just used (ver>=7.0)
    uicontrol(HANDLES.time.edtxt2)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'newtime3')
    %
    % plot with new time
    % mmm.sss
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    PARAMS.save.dnum = PARAMS.plot.dnum;
    PARAMS.save.dvec = PARAMS.plot.dvec;
    if strcmp(get(HANDLES.time.edtxt3,'String'),'0')    % allow 0 instead of having to type 000.000
        PARAMS.plot.dnum = timenum([get(HANDLES.time.edtxt1,'String'),' ',...
            get(HANDLES.time.edtxt2,'String')],6);
    else
        PARAMS.plot.dnum = timenum([get(HANDLES.time.edtxt1,'String'),' ',...
            get(HANDLES.time.edtxt2,'String'),'.',...
            get(HANDLES.time.edtxt3,'String')],1);
    end
    PARAMS.plot.dvec = datevec(PARAMS.plot.dnum);
    readseg
    plot_triton
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    % the following give focus to the uicontrol obj just used (ver>=7.0)
    uicontrol(HANDLES.time.edtxt3)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'newtseg')
    %
    % plot with new time segment (Plot Length)
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    tseg = str2num(get(HANDLES.time.edtxt4,'String'));
    if tseg < 2/PARAMS.fs;
        disp_msg('Error: Duration too small')
        %         set(HANDLES.time.edtxt4,'String',num2str(PARAMS.tseg.sec));
    elseif PARAMS.end.dnum < (PARAMS.plot.dnum + datenum([0 0 0 0 0 tseg]))
        disp_msg('Error: Plot Length too Long')
        if PARAMS.plot.dnum == PARAMS.start.dnum    % beginning of file
            disp_msg('Set Plot Length to Files Size')
            PARAMS.tseg.sec = floor((PARAMS.end.dnum - PARAMS.start.dnum)...
                * (24 * 60 * 60));
            if ~isempty(PARAMS.xhd.byte_length)
                etime = 0;
                for r=1:length(PARAMS.xhd.byte_length)
                    etime = etime + PARAMS.xhd.byte_length(r)/PARAMS.xhd.ByteRate;
                end
                
                if etime < PARAMS.tseg.sec
                    PARAMS.tseg.sec = etime;
                end
            end
        else
            disp_msg('Set Plot Length to End of File')
            PARAMS.tseg.sec = floor((PARAMS.end.dnum - PARAMS.plot.dnum)...
                * (24 * 60 * 60));
        end
    else
        PARAMS.tseg.sec = tseg;
        if ~isempty(PARAMS.xhd.byte_length)
                etime = 0;
                for r=1:length(PARAMS.xhd.byte_length)
                    etime = etime + PARAMS.xhd.byte_length(r)/PARAMS.xhd.ByteRate;
                end
                
                if etime < PARAMS.tseg.sec
                    PARAMS.tseg.sec = etime;
                end
            end
    end
    set(HANDLES.time.edtxt4,'String',num2str(PARAMS.tseg.sec));
    readseg
    plot_triton
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    % the following give focus to the uicontrol obj just used (ver>=7.0)
    uicontrol(HANDLES.time.edtxt4)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'newtstep')
    %
    % plot with new time step
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PARAMS.tseg.step = str2num(get(HANDLES.time.edtxt5,'String'));
    if PARAMS.tseg.step < 0 & PARAMS.tseg.step ~= -1 & PARAMS.tseg.step ~= -2
        disp_msg('Error: Incorrect Step Size')
        PARAMS.tseg.step = -1;
        set(HANDLES.time.edtxt5,'String',num2str(PARAMS.tseg.step));
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'delay')
    %
    % delay between auto displays
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % time delay between Auto Display
    delay= str2num(get(HANDLES.time.edtxt6,'String'));
    maxdelay = 10;
    mindelay = 0;
    if maxdelay < delay
        disp_msg(['Error: Delay greater than ' num2str(maxdelay) ' seconds!'])
        PARAMS.cancel = 1;
        return
    elseif delay < mindelay
        disp_msg(['Error: Delay shorter than ' num2str(mindelay) ' seconds?'])
        PARAMS.cancel = 1;
        return
    elseif delay <= maxdelay & delay >= mindelay
        PARAMS.aptime = delay;
    else
        PARAMS.cancel = 1;
        disp_msg('Error: Unknown amount')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'coorddisp')
    %
    % show new cursor location
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    coorddisp
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'setcmapjet')
    %
    % set color map to jet
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PARAMS.cmap = 'jet';
    figure(HANDLES.fig.main)
    colormap(PARAMS.cmap)
    figure(HANDLES.fig.ctrl)
    set(HANDLES.amp.cmapcontrol,'Value',0)
    set(HANDLES.amp.cmapjet,'Value',1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'setcmapgray')
    %
    % set color map to gray
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PARAMS.cmap = 'gray';
    figure(HANDLES.fig.main)
    % make negative colormap ie dark is big amp
    g = gray;
    szg = size(g);
    cmap = g(szg:-1:1,:);
    colormap(cmap)
    figure(HANDLES.fig.ctrl)
    set(HANDLES.amp.cmapcontrol,'Value',0)
    set(HANDLES.amp.cmapgray,'Value',1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'setcmapcool')
    %
    % set color map to cool
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PARAMS.cmap = 'cool';
    figure(HANDLES.fig.main)
    colormap(PARAMS.cmap)
    figure(HANDLES.fig.ctrl)
    set(HANDLES.amp.cmapcontrol,'Value',0)
    set(HANDLES.amp.cmapcool,'Value',1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'setcmaphot')
    %
    % set color map to hot
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PARAMS.cmap = 'hot';
    figure(HANDLES.fig.main)
    colormap(PARAMS.cmap)
    figure(HANDLES.fig.ctrl)
    set(HANDLES.amp.cmapcontrol,'Value',0)
    set(HANDLES.amp.cmaphot,'Value',1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'ampadj')
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    brsld = get(HANDLES.amp.brsld,'Value');
    bredt = str2num(get(HANDLES.amp.bredt,'String'));
    consld = get(HANDLES.amp.consld,'Value');
    conedt = str2num(get(HANDLES.amp.conedt,'String'));
    if bredt ~= PARAMS.bright
        PARAMS.bright = bredt;
    elseif brsld ~= PARAMS.bright
        PARAMS.bright = round(brsld);
    end
    set(HANDLES.amp.bredt,'String',num2str(PARAMS.bright));
    set(HANDLES.amp.brsld,'Value',PARAMS.bright);
    if conedt ~= PARAMS.contrast
        PARAMS.contrast = conedt;
    elseif consld ~= PARAMS.contrast
        PARAMS.contrast = round(consld);
    end
    set(HANDLES.amp.consld,'Value',PARAMS.contrast)
    set(HANDLES.amp.conedt,'String',num2str(PARAMS.contrast))

    % check and apply/remove spectrogram equalization:
    state = get(HANDLES.sgeq.tog,'Value');
    if state == get(HANDLES.sgeq.tog,'Max')
        set(HANDLES.sgeq.tog,'String','ON')
        sg = PARAMS.pwr - mean(PARAMS.pwr,2) * ones(1,length(PARAMS.t));
    elseif state == get(HANDLES.sgeq.tog,'Min')
        set(HANDLES.sgeq.tog,'String','OFF')
        sg = PARAMS.pwr;
    end


    %c = (1 + PARAMS.contrast/100).* PARAMS.pwr + PARAMS.bright;
    %     c = (PARAMS.contrast/100) .* PARAMS.pwr + PARAMS.bright;
    c = (PARAMS.contrast/100) .* sg + PARAMS.bright;
    %         c = (PARAMS.contrast/100) .* (PARAMS.pwr + PARAMS.bright);
    set(HANDLES.BC,'String',['B = ',num2str(PARAMS.bright),', C = ',num2str(PARAMS.contrast)]);
    %
    if PARAMS.fax == 0
        set(HANDLES.plt.specgram,'CData',c)
    elseif PARAMS.fax == 1
        flen = length(PARAMS.f);
        [M,N] = logfmap(flen,4,flen);
        c = M*c;
        %         f = M*PARAMS.f;
        %         HANDLES.plt = image(PARAMS.t,f,c);
        %         set(get(HANDLES.plt,'Parent'),'YScale','log');
        set(HANDLES.plt.specgram,'CData',c)
    end
    % adjust colorbar
    minc = min(min(c));
    maxc = max(max(c));
    %difc = floor(maxc-minc / 100);
    difc = 2;
    %
    minp = min(min(PARAMS.pwr));
    maxp = max(max(PARAMS.pwr));
    %
    set(PARAMS.cb,'YLim',[minp maxp])
    % image (child of colorbar)
    PARAMS.cbb = findobj(get(PARAMS.cb, 'Children'), 'Type', 'image');
    set(PARAMS.cbb,'CData',[minc:difc:maxc]')
    set(PARAMS.cbb,'YData',[minp maxp])
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'newstfreq')
    %
    % Start Frequency
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    f0 = str2num(get(HANDLES.stfreq.edtxt,'String'));
    if f0 >= PARAMS.freq1
        disp_msg('Freq larger than End Freq :')
        disp_msg(num2str(PARAMS.freq1))
        PARAMS.cancel = 1;
        set(HANDLES.stfreq.edtxt,'String',PARAMS.freq0);
        return
    elseif f0 < 0
        disp_msg('Freq smaller than Min Freq :')
        disp_msg('0')
        PARAMS.cancel = 1;
        set(HANDLES.stfreq.edtxt,'String',PARAMS.freq0);
        return
    elseif length(f0) == 0
        disp_msg('Wrong format')
        PARAMS.cancel = 1;
        set(HANDLES.stfreq.edtxt,'String',PARAMS.freq0);
        return
    else
        PARAMS.freq0 = f0;
        if PARAMS.cancel ~= 1
            plot_triton
        else
            PARAMS.cancel = 0;
        end
    end
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    % the following give focus to the uicontrol obj just used (ver>=7.0)
    uicontrol(HANDLES.stfreq.edtxt)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'newendfreq')
    %
    % End Frequency
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    f1 = str2num(get(HANDLES.endfreq.edtxt,'String'));
    if f1 <= PARAMS.freq0
        disp_msg('Freq smaller than Start Freq :')
        disp_msg(num2str(PARAMS.freq0))
        PARAMS.cancel = 1;
        set(HANDLES.endfreq.edtxt,'String',PARAMS.freq1);
        set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
        return
    elseif f1 > PARAMS.fmax
        disp_msg('Freq greater than Max Freq :')
        disp_msg(num2str(PARAMS.fmax))
        PARAMS.cancel = 1;
        set(HANDLES.endfreq.edtxt,'String',PARAMS.freq1);
        set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
        return
    elseif length(f1) == 0
        disp_msg('Wrong format')
        PARAMS.cancel = 1;
        set(HANDLES.endfreq.edtxt,'String',PARAMS.freq1);
        set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
        return
    else
        PARAMS.freq1 = f1;
        if PARAMS.cancel ~= 1
            plot_triton
        else
            PARAMS.cancel = 0;
        end
    end
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    % the following give focus to the uicontrol obj just used (ver>=7.0)
    uicontrol(HANDLES.endfreq.edtxt)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'setspec')
    %
    % Set Spectral Parameters
    %
    sgco=gco;
    % FFT length
    PARAMS.nfft=str2num(get(HANDLES.specnfft.edtxt,'String'));
    % FFT overlap
    PARAMS.overlap=str2num(get(HANDLES.specol.edtxt,'String'));
    if PARAMS.cancel ~= 1
        plot_triton
    else
        PARAMS.cancel = 0;
    end
    if sgco == HANDLES.specnfft.edtxt
        % the following give focus to the uicontrol obj just used (ver>=7.0)
        uicontrol(HANDLES.specnfft.edtxt)
    elseif sgco == HANDLES.specol.edtxt
        % the following give focus to the uicontrol obj just used (ver>=7.0)
        uicontrol(HANDLES.specol.edtxt)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'filton')
    %
    % toggle filter on with radio button
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PARAMS.filter = 1;
    set(HANDLES.filtradios,'Value',0)
    set(HANDLES.filt.rad1,'Value',1)
    control('filtdata')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'filtoff')
    %
    % toggle filter on with radio button
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PARAMS.filter = 0;
    set(HANDLES.filtradios,'Value',0)
    set(HANDLES.filt.rad2,'Value',1)
    readseg
    plot_triton
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'filtdata')
    %
    % Filter Data
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sgco=gco;
    pflag = 0;
    if PARAMS.filter == 1
        % start Frequency
        f0 = str2num(get(HANDLES.filt.edtxt1,'String'));
        if f0 >= PARAMS.freq1
            disp_msg('Freq larger than End Freq :')
            disp_msg(num2str(PARAMS.freq1))
            PARAMS.cancel = 1;
            return
        elseif f0 < 0
            disp_msg('Freq smaller than Min Freq :')
            disp_msg('0')
            PARAMS.cancel = 1;
            return
        elseif length(f0) == 0
            disp_msg('Wrong format')
            PARAMS.cancel = 1;
            return
        else
            PARAMS.ff1 = f0;
        end
        % End Freq
        f1 = str2num(get(HANDLES.filt.edtxt2,'String'));
        if f1 <= PARAMS.freq0
            disp_msg('Freq smaller than Start Freq :')
            disp_msg(num2str(PARAMS.freq0))
            PARAMS.cancel = 1;
            return
        elseif f1  > PARAMS.fmax * 0.999
            disp_msg('High End Freq too Large for Bandpass')
            disp_msg('Set to Max for Filter :')
            PARAMS.ff2 = PARAMS.fmax * 0.999;
            disp_msg(num2str(PARAMS.ff2))
            set(HANDLES.filt.edtxt2,'String',num2str(PARAMS.ff2));
%             PARAMS.cancel = 1;
%             return
        elseif length(f1) == 0
            disp_msg('Wrong format')
            PARAMS.cancel = 1;
            return
        else
            PARAMS.ff2 = f1;
        end
        pflag = 1;
    end

    if pflag == 1
        readseg
        plot_triton
        if sgco == HANDLES.filt.edtxt1
            % the following give focus to the uicontrol obj just used (ver>=7.0)
            uicontrol(HANDLES.filt.edtxt1)
        elseif sgco == HANDLES.filt.edtxt2
            % the following give focus to the uicontrol obj just used (ver>=7.0)
            uicontrol(HANDLES.filt.edtxt2)
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'faxlinear')
    %
    % Freq Axis linear
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.faxcontrol,'Value',0);
    set(HANDLES.fax.linear,'Value',1);
    PARAMS.fax = 0;
    plot_triton
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'faxlog')
    %
    % Freq Axis log
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.faxcontrol,'Value',0);
    set(HANDLES.fax.log,'Value',1);
    PARAMS.fax = 1;
    plot_triton
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'TFon')
    %
    % Transfer Function ON
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.tfradios,'Value',0);
    set(HANDLES.tf.rad1,'Value',1);
    PARAMS.tf.flag = 1;
    plot_triton
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'TFoff')
    %
    % Transfer Function OFF
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.tfradios,'Value',0);
    set(HANDLES.tf.rad2,'Value',1);
    PARAMS.tf.flag = 0;
    plot_triton

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'setchan')
    %
    % Set Channel number
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ch = get(HANDLES.ch.pop,'Value');
    PARAMS.ch = ch;
    readseg
    plot_triton
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'toggleSGEqual')
    %
    % Push button Pick time to average spectrogram equalization
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    state1 = get(HANDLES.sgeq.tog,'Value');
    if state1 == get(HANDLES.sgeq.tog,'Max')
        set(HANDLES.sgeq.tog,'String','ON')
    elseif state1 == get(HANDLES.sgeq.tog,'Min')
        set(HANDLES.sgeq.tog,'String','OFF')
    end
    plot_triton
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'toggleMean')
    %
    % Toggle Spectrogram Equalization Pick and Full Mean
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    state1 = get(HANDLES.sgeq.tog,'Value');
    state2 = get(HANDLES.sgeq.tog2,'Value');
    if state2 == get(HANDLES.sgeq.tog2,'Max') & ...
            state1 == get(HANDLES.sgeq.tog,'Max')
        set(HANDLES.sgeq.tog2,'String','Pick')
        figure(HANDLES.fig.main)
        [t,f] = ginput(2);
        dt = PARAMS.t(2)-PARAMS.t(1);	%sec/pixel
        x = floor((t+dt/2)./dt) + 1;
        if x(1) > x(2)
            xs = x(1);
            x(1) = x(2);
            x(2) = xs;
        elseif x(1) == x(2)
            x(2) = x(1) + 1;
        end
        PARAMS.mean.save = mean(PARAMS.pwr(:,x(1):x(2)),2) ;
    elseif state2 == get(HANDLES.sgeq.tog2,'Min')
        set(HANDLES.sgeq.tog2,'String','Full')
    end
    plot_triton
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'setspeedFactor')
    %
    % Set Speed Factor for Sound Playback
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    spf = str2num(get(HANDLES.snd.edtxt,'String'));
    if spf > 10 | spf < 0.1
        disp_msg(['Out of Range Sound Playback Speed : ',num2str(spf)])
        disp_msg('Use 0.1 to 10')
        set(HANDLES.snd.edtxt,'String','1')
    else
        PARAMS.speedFactor = spf;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'setVolume')
    %
    % Set Volume for Sound Playback
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PARAMS.sndVol = get(HANDLES.snd.svsld,'Value');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'delimit')
    %
    % Set Delimiter (red line) flag/toggle
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PARAMS.delimit.value = get(HANDLES.delimit.but,'Value');
    plot_triton
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'stopSound')
    %
    % Set Speed Factor for Sound Playback
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.snd.stop,'Userdata',-1)
    set(HANDLES.snd.stop,'Enable','off')
    set(HANDLES.snd.play,'Enable','on')
    plot_triton
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'playSound')
    %
    % Set Speed Factor for Sound Playback
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.snd.stop,'Enable','on')
    set(HANDLES.snd.play,'Enable','off')
    audvidplayer
    plot_triton
end;