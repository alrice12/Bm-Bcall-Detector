function motion_ltsa(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% motion_ltsa.m
%
% control motion of plot windown with push buttons in control window
%
%
% ripped off from triton v1.50 (motion.m)
% smw 050117 - 060227
%
% LTSA triton v1.61 smw 060524
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS HANDLES

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if strcmp(action,'forward')
    %
    % forward button
    %
    % plot next frame
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PARAMS.ltsa.save.dnum = PARAMS.ltsa.plot.dnum;
    if PARAMS.ltsa.tseg.step ~= -1 & PARAMS.ltsa.tseg.step ~= -2
        PARAMS.ltsa.plot.dnum = PARAMS.ltsa.plot.dnum + datenum([0 0 0 PARAMS.ltsa.tseg.step 0 0]);
    elseif PARAMS.ltsa.tseg.step == -2
        PARAMS.ltsa.plot.dnum = PARAMS.ltsa.plot.dnum + datenum([0 0 0 PARAMS.ltsa.tseg.hr 0 0]);
    elseif PARAMS.ltsa.tseg.step == -1
        stepPlotTimeLTSA('f')
    end
    read_ltsadata
    plot_triton
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'back')
    %
    % back button
    %
    % plot previous frame
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PARAMS.ltsa.save.dnum = PARAMS.ltsa.plot.dnum;
    if PARAMS.ltsa.tseg.step ~= -1 & PARAMS.ltsa.tseg.step ~= -2
        PARAMS.ltsa.plot.dnum = PARAMS.ltsa.plot.dnum - datenum([0 0 0 PARAMS.ltsa.tseg.step 0 0]);
    elseif PARAMS.ltsa.tseg.step == -2
        PARAMS.ltsa.plot.dnum = PARAMS.ltsa.plot.dnum - datenum([0 0 0 PARAMS.ltsa.tseg.hr 0 0]);
    elseif PARAMS.ltsa.tseg.step == -1
        stepPlotTimeLTSA('b')
    end
    read_ltsadata
    plot_triton
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'autof')
    %
    % autof button - plot next frame
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % turn off menus and buttons while autorunning
    control_ltsa('menuoff');
    control_ltsa('buttoff');

    % turn Stop button back on
    set(HANDLES.ltsa.motion.stop,'Userdata',1);	% turn on while loop condition
    set(HANDLES.ltsa.motion.stop,'Enable','on');	% turn on the Stop button
    while (get(HANDLES.ltsa.motion.stop,'Userdata') == 1)
        motion_ltsa('forward')
        if PARAMS.aptime ~= 0
         pause(PARAMS.ltsa.aptime);
        end		
    end
    % turn buttons and menus back on
    control_ltsa('menuon')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'autob')
    %
    % autob button - plot previous frame
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % turn off menus and buttons while autorunning
    control_ltsa('menuoff');
    control_ltsa('buttoff');
    % turn Stop button back on
    set(HANDLES.ltsa.motion.stop,'Userdata',1);	% turn on while loop condition
    set(HANDLES.ltsa.motion.stop,'Enable','on');	% turn on the Stop button
    while (get(HANDLES.ltsa.motion.stop,'Userdata') == 1)
        motion_ltsa('back')	% step back one frame
        if PARAMS.aptime ~= 0
         pause(PARAMS.ltsa.aptime); % wait (needed on fast machines)
        end				
    end
    % turn menus back on
    control_ltsa('menuon')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'stop')
    %
    % stop button - keep current frame
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.ltsa.motion.stop,'Userdata',-1)
    control_ltsa('button')
    control_ltsa('menuon')
    set(HANDLES.ltsa.motion.stop,'Enable','off');	% turn off Stop button
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
elseif strcmp(action,'seekbof')
    %
    % goto beginning of file button - plot first frame
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    PARAMS.ltsa.plot.dnum = PARAMS.ltsa.start.dnum;
    read_ltsadata
    plot_triton
    set(HANDLES.ltsa.motion.seekbof,'Enable','off');
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(action,'seekeof')
    %
    % goto end of file button - plot last frame
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    if PARAMS.ltsa.tseg.step == -2
        PARAMS.ltsa.plot.dnum = PARAMS.ltsa.end.dnum - datenum([0 0 0 PARAMS.ltsa.tseg.hr 0 0]);
        %     disp_msg(['plot.dnum= ',num2str(PARAMS.ltsa.plot.dnum)])
    elseif PARAMS.ltsa.tseg.step == -1
        % total number of time bins to plot
        tbin = floor((PARAMS.ltsa.tseg.hr * 60 *60 ) / PARAMS.ltsa.tave);
        cbin = 0;
        k = PARAMS.ltsa.nrftot+1;
        % count rawfile Indices backwards 
        while cbin < tbin
            k = k - 1;
            cbin = cbin + PARAMS.ltsa.nave(k);
        end
        sbin = cbin - tbin;

        PARAMS.ltsa.plotStartBin = sbin;
        PARAMS.ltsa.plotStartRawIndex = k;
        PARAMS.ltsa.plot.dnum = PARAMS.ltsa.dnumStart(PARAMS.ltsa.plotStartRawIndex)+ ...
            (PARAMS.ltsa.plotStartBin * PARAMS.ltsa.tave) / (60 * 60 * 24);

        %PARAMS.ltsa.plot.dnum = PARAMS.ltsa.end.dnum - datenum([0 0 0 PARAMS.ltsa.tseg.hr 0 0]);
    end
    read_ltsadata
    plot_triton
    set(HANDLES.ltsa.motion.seekeof,'Enable','off');
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end;
