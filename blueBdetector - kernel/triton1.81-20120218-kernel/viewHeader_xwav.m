function viewHeader_xwav()
%
% editHeader_xwav.m
%
% 060226 - 060227 smw
%
% used to change time or other header values for xwav files
%
%
global PARAMS HANDLES

%
% user interface retrieve file to open through a dialog box
boxTitle1 = 'Open XWAV File to View Header';   % psds is old neptune format
filterSpec1 = '*.x.wav';
[PARAMS.infile,PARAMS.inpath]=uigetfile(filterSpec1,boxTitle1);

% if the cancel button is pushed, then no file is loaded so exit this script
if strcmp(num2str(PARAMS.infile),'0')
    return
else % give user some feedback
    disp_msg('Opened XWAV File to View Header: ')
    disp_msg([PARAMS.inpath,PARAMS.infile])
    cd(PARAMS.inpath)
end

% Get Header timing info and load up PARAMS

rdxwavhd

% user input dialog box
% prompt(1) = {'Raw File Start Times'};
prompt = {'yy mm dd HH MM SS mmm'};
%dlgTitle=['View XWAV Header ',PARAMS.inpath,PARAMS.infile];
lineNo=PARAMS.xhd.NumOfRawFiles;

% raw file timing headers format YY MM DD HH MM SS mmm
% for k = 1:PARAMS.xhd.NumOfRawFiles
% %
% %     PARAMS.raw.dvecStart(i,:) = [PARAMS.xhd.year(i) PARAMS.xhd.month(i)...
% %         PARAMS.xhd.day(i) PARAMS.xhd.hour(i) PARAMS.xhd.minute(i) ...
% %         PARAMS.xhd.secs(i)+(PARAMS.xhd.ticks(i)/1000)];

y = [PARAMS.xhd.year' PARAMS.xhd.month' ...
        PARAMS.xhd.day' PARAMS.xhd.hour' PARAMS.xhd.minute' ...
        PARAMS.xhd.secs' PARAMS.xhd.ticks'];
    
%msg={num2str(y)};
% msg={num2str(PARAMS.xhd)};
% msg={PARAMS.xhd};
dlgTitle = ['Header Values for ',PARAMS.inpath,PARAMS.infile];
% msgbox(msg,title,'createMode','non-modal')


def={num2str(y)};
% def={num2str(PARAMS.raw.dvecStart)};

AddOpts.Resize='on';
AddOpts.WindowStyle='normal';
AddOpts.Interpreter='tex';

in = inputdlg(prompt,dlgTitle,lineNo,def,AddOpts);

