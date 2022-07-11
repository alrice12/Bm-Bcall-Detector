function toolpd(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% toolpd.m
%
% Tools pull-down menu operation
%
% 060525 smw v1.61
%
% 5/5/04 smw
%
% 060220 - 060227 smw modified for v1.60
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global HANDLES PARAMS DATA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if strcmp(action,'run_mat')
    disp_msg('This function is not available yet')
    % savepath = pwd;
    % % user interface retrieve file to open through a dialog box
    % boxTitle1 = 'Run MATLAB script';
    % filterSpec1 = '*.m';
    %
    % % cd to default directory (used for quick directory access
    % ipnamesave = PARAMS.inpath;
    % ifnamesave = PARAMS.infile;
    % cd2current_v140;
    %
    % [PARAMS.run_mat,PARAMS.matpath]=uigetfile(filterSpec1,boxTitle1);
    %
    % % if the cancel button is pushed, then no file is loaded so exit this script
    % if strcmp(num2str(PARAMS.infile),'0')
    %     return
    % else % give user some feedback
    %     disp('MATLAB script to run: ')
    %     disp([PARAMS.matpath,PARAMS.run_mat])
    %     disp(' ')
    % end
    %
    % eval(PARAMS.run_mat(1:length(PARAMS.run_mat)-2))
    % cd(savepath)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box
elseif strcmp(action,'dd_list')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp_msg('underconstruction')
    % kinda kludgy, but it works...
    if exist('dd.exe') && ispc
        ddx = which('dd.exe');  % get path and filename
        [status, result] = system([ddx,' --list']);
        disp(result)
        
        % disp_msg(result) % doesn't show newline feeds
        % because of the way disp_msg works on vector of chars
        % the following works
        % C = textscan(result, '%s', 'delimiter', '\n');
        % disp(C{:})
    end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box
elseif strcmp(action,'get_RawDisk')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp_msg('underconstruction')
    findRawDisks
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box
elseif strcmp(action,'get_Rawhead')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp_msg('underconstruction')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box
elseif strcmp(action,'get_Rawdir')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp_msg('underconstruction')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box
elseif strcmp(action,'convert_multiHRP2XWAVS')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    %need a gui input here
    make_multixwav
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box
elseif strcmp(action,'convert_HRP2XWAVS')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    % get HRP input file name
    [fname,fpath]=uigetfile('*.hrp','Select HRP file to convert to XWAVS');
    infilename = [fpath,fname];
    cflag = 0;
    % if the cancel button is pushed
    if strcmp(num2str(fname),'0')
        disp_msg('Cancel button pushed')
        cflag = 1;
    end
    % get HDR XWAV header file name
    [fname,fpath]=uigetfile('*.hdr','Select XWAV Header file');
    hdrfilename = [fpath,fname];
    % if the cancel button is pushed
    if strcmp(num2str(fname),'0')
        disp_msg('Cancel button pushed')
        cflag = 1;
    end
    % get XWAV directory name
    outdir = uigetdir(PARAMS.inpath,'Select Directory to output XWAVs');
    if outdir == 0	% if cancel button pushed
        disp_msg('Cancel button pushed')
        cflag = 1;
    end
    % display obtained names in message window
    disp_msg(['Input FileName = ',infilename])
    disp_msg(['XWAV Header FileName = ',hdrfilename])
    disp_msg(['XWAV DirectoryName = ',outdir])
    d = 1;  % display progress info
    if ~cflag
        write_hrp2xwavs(infilename,hdrfilename,outdir,d)
    end
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box
elseif strcmp(action,'get_HRPhead')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    % need gui input here
    d = 1;      % d=1: display output to command window
    [fname,fpath]=uigetfile('*.hrp','Select HRP file to read disk Header');
    filename = [fpath,fname];
    % if the cancel button is pushed, then no file is loaded so exit this script
    if strcmp(num2str(fname),'0')
        return
    else % get raw HARP disk header
        read_rawHARPhead(filename,d)
    end

    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box
elseif strcmp(action,'get_HRPdir')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    d = 1;      % d=1: display output to command window
    [fname,fpath]=uigetfile('*.hrp','Select HRP file to read disk Directory');
    filename = [fpath,fname];
    % if the cancel button is pushed, then no file is loaded so exit this script
    if strcmp(num2str(fname),'0')
        return
    else % get raw HARP disk directory
        read_rawHARPdir(filename,d)
    end
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box
elseif strcmp(action,'ck_dirlist_times')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    
    check_dirlist_times
    
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box
elseif strcmp(action,'plotSectorTimes')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    
    plot_hrpSectorTimes
    
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box edit header psds file
elseif strcmp(action,'editpsds')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    % editHeader_ltsa
    disp_msg('this function is not currently available')
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box view header xwav file
elseif strcmp(action,'viewxwavhd')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    viewHeader_xwav
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box edit header xwav file
elseif strcmp(action,'editxwavhd')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    editHeader_xwav
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box convertfile into a file
elseif strcmp(action,'convertfile')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    hrp2xwav
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % use output file from hrp2xwav for input to plot
    if ~exist(PARAMS.outfile)
        set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
        set(HANDLES.fig.main, 'Pointer', 'arrow');
        set(HANDLES.fig.msg, 'Pointer', 'arrow');

        return
    end
    PARAMS.infile = PARAMS.outfile;
    PARAMS.inpath = PARAMS.outpath;
    % initialize the  PARAMS, read a segment, then plot it
    PARAMS.ftype = 2;   % XWAV file format
    initdata
    if isempty(DATA)
        set(HANDLES.display.timeseries,'Value',1);
    end
    readseg
    plot_triton

    control('timeon')   % was timecontrol(1)
    % turn on other menus now
    control('menuon')
    control('button')
    % turn some other buttons/pulldowns on/off
    set([HANDLES.motion.seekbof HANDLES.motion.back HANDLES.motion.autoback HANDLES.motion.stop],...
        'Enable','off');
    % set(HANDLES.pickxyz,'Enable','on')
    set(HANDLES.motioncontrols,'Visible','on')
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
        set(HANDLES.fig.msg, 'Pointer', 'arrow');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box convertARP into a file
elseif strcmp(action,'convertARP')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    bin2xwav
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box convertARP into a file
elseif strcmp(action,'convertOBS')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    obs2xwav
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box convertARP into a file
elseif strcmp(action,'convertMultiARP')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    multibin2xwav
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box decimatefile into a file
elseif strcmp(action,'decimatefile')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    decimatexwav
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box decimatefile into a file
elseif strcmp(action,'decimatefiledir')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    decimatexwav_dir
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box decimatefile into a file
elseif strcmp(action,'decimatewavfile')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    decimatewav
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box decimatefile into a file
elseif strcmp(action,'decimatewavfiledir')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    decimatewavdir
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box make ltsa file
elseif strcmp(action,'mkltsa')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    mk_ltsa
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dialog box change plot parameters
elseif strcmp(action,'changePlotParams')
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    changePlotParams
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');
        
end