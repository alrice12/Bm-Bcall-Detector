function kernel_gen_OLD(buttonH, varargin)
% kernel_gen(buttonH)
% Generate a kernel blah blah blah

global handles PARAMS

% Retrieve time/freq picks of last bounding box.
for idx = 1:2
    tf(idx) = get(handles.timefreq(idx), 'UserData');
end

% Check for emtpy time/freq box....
% to do, return error or do nothing...

% keyboard

%PARAMS.t = every time bin
%PARAMS.f = every freq bin
%PARAMS.pwr = matrix of amplitudes...right?

boxTimeIdx = tf(1).timeidx:tf(2).timeidx;
boxTime = PARAMS.t(boxTimeIdx);
boxFreqIdx = tf(2).freqidx:tf(1).freqidx;
boxFreq = PARAMS.f(boxFreqIdx);

boxFreqIdx2 = boxFreqIdx';

box = PARAMS.pwr(boxFreqIdx2,boxTimeIdx); %is this where amp is?
% box = abs(box);

for a = 1:length(box)
    [C, I] = max(box(:,a)); %where I is the row Index, C is the value
    Freq(a) = boxFreq(I);    
end

%Now pick out time indices of interest....
%Find the max of the first 5 points...make that the start.

firstM = max(Freq(1:10));
where = find(Freq == firstM);
%Every 5 bins = 1 sec of time. Truncate after 50 pts (ie 10 sec)
FreqNew = Freq(5:54);

Call(1) = FreqNew(1);
Call(2) = nanmean(FreqNew(5:10)); %1.5s
Call(3) = nanmean(FreqNew(13:18)); %1.5s
Call(4) = nanmean(FreqNew(21:26)); %1.5s
Call(5) = nanmean(FreqNew(45:50));

newMatFile = ['SOCAL29E_Dec_Bcall.mat'];
save(newMatFile,'Call');
disp(['B call characteristics calculated and saved.']);








