function fix_dirlistTimes(dflag)
%
% fix_dirlistTimes.m
%
% useage: >>fix_dirlistTimes(dflag)
%   dflag = display flag, on = 1
%
% based on mod_xwavhdrTime.m 091125 smw
%
%
% 100528 smw
global PARAMS

% check to see if PARAMS.xhd and PARAMS.head exist
if ~isfield(PARAMS,'head')
    disp('Error : PARAMS.head undefined')
    return
end

% raw file start times in days
% y = PARAMS.raw.dnumStart;
y = datenum([PARAMS.head.dirlist(:,2) PARAMS.head.dirlist(:,3)...
    PARAMS.head.dirlist(:,4) PARAMS.head.dirlist(:,5) PARAMS.head.dirlist(:,6) ...
    PARAMS.head.dirlist(:,7)+(PARAMS.head.dirlist(:,8)/1000)]);

% differenced time in seconds
dy = 24*60*60*diff(y);

%  find times later than next raw file
I = [];
I = find( dy < 0);
Ilen = length(I);
if ~isempty(I)
    if dflag
        disp([num2str(Ilen),' Raw File Times Later than Next'])
        disp(num2str(datevec(y(I))))
        disp(num2str(dy(I)'))
    end
    
    % calculat modified times
    % only good if one bad time, doesn't work for two or more sequential
    % bad times...
    y(I) = y(I+1) - datenum([0 0 0 0 0 75]);
    % put in date vector
    ydv = datevec(y);
    % get mseconds from decimal seconds
    ydv(:,7) = floor(1000*(ydv(:,6) - floor(ydv(:,6))));
    ydv(:,6) = floor(ydv(:,6));
    % could fix ticks if greater than 999, but ripple effect to sec,
    % min,hr....
    
    % modify dirlist times
    PARAMS.head.dirlist(I,2:8) = ydv(I,1:7);
    
else
    if dflag
        disp('No Raw File Times Later than Next')
    end
end

