function closefigure(string, fig)
% User-defined close request function
% to display a question dialog box
if nargin < 2 && strcmp(string,'all')
    string = 'all Windows';
    fig = get(0,'Children');
end

selection = questdlg(['Close ',string, '?'],...
                     'Close Request Function',...
                     'Yes','No','Yes');
switch selection,
   case 'Yes',
     delete(fig)
   case 'No'
     return
     
end
