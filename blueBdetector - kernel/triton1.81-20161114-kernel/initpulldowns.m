function initpulldowns
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% initpulldowns.m
%
% generate figure pulldown menus
%
% 5/5/04 smw
%
% 060224 - 060227 smw modified for v1.60
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global HANDLES
%
%%%%%%%%%%%%%%%%%%%%
%
% 'File' pulldown
%
%%%%%%%%%%%%%%%%%%%%
HANDLES.filemenu = uimenu(HANDLES.fig.ctrl,'Label','&File');
% 'Open long-term spectral average File (*.ltsa)'
% uimenu(HANDLES.filemenu,'Label','&Open PSDS File','Callback','filepd(''openltsa'')');
uimenu(HANDLES.filemenu,'Label','&Open LTSA File','Callback','filepd(''openltsa'')');
% 'Open Pseudo-Wav File (*.x.wav)'
uimenu(HANDLES.filemenu,'Label','Open &XWAV File','Callback','filepd(''openxwav'')');
% 'Open Wav File (*.wav)'
uimenu(HANDLES.filemenu,'Label','Open &WAV File','Callback','filepd(''openwav'')');

% 'Open Detection Label File (*.lab)'
% uimenu(HANDLES.filemenu,'Separator','on', 'Label', 'Open &Detection Label File', ...
%        'Callback', 'filepd(''openlabel'')');
   
% Load Hydrophone Transfer Functions File
%
uimenu(HANDLES.filemenu,'Separator','on','Label','Load Transfer Function File',...
    'Enable','on','Callback','filepd(''loadTF'')');
       
%
% 'Save As Wav'
HANDLES.saveas = uimenu(HANDLES.filemenu,'Separator','on','Label','Save Plotted Data As &WAV',...
    'Enable','off','Callback','filepd(''savefileas'')');
% 'Save As XWav'
HANDLES.saveasxwav = uimenu(HANDLES.filemenu,'Separator','off','Label','Save Plotted Data As &XWAV',...
    'Enable','off','Callback','filepd(''savefileasxwav'')');
% 'Save JPG'
HANDLES.savejpg = uimenu(HANDLES.filemenu,'Label','Save Plotted Data As &JPG',...
    'Enable','off','Callback','filepd(''savejpg'')');
%
% 'Save Figure As'
HANDLES.savefigureas = uimenu(HANDLES.filemenu,'Separator','on',...
    'Label','Save Plotted Data As MATLAB &Figure',...
    'Visible','off',...
    'Enable','off','Callback','filepd(''savefigureas'')');
% 'Save Image As'
HANDLES.saveimageas = uimenu(HANDLES.filemenu,'Label','Save Spectrogram As &Image',...
    'Visible','off',...
    'Enable','off','Callback','filepd(''saveimageas'')');
%
% 'Exit'
uimenu(HANDLES.filemenu,'Separator','on','Label','E&xit',...
    'Callback','filepd(''exit'')');
%%%%%%%%%%%%%%%%%%
%
% 'Tools' pulldown
%
%%%%%%%%%%%%%%%%%%%
HANDLES.toolmenu = uimenu(HANDLES.fig.ctrl,'Label','&Tools',...
    'Enable','on');
%      uimenu(HANDLES.toolmenu,'Label','Run Matlab script',...
%          'Callback','toolpd(''run_mat'')');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% HARP Raw Disk
%
HANDLES.rawmenu = uimenu(HANDLES.toolmenu,'Label','HARP Raw Disk');
 uimenu(HANDLES.rawmenu,'Label','dd --list',...
     'Callback','toolpd(''dd_list'')','Enable','on');
  uimenu(HANDLES.rawmenu,'Label','Get Raw Disk ID',...
     'Callback','toolpd(''get_RawDisk'')','Enable','on');
 uimenu(HANDLES.rawmenu,'Label','Get Raw Disk Header',...
     'Callback','toolpd(''get_Rawhead'')','Enable','on');
% % 'Read HRP Disk file directory listing of raw files'
uimenu(HANDLES.rawmenu,'Label','Get Raw Directory List',...
    'Enable','on','Callback','toolpd(''get_Rawdir'')','Enable','on');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% HRP file operations
%
HANDLES.hrpmenu = uimenu(HANDLES.toolmenu,'Label','HRP File');
% 'Convert HRP disk file to XWAVS'
 uimenu(HANDLES.hrpmenu,'Label','Convert Multiple HRP Files to XWAV Files',...
     'Callback','toolpd(''convert_multiHRP2XWAVS'')','Enable','off');
 uimenu(HANDLES.hrpmenu,'Label','Convert HRP File to XWAV Files',...
     'Callback','toolpd(''convert_HRP2XWAVS'')','Enable','on');
% % 'Read Disk HRP file header'
 uimenu(HANDLES.hrpmenu,'Label','Get HRP File Disk Header',...
     'Callback','toolpd(''get_HRPhead'')','Enable','on');
% % 'Read HRP Disk file directory listing of raw files'
uimenu(HANDLES.hrpmenu,'Label','Get HRP File Directory List',...
    'Enable','on','Callback','toolpd(''get_HRPdir'')','Enable','on');
% check directory listing times in HRP disk file Header
uimenu(HANDLES.hrpmenu,'Label','Check Directory List Times',...
    'Enable','on','Callback','toolpd(''ck_dirlist_times'')','Enable','on');
% plot sector times
uimenu(HANDLES.hrpmenu,'Label','Plot Sector Times',...
    'Enable','on','Callback','toolpd(''plotSectorTimes'')','Enable','on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Convert Submenu:
%
HANDLES.convertmenu = uimenu(HANDLES.toolmenu,'Separator','on','Label','Convert');
%
uimenu(HANDLES.convertmenu,'Separator','on','Label','&Convert Single HARP FTP File to XWAV',...
    'Callback','toolpd(''convertfile'')');
% 'Convert ARP *.bin file'
uimenu(HANDLES.convertmenu,'Label','Convert Single &ARP BIN File to XWAV',...
    'Callback','toolpd(''convertARP'')');
% 'Convert OBS *.obs file'
uimenu(HANDLES.convertmenu,'Label','Convert Single &OBS File to XWAV',...
    'Callback','toolpd(''convertOBS'')');
% 'Convert ARP *.bin folder'
uimenu(HANDLES.convertmenu,'Separator','on','Label','Convert Directory of ARP BIN Files to XWAVs',...
    'Callback','toolpd(''convertMultiARP'')');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Header Ops
%
HANDLES.headmenu = uimenu(HANDLES.toolmenu,'Label','Headers');
HANDLES.editltsa = uimenu(HANDLES.headmenu,'Separator','on','Label','&Edit Header - LTSA File',...
    'Enable','off','Visible','off','Callback','toolpd(''editltsa'')');
% view XWAV file
HANDLES.viewxwav = uimenu(HANDLES.headmenu,'Label','&View Header - XWAV File',...
    'Enable','on','Callback','toolpd(''viewxwavhd'')');
% modify XWAV file
HANDLES.editxwav = uimenu(HANDLES.headmenu,'Label','&Edit Header - XWAV File',...
    'Enable','on','Callback','toolpd(''editxwavhd'')');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Decimate ops
%
HANDLES.decimenu = uimenu(HANDLES.toolmenu,'Label','Decimate');
%
% 'decimate xwav file'
uimenu(HANDLES.decimenu,'Separator','on','Label','&Decimate Single XWAV File',...
    'Enable','on','Callback','toolpd(''decimatefile'')');
% 'decimate xwav file directory'
uimenu(HANDLES.decimenu,'Label','&Decimate All XWAV Files in Directory',...
    'Enable','on','Callback','toolpd(''decimatefiledir'')');
% 'decimate wav file'
uimenu(HANDLES.decimenu,'Separator','on','Label','&Decimate Single WAV File',...
    'Enable','on','Callback','toolpd(''decimatewavfile'')');
% 'decimate wav file directory'
uimenu(HANDLES.decimenu,'Label','&Decimate All WAV Files in Directory',...
    'Enable','on','Callback','toolpd(''decimatewavfiledir'')');
%
%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Parameters Ops
%
%%%%%%%%%%%%%%%%%%%%%%%%%
HANDLES.parametersmenu = uimenu(HANDLES.toolmenu,'Label','&Parameters');
% set parameters
% load parameter file
uimenu(HANDLES.parametersmenu,'Label','&Load Parameters',...
    'Callback','save_cp(''readPick'')');
% save parameter file
uimenu(HANDLES.parametersmenu,'Label','&Save Parameters',...
    'Callback','save_cp(''saveTo'')');
% default parameter file
uimenu(HANDLES.parametersmenu,'Label','&Load Default Parameters',...
    'Callback','save_cp(''readDefault'')');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Detect
%
% HANDLES.detectmenu = uimenu(HANDLES.toolmenu,'Label','Detect');
% % 'Batch Detect LTSA File'
% uimenu(HANDLES.detectmenu,'Separator','on','Label','&Batch Detect LTSA File',...
%     'Enable','on','Callback','toolpd(''dtLTSABatch'')');
% % 'Batch Detect XWAV File'
% uimenu(HANDLES.detectmenu,'Label','&Batch Detect Single XWAV File',...
%     'Enable','on','Callback','toolpd(''dtSingleSTBatch'')');
% % 'Batch Detect XWAV Directory'
% uimenu(HANDLES.detectmenu,'Label','&Batch Detect ALL XWAV Files in Directory',...
%     'Enable','on','Callback','toolpd(''dtDirSTBatch'')');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% generate LTSAs
%
uimenu(HANDLES.toolmenu,'Separator','on','Label','&Make LTSA from Directory of Files',...
    'Enable','on','Callback','toolpd(''mkltsa'')');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Misc ops
%
HANDLES.miscmenu = uimenu(HANDLES.toolmenu,'Label','Misc');
%
% 'change plot parameters'
uimenu(HANDLES.miscmenu,'Separator','on','Label','&Change Plot Parameters',...
    'Enable','on','Callback','toolpd(''changePlotParams'')');


%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 'Log' pulldown
%
%%%%%%%%%%%%%%%%%%%%%%%%%
HANDLES.logmenu = uimenu(HANDLES.toolmenu,'Label','&Log',...
    'Enable','on','Visible','on');
% select a logging GUI
uimenu(HANDLES.logmenu, 'Label', 'New log', ...
    'Callback', 'initLogctrl(''create'')');
uimenu(HANDLES.logmenu, 'Label', 'Continue existing log', ...
    'Callback', 'initLogctrl(''append'')');
uimenu(HANDLES.logmenu, 'Label', 'Submit log', ...
    'Callback', @dbSubmit);


%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 'Help' pulldown
%
%%%%%%%%%%%%%%%%%%%%%%%%%
HANDLES.helpmenu = uimenu(HANDLES.fig.ctrl,'Label','&Help',...
    'Enable','on');
% set parameters
uimenu(HANDLES.helpmenu,'Label','&About',...
    'Callback','helppd(''dispAbout'')');
uimenu(HANDLES.helpmenu,'Label','&Manual',...
    'Callback','helppd(''openManual'')');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Message window pulldown
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
HANDLES.msgmenu = uimenu(HANDLES.fig.msg,'Label','&File');

% 'Open picks'
HANDLES.openpicks = uimenu(HANDLES.msgmenu,'Separator','off','Label','&Open Picks',...
    'Enable','on','Visible','on','Callback','filepd(''openpicks'')');
% 'Save picks'
HANDLES.savepicks = uimenu(HANDLES.msgmenu,'Separator','off','Label','Save &Picks',...
    'Enable','off','Callback','filepd(''savepicks'')');

% 'Save messages'
HANDLES.savemsgs = uimenu(HANDLES.msgmenu,'Separator','on','Label','Save &Messages',...
    'Enable','on','Callback','filepd(''savemsgs'')');
HANDLES.clrmsgs = uimenu(HANDLES.msgmenu,'Separator','off','Label','Clear Messages',...
    'Enable','on','Callback','filepd(''clrmsgs'')');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% some window stuff?
set(gcf,'Units','pixels');
axis off
axHndl1=gca;


%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Detection Parameters pulldown
%
%%%%%%%%%%%%%%%%%%%%%%%%%
% HANDLES.dt.filemenu = uimenu(HANDLES.fig.dt,'Label','&File',...
%     'Enable','on','Visible','on');
% % load LTSA parameter file
% uimenu(HANDLES.dt.filemenu,'Label','&Load LTSA ParamFile',...
%     'Callback','dt_paramspd(''LTSAparamload'')');
% % load spectrogram parameter file
% uimenu(HANDLES.dt.filemenu,'Label','&Load Specgram ParamFile',...
%     'Callback','dt_paramspd(''STparamload'')');
% 
% % save LTSA parameter file
% uimenu(HANDLES.dt.filemenu,'Separator','on','Label','&Save LTSA ParamFile',...
%     'Callback','dt_paramspd(''LTSAparamsave'')');
% % save spectrogram parameter file
% uimenu(HANDLES.dt.filemenu,'Label','&Save Specgram ParamFile',...
%     'Callback','dt_paramspd(''STparamsave'')');