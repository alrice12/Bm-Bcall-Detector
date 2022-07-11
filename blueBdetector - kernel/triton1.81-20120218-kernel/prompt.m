%datasetPrompt

%dialog box to set dataset name (for saveSpecs_short)

prompt={'Name this B call .mat file :'};

def = {' '};

dlgTitle='Filename';
lineNo=1;
AddOpts.Resize='on';
AddOpts.WindowStyle='normal';
AddOpts.Interpreter='tex';

% display input dialog box window
in=inputdlg(prompt,dlgTitle,lineNo,def,AddOpts);

% if cancel button pushed
if length(in) == 0
    PARAMS.ltsa.gen = 0;
    return
else
    PARAMS.ltsa.gen = 1;
end

name = in{1,1};

