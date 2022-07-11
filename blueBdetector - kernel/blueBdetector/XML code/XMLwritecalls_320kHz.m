function XMLwritecalls_320kHz (hdr, rIdx, halfblock, startTime, offset, peakS, score, out_fid, in_fid, dxml, rf_secs)

% Adapted from Shyam's BatchClassifyBlueCalls
% Updated to write score after start time
% smk 100713
import tethys.nilus.*; %JAXB Package
speciesID = 180528; %TSN for Blue Whales
totalCalls = size(peakS, 1); %total number of detections
fullname=fopen(in_fid);
[dontcare,name,ext] = fileparts(fullname);
input_file = strcat(name,ext);


% window = startTime+halfblock; %total number of seconds at start of window
% numraw = window/75; %# raw files up to this point - must be integer

if totalCalls > 0
    saveList = peakS(find(peakS(:, 1) <= halfblock), :);
    savedCalls = size(saveList, 1);
           
    if savedCalls > 0
        for m = 1:length(saveList)
            %put detections into raw file bins and add offset
            
            whichraw = ceil((saveList(m)+startTime)/rf_secs);
           
            RealSec(m) = offset(whichraw) + startTime + saveList(m);          
            
            abstime = dateoffset + datenum([0 0 0 0 0 RealSec(m)])+ hdr.raw.dnumStart(1);
            
            dvec = datevec(abstime(1));
            fraction = num2str(dvec(6) - floor(dvec(6)));
            fraction = fraction(2:end);
            thisScore = score(m);
            start=dbSerialDateToISO8601(datenum(dvec));
            oed=Detection(start,speciesID); %XML detection object
            oed.addCall('B NE Pacific');
            oed.setInputFile(input_file);
            oed.parameters.setScore(java.lang.Double(thisScore));
            %oed.popParameters();
            dxml.addDetection(oed);
            fprintf(out_fid, '%s%s\t%f\n', datestr(abstime(1), 31), fraction, thisScore);
           
        end
        
    end
end


