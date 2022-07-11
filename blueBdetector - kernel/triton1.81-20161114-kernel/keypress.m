function varargout = keypress(varargin)
%
%
% @author Brian Truong
%
% controls the mostly the motion controls of the ltsa and spectrogram plot
% each control is binded to certain keys thus creating hotkey functions for
% triton
%
% called from toolpd
%
% Based off of script from the site:
% http://blinkdagger.com/matlab/matlab-gui-tutorial-adding-keyboard-shortcu
% ts-hotkeys-to-a-gui/2/
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global HANDLES 
% HANDLES.figure1 = figure(4);


%whenever any key is pressed, myFunction is called
 set(HANDLES.fig.main,'KeyPressFcn',@handleKeypress)
%set(HANDLES.fig.main,'WindowButtonDownFcn',@myFunction)
%%
% --- Executes just before keypress is made visible.

function handleKeypress(src,evnt)
%this function takes in two inputs automatically
%src is the gui figure
%evnt is the keypress information
% figure1 = figure(4);
global HANDLES handles PARAMS

% figure out how many subplots needed :
savalue = get(HANDLES.display.ltsa,'Value');
tsvalue = get(HANDLES.display.timeseries,'Value');
spvalue = get(HANDLES.display.spectra,'Value');
sgvalue = get(HANDLES.display.specgram,'Value');

%initialize these variables
control = 0;
alt = 0;
shift = 0;

%determine which modifiers have been pressed
for x=1:length(evnt.Modifier)
    switch(evnt.Modifier{x})
        case 'control'
            control = 1;
        case 'alt'
            alt = 1;
        case 'shift'
            shift = 1;
    end
end

%checks to see if the control button is being pressed 
%and the LTSA plot is on, then the following commands are made
if control + savalue == 2 
    % pressing the RIGHT arrow key moves the LTSA plot forward
    if (strcmp(evnt.Key, 'rightarrow'))
        motion_ltsa('forward');
        
   % pressing the LEFT arrow key moves the LTSA plot backward
    elseif (strcmp(evnt.Key, 'leftarrow'))
        motion_ltsa('back');
    
    % pressing the UP arrow key controls the LTSA auto forward motion
    elseif (strcmp(evnt.Key, 'uparrow'))
        motion_ltsa('autof');
    
    % pressing the DOWN key controls the LTSA auto backward motion
    elseif (strcmp(evnt.Key, 'downarrow'))
        motion_ltsa('autob');
        
    % pressing the SPACEBAR controls the stops the LTSA plot motion
    elseif (strcmp(evnt.Key, 'space'))
        motion_ltsa('stop');
    end

%if the ctrl button is not pressed then it checks to see if the spectrogram
%timeseries and spectra plots are available and performs the following
%commands.
elseif (sgvalue + tsvalue + spvalue) > 0

    % pressing the RIGHT arrow key moves the plot forward
    if (strcmp(evnt.Key, 'rightarrow'))
        motion('forward');
    
    % pressing the LEFT arrow key moves the plot backward
    elseif (strcmp(evnt.Key, 'leftarrow'))
        motion('back');
    
    % pressing the UP arrow key controls the auto forward motion
    elseif (strcmp(evnt.Key, 'uparrow'))
        motion('autof');
    
    % pressing the DOWN key controls the auto backward motion
    elseif (strcmp(evnt.Key, 'downarrow'))
        motion('autob');
    
     % pressing the SPACEBAR controls the stops the plot motion
    elseif (strcmp(evnt.Key, 'space'))
        motion('stop');
    end

        % check to see if the logger is on
%elseif ~isempty(handles)
end

% Logger options
switch evnt.Key
    case 'b'   % Specify both:  start and end
        control_log('pickboth');
        
    case 's'  % Start of call
        control_log('pickstart');
        
    case 'e'  % end of call
        control_log('pickend');
        
    case {'1','2','3','4','5','6'}  % Set parameter
        idx = str2num(evnt.Key);
        control_log(handles.freq(idx), [], 'set_parameter');
        
    case 'f'  % Toggle pick frequency button
        value = get(handles.pkfreq, 'Value');
        set(handles.pkfreq, 'Value', ~value);

    case 'l'
        control_log('log')
end





