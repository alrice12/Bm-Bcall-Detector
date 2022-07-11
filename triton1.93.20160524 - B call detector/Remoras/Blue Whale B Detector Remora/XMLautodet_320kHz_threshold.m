function XMLautodet_320kHz(det,params, directory, filename, outfile,samplefreq)

% scroll through xwav file - adapted from Shyam's BatchClassifyBlueCalls
% smk 100219

% ideal for window lengths greater than 1 raw file (75s).  As is, raw file
% length in seconds must be hard-coded.  If raw files are ever NOT 75s,
% code must be adapted.
%To use for determinging threshold - uncomment directory, filename,
%outfile, sample frequency. Comment xml_out 

%clear all;
%import XML package
import tethys.nilus.*;
 


% % Hardcode Options:
directory = false; %Anaylzing a whole directory or single file?
filename = 'D:\Data\CINMS\Site C\CINMS_C_31_disks01-03_df100\groundtruth\CINMS_C_31_d02_161003_223814.df100.x.wav';
outfile = 'F:\General LF Data Analysis\Thresholds\CINMS\CINMS31C_ker59H_thresh39.xls';
% xml_out='D:\\Backup\\General LF Data Analysis\\Detections\\SOCAL\\CINMS20C_ker47M_thresh25.xml'; %location of output XML, notice double backslash (java thing).
% textfile = 'H:\SOCAL df100 data\Site C\CINMS18C.txt';

block = 2250;   % s
startTime = 0;
halfblock = block/2;

ftype = 2; %confirm xwav
if isempty(strfind(filename, '.x.wav'))
    ftype = 1;
end

%Write xwav file name into excel sheet
in_fid = fopen(filename, 'r');   % Open audio data
out_fid = fopen(outfile, 'a');   % Open xls file to write to
% fprintf(out_fid, '%s\n', filename); % print xwav file name

% colhds = {'Det Start Time', 'Det Score'};
% xlswrite(outfile,colhds,'Sheet1','A1')
% row_start = 2;

hdr = ioReadXWAVHeader(filename, 'ftype', ftype); %read in header info


% Trying to avoid hardcoding number of seconds in a raw file.  Does not
% work yet bc raw files are not equal when scheduled.
% rawsec = 1:(length(hdr.raw.dnumStart));
% for r = 2:length(hdr.raw.dnumStart)
%     raw = datevec((hdr.raw.dnumStart(r))-hdr.raw.dnumStart(r-1));
%     rawsec(r) = (raw(5)*60)+raw(6);

%     make sure raw files lengths are all equal.
% %     if rawsec(r) ~= rawsec(r-1)
% %         disp('raw files are not equal size')
% %         return
% %     end
% end


%Index each block.  Find total number of seconds in xwav, divide by 
%length of a raw file
%params.fs = samplefreq;
samplefreq=320e6;
if samplefreq == 320e6 || 320e6/20 || 320e6/100
    rf_secs = 43.75;
elseif samplefreq == 200e6 || 200e6/20 || 200e6/100
    rf_secs = 75;
else
errordlg(sprintf('Uknown fs %d',samplefreq))
return
end

totalsec = (length(hdr.raw.dnumStart))*rf_secs; %number of raw files * 75s
blocknum = floor(totalsec/block); %how many times will the whole window fit
blkfit = blocknum*block; %how many seconds will fit the block
extra = totalsec-blkfit; %total seconds left over
extraraw = extra/rf_secs; %total raw files left over to process
%process extra separately

% Find scheduled gaps in Duty Cycle data
% The offset will be used when calculating the real time of detections in
% writeBcalls function
for rIdx = 1:length(hdr.raw.dnumStart)
    if rIdx <= 1
        gap = 0;
        offset = 0;
    else
        gap(rIdx) = floor((hdr.raw.dnumStart(rIdx) - ...
            hdr.raw.dnumEnd(rIdx-1)) * 24 * 60 * 60);

        % Calculate the cumulative offset in scheduled gaps per raw file
        offset(rIdx) = offset(rIdx-1) + floor((hdr.raw.dnumStart(rIdx) - ...
            hdr.raw.dnumEnd(rIdx-1)) * 24 * 60 * 60); % will give cumulative gap time so far
    end
end

%%%%%%VERIFY THESE, esp call type,soft, xml_out%%%%%%%
%set up XML variables, preamble
%BmB det parameter values
if ~directory  %won't execute the rest unless directory==true
    det=Detections();
    q=dbInit('Server', 'bandolero.ucsd.edu', 'Port', 9779); %set up query handler
    userid = 'arice'; %change to your username, usually firstinitial+lastname(jdoe)
    soft = 'autodet'; %"name of the software that implements the algorithm"
    version = '1.0';  %change to reflect version the software
    method = 'Energy Detector'; %this line is optional, just a description of the algorithm
    granularity = 'call'; %type of granularity, allowed: call, encounter, binned
    call = 'B NE '; %string to describe calls of interest
    speciesID = 180528; %TSN for Blue Whales
    
    %Grab information from file header (hdr)
    project=hdr.xhd.ExperimentName(isstrprop(hdr.xhd.ExperimentName,'alpha'));
    deployment=str2double(hdr.xhd.ExperimentName(isstrprop(hdr.xhd.ExperimentName,'digit')));
    site=hdr.xhd.SiteName(isstrprop(hdr.xhd.SiteName,'alphanum'));
    
    %Effort time; compare to Wake up time in the HARP DB
    query=sprintf('collection("Deployments")/ty:Deployment[Project="%s"][DeploymentID="%02d"][Site="%s"]/SamplingDetails/Channel/Start', project, deployment,site);
    start_elem = char(q.QueryTethys(query));
    wake_up=dbISO8601toSerialDate(strtok(start_elem(8:length(start_elem)),'<'));
    for tidx=1:length(hdr.raw.dnumStart)
        if hdr.raw.dnumStart(tidx)+dateoffset >= wake_up
            effStart = dbSerialDateToISO8601(hdr.raw.dnumStart(tidx)+dateoffset);
            break; %jump out the loop, we've found the time
        end
    end
    effEnd = dbSerialDateToISO8601(hdr.end.dnum+dateoffset);
    
       
    
    %Add what we have so far to the Detections object
    det.setUserID(userid);
    det.setSite(project,site,deployment);
    det.setEffort(effStart, effStart);%start and end set equal, change later.
    det.addKind(speciesID,{granularity,call});
    det.setAlgorithm({soft,version, method});

end




% Here we go...

% for blockIdx = 1:blocknum  %scroll through blocks
%     fprintf('Analyzing block %2d of %d ...\n', blockIdx, blocknum);

% While we are in range for the current block...
firstrun=true;
while startTime + block <= blkfit
    endTime = startTime + block;
    fprintf('Analyzing %2d - %d of %d seconds ...\n', startTime, (startTime+halfblock), totalsec);
    
    if firstrun==true && ~directory
        params = true; %flag to write parameters, is set to false later in code  
    end
    XMLfindcalls_320kHz(rIdx, halfblock, block, gap, offset, startTime, endTime, filename, hdr, ftype, in_fid, out_fid, 0, det, params, rf_secs);
    firstrun=false;
    params=false ;%XML parameters won't be added anymore
    startTime = startTime + halfblock;
    %XMLfindcalls_320kHz(rIdx, halfblock, block, gap, offset, startTime, endTime, filename, hdr, ftype, in_fid, out_fid, 0, det, params, rf_secs);
end

% Process the last remaining segment thats < 1 block but is
% at least 1 halfblock long
if startTime + halfblock <= blkfit;
    
    endTime = startTime + halfblock;
    
    fprintf('Analyzing %2d - %d of %d seconds ...\n', startTime, endTime, totalsec);
    
    XMLfindcalls_320kHz(rIdx, halfblock, block, gap, offset, startTime, endTime, filename, hdr, ftype, in_fid, out_fid, 0, det, params,rf_secs);
    
    startTime = startTime + halfblock;
end

rawblk = rf_secs; %hardcoding at 75s (length of raw file) will ensure that
% all raw files left over are processed
halfraw = rf_secs/2;
fprintf ('\nProcess any "extra" ...\n')
%Process the extra raw files
while startTime + rawblk <= totalsec
    
    endTime = startTime + rawblk;
    
    fprintf('Analyzing %.1f - %.1f of %d seconds ...\n', startTime, (startTime+halfraw), totalsec);
    
    XMLfindcalls_320kHz(rIdx, halfblock, block, gap, offset, startTime, endTime, filename, hdr, ftype, in_fid, out_fid, 0, det, params,rf_secs);
    
    startTime = startTime + halfraw;
end

fprintf ('\n...last bit.\n')
%Process last remaining bit of extra
if startTime + halfraw <= totalsec
    endTime = startTime + halfraw;
    
    fprintf('Analyzing %.1f - %.1f of %d seconds.\n', startTime, endTime, totalsec);
    
    XMLfindcalls_320kHz(rIdx, halfblock, block, gap, offset, startTime, endTime, filename, hdr, ftype, in_fid, out_fid, 0, det, params,rf_secs);
    
end

%close out with effort
if ~directory
    det.setEffort(effStart,effEnd);
    %det.marshal(xml_out);
end
fclose(in_fid);
fclose(out_fid);
    
%end