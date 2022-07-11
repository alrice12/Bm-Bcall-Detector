function mk_ltsa
%
% make long-term spectral averages from XWAV files in a directory
%
% 060612 smw
%
global PARAMS HANDLES

% initialize ltsa parameters
init_ltsaparams

% get directory
get_ltsadir

if PARAMS.ltsa.gen == 0
    disp_msg('Canceled making ltsa')
    return
end

% read data file headers
get_headers

% get ltsa parameters from user 
get_ltsaparams

% check some ltsa parameter and other stuff:
ck_ltsaparams

% setup lsta file header + directory listing
write_ltsahead

if PARAMS.ltsa.gen == 0
    disp_msg('Canceled making ltsa')
    return
end
% calculated averaged spectra
calc_ltsa

% might as well plot it up:


initparams
PARAMS.ltsa.infile = PARAMS.ltsa.outfile;
PARAMS.ltsa.inpath = PARAMS.ltsa.outdir;

    set(HANDLES.display.ltsa,'Visible','on')
    set(HANDLES.display.ltsa,'Value',1);
    set(HANDLES.ltsa.equal,'Visible','on')
    control_ltsa('button')
    set([HANDLES.ltsa.motion.seekbof HANDLES.ltsa.motion.back HANDLES.ltsa.motion.autoback HANDLES.ltsa.motion.stop],...
        'Enable','off');
    init_ltsadata
    read_ltsadata
    %
    % need some sort of reset here on graphics and opened xwav file
    % 060802smw
    %
    plot_triton
    control_ltsa('timeon')   % was timecontrol(1)
    % turn on other menus now
    control_ltsa('menuon')
    %control_ltsa('button')
    control_ltsa('ampon')
    control_ltsa('freqon')
    %set([HANDLES.ltsa.motion.seekbof HANDLES.ltsa.motion.back HANDLES.ltsa.motion.autoback HANDLES.ltsa.motion.stop],...
    %    'Enable','off');
    set(HANDLES.ltsa.motioncontrols,'Visible','on')
    % turns on radio button
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');

%
% disp(PARAMS.ltsa)

disp('done - go home now')

