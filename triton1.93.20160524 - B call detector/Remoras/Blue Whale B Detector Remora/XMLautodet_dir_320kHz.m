% XMLautodet_dir

% Adapted from decimatexwav_dir
% smk 100219
% Updated to look for only xwavs and output to .xls (not .txt)
% smk 110603
% Modify L96 to use appropriate sample frequency

import tethys.nilus.*; %Import JAXB Package
q=dbInit('Server','bandolero.ucsd.edu','Port',9779); %setup query handler
dps = 1.15741e-5; %conversion factor -- days per second
%-------------------------------------------------------------------------
% Choose input directory.
ii = 1;
ddir = '';   % default directory
idir{ii} = uigetdir(ddir,['Select Directory of XWAVS']);
% if the cancel button is pushed, then no file is loaded so exit this script
if strcmp(num2str(idir{ii}),'0')
    disp('Canceled Button Pushed - no directory for XWAV inputs')
    return
else
    disp('Input file directory : ')
    disp([idir{ii}])
    disp(' ')
end

% Display number of files in directory
d = dir(idir{ii});    % directory info
fn = {d.name}';      % file names in directory
str = '.x.wav';
k = strfind(fn, str);
for m = 1:length(k)
    n(m,1) = isempty(k{m,1});
end
x = n == 0;
xwavs = fn(x);
xnum = size(xwavs);
numx = xnum(1);
disp(['Number of XWAVs in Input file directory is ',num2str(numx)])

%--------------------------------------------------------------------------
%boxTitle1 = ['Select Output Text File'];
%filterSpec1 = '*.txt';
%defaultName = 'E:';
outfile = 'CINMS30C_ker57N_thresh37.xls';
%[outfile,outpath]=uigetfile(filterSpec1,boxTitle1,defaultName);
%outpath = 'E:\SOCAL df100 data\detection\AutoDetect_txt\Complete Detections\Site A'
outpath = 'F:\General LF Data Analysis\Detections\SOCAL\CINMS\Site C\'
outflen = length(outfile);
outplen = length(outpath);

%--------------------------------------------------------------------------
% Choose XML output file
% boxTitle2 = ['Select Output XML File'];
% filterSpec2 = {'*.xml';'*.txt'};
% defaultName2 = 'E:';
% [xmlfile,xmlpath]=uigetfile(filterSpec2,boxTitle2,defaultName2);
% xml_out=strcat(xmlpath,xmlfile);

%hardcoded location of output XML, if not using prompt
xml_out= 'F:\General LF Data Analysis\Detections\SOCAL\CINMS\Site C\CINMS30C_ker57N_thresh37.xml'; 
% -------------------------------------------------------------------------
%Loop the following codes through chosen directory
detALL=[];
det=Detections(); %create XML object input
proc_dir=true; %tell autodet it's working through a directory
for jj = 1:numx
    directory.inpath = strcat(idir,'\');
    directory.infiledet = xwavs(jj,:); % get file names sequentally
    filename = strcat(directory.inpath,directory.infiledet);
    disp(['Looking for calls in  ' filename{1,1}])
    %     [fid,message] = fopen([xwavs.inpath,xwavs.infiledet], 'r');  %reading file
    if jj==1 %first run
        %grab header info from it
        first_hdr = ioReadXWAVHeader(filename{1,1});
        project=first_hdr.xhd.ExperimentName(isstrprop(first_hdr.xhd.ExperimentName,'alpha'));
        deployment=str2double(first_hdr.xhd.ExperimentName(isstrprop(first_hdr.xhd.ExperimentName,'digit')));
        site=first_hdr.xhd.SiteName(isstrprop(first_hdr.xhd.SiteName,'alphanum'));
        site = 'C';
        project = 'CINMS';
        deployment = 23;
        params=true; %set parameters the first time
        %Effort time; compare to Wake up time in the HARP DB
        query=sprintf('collection("Deployments")/ty:Deployment[Project="%s"][DeploymentID="%02d"][Site="%s"]/SamplingDetails/Channel/Start', project, deployment,site);
        start_elem = char(q.QueryTethys(query));
        wake_up=dbISO8601toSerialDate(strtok(start_elem(8:length(start_elem)),'<'));
        for tidx=1:length(first_hdr.raw.dnumStart)
            if first_hdr.raw.dnumStart(tidx)+dateoffset >= wake_up
                startSerial = first_hdr.raw.dnumStart(tidx) + dateoffset;
                effStart = dbSerialDateToISO8601(startSerial);
                break; %jump out the loop, we've found the time
            end
        end
    else
        params=false;
    end
    try
        samplefreq = 320000;
        XMLautodet_320kHz(det, params, proc_dir, [filename{1,1}], [outpath, outfile],samplefreq)
    catch e
        if jj==1
            disp('autodet failed on first file')
            disp(['setting EffortEnd to: ',datestr(startSerial),'+', e.cause{1,1}.message, ' seconds...']);
            days = str2double(e.cause{1,1}.message) * dps;
            disp(['end set to: ',datestr(startSerial+days)]);
            effEnd = dbSerialDateToISO8601(startSerial+days);
            break;
        else
            directory.infiledet = xwavs(jj-1,:);
            filename = strcat(directory.inpath,directory.infiledet);
            known_hdr = ioReadXWAVHeader(filename{1,1});%append: ...,'ftype',1) for wav
            endSerial = known_hdr.end.dnum+dateoffset;
            disp(['setting EffortEnd to the previous file''s end time: ',datestr(endSerial),'+', e.cause{1,1}.message, ' seconds...']);
            days = str2double(e.cause{1,1}.message) * dps;
            disp(['end set to: ', datestr(endSerial+days)]);
            effEnd = dbSerialDateToISO8601(endSerial+days);
            break;
        end
    end
    if jj==numx
        %grab endtime
        last_hdr = ioReadXWAVHeader(filename{1,1});
        effEnd = dbSerialDateToISO8601(last_hdr.end.dnum+dateoffset);
    end
end

%--------------------------------------------------------------------------
%XML Preamble
%Variables:
userid = 'arice'; %change to your username, usually firstinitial+lastname(jdoe)
soft = 'autodet'; %"name of the software that implements the algorithm"
version = '1.0';  %change to reflect version the software
method = 'Spectrogram Correlation'; %this line is optional, just a description of the algorithm
granularity = 'call'; %type of granularity, allowed: call, encounter, binned
call = 'B NE Pacific'; %string to describe calls of interest
speciesID = 180528; %TSN for Blue Whales



det.setUserID(userid);
det.setSite(project,site,deployment);
det.setEffort(effStart, effEnd);
det.addKind(speciesID,{granularity,call});
det.setAlgorithm({soft,version, method});
det.marshal(xml_out);
