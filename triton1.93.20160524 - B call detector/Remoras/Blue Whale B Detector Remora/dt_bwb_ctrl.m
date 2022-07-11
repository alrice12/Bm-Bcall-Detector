function dt_bwb_ctrl(choice)

global REMORA PARAMS

switch choice
    case 'ctn'
        blanks = false;
        
        % get string from each of the txt fields
        str = get(REMORA.fig.dir_handles, 'String');
        if isempty(str)
            set(REMORA.fig.dir_handles, 'BackgroundColor', 'red');
            blanks = true;
        else 
            set(REMORA.fig.dir_handles, 'BackgroundColor', 'white');
        end
        
        REMORA.dt_bwb.params_file = get(REMORA.fig.dir_handles, 'String');

        % if missing fields
        if blanks 
            return
        end
        
        PARAMS.dflag = get(REMORA.fig.dflag, 'Value');
        
        closereq;
        
    case 'dflag'
        PARAMS.dflag = get(REMORA.fig.dflag, 'Value');
            
    case 'getfile'
        [fname, fpath] = uigetfile('*.m');
        set(REMORA.fig.dir_handles, 'String', fullfile(fpath, fname));
        
    case 'getdir'
        set(REMORA.fig.dir_handles, 'String', uigetdir);
        
    case 'close_cancel'
        uiresume(gcf);
        delete(gcf);
        REMORA.dt_bwb.success = 0;
end
end
