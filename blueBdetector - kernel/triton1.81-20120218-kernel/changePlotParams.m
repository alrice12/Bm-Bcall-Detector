function changePlotParams
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% changePlotParams.m
%
% 070315 smw
%
% adjust plotting parameters - auto or manual values
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS

prompt={'Enter Scaling => Auto = 1, Manual = 0 : ',...
    'Enter Max Amp [counts] : ',...
    'Enter Min Amp [counts] : ',...
    'Enter Max SPL [dB] : ', ...
    'Enter Min SPL [dB] :'};


def={num2str(PARAMS.auto),...
    num2str(PARAMS.ts.max),...
    num2str(PARAMS.ts.min),...
    num2str(PARAMS.sp.max),...
    num2str(PARAMS.sp.min)};

dlgTitle='Set Spectra Plotting Parameters';
lineNo=1;
AddOpts.Resize='on';
AddOpts.WindowStyle='normal';
AddOpts.Interpreter='tex';
% display input dialog box window
in=inputdlg(prompt,dlgTitle,lineNo,def,AddOpts);
if length(in) == 0	% if cancel button pushed
    PARAMS.ltsa.gen = 0;
    return
else
    PARAMS.ltsa.gen = 1;
end

PARAMS.auto = str2num(deal(in{1}));

PARAMS.ts.max = str2num(deal(in{2}));

PARAMS.ts.min = str2num(deal(in{3}));

PARAMS.sp.max = str2num(deal(in{4}));

PARAMS.sp.min = str2num(deal(in{5}));

plot_triton
