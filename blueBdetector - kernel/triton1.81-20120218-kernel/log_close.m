function log_close(end_effort_date)

global handles HANDLES PARAMS

% Locate the end of effort
effortEnd = 'Effort End';
col = find(strcmp(handles.Meta.Headers, effortEnd), 1, 'first');
if isempty(col)
    errordlg(sprintf('Column %s missing from MetaData sheet', effortEnd));
    return
else
    colStr = excelColumn(col - 1);
    set(handles.Meta.Sheet.Range(sprintf('%s2', colStr)), ...
        'Value', datestr(end_effort_date, 31))
    
end

PARAMS.log.pick = [];  % Turn off time X freq callback
pickxyz(true);  % reset cursor

% Save and close up
handles.Workbook.Save();
handles.Workbook.Close();
handles.Workbook = [];
handles.Server.Quit();
handles.Server = [];

% Restore original closing function
for f = {'main', 'ctrl', 'msg'}
    field = f{1};
    set(HANDLES.fig.(field), ...
        'CloseRequestFcn', handles.log.oldclosefn.(field));
end

delete(handles.logcallgui);  % Remove logger gui
clear GLOBAL handles;  % No longer valid
