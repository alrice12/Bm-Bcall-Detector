% CreateHourBins
% Loads detections from spec correlation and puts into hour bins
% smk 20100825

% Import the detector-based Excel sheet
% [detectorDates, scores] = import_DetectorXls;
[detectorDates] = import_LoggerXls;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Choose output file
boxTitle1 = ['Select Output Text File for Times'];
filterSpec1 = '*.txt';
defaultName = 'H:';
[outfile1,outpath1]=uigetfile(filterSpec1,boxTitle1,defaultName);
outflen1 = length(outfile1);
outplen1 = length(outpath1);
textfile1 = [outpath1, outfile1];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

detDatestr=datestr(detectorDates(:,1),0);

% Find the ultimate min and max dates.
D_min_date = min(min(detectorDates));           %earliest date
D_max_date = max(max(detectorDates));           %latest date
min_date = D_min_date;
max_date = D_max_date;
dateVmin = datevec(min_date);
minHour = dateVmin(:,1:4);
minHour(:,5:6) = 0;
dateVmax = datevec(max_date);
maxHour = dateVmax(:,1:4);
maxHour(:,5:6) = 0;
minHourNum = datenum(minHour);
maxHourNum = datenum(maxHour);
diffHourNum = maxHourNum-minHourNum;
totalHours = diffHourNum*24;

%remove repeated dets in same hour
DetDatevec = datevec(detectorDates);
ReduceDetDates = DetDatevec(:,1:4);
ReduceDetDates(:,5:6) = 0;
Det_RedHourBins = datenum(ReduceDetDates);
Det_HourBins = unique(Det_RedHourBins); 
numHourBins = length(Det_HourBins);

% Convert Bins to datestr for txt file
Det_HourBins_str = datestr(Det_HourBins);

disp(['Hours of presence detected: ', num2str(numHourBins)])
% disp(['Total number of hours in dataset: ', num2str(totalHours)])

out_fid = fopen(textfile1, 'a');   % Open txt file to write to
fprintf(out_fid, '%s\n', 'Detected Hour Bins');
for a = 1:numHourBins
    fprintf(out_fid, '%s\t\n', Det_HourBins_str(a,:));
end










