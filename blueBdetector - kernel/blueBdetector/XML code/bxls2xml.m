%Blue Whale XLS Spreadsheet to XML coverter
%Designed for blue whale detection spreadsheets of a specific format
%
%Some prompt layout adapted from autodet_dir
%Author: sherbert    11/15/2013

import tethys.nilus.*;

%--------------------------------------------------------------------------
%Detection Spreadsheet Directory Input

%Prompt options:
%indir = uigetdir('','Select Spreadsheet Directory');
%indir = strcat(indir,'\');

%Hardcode option:
indir = 'G:\Detections\Not Submitted XML';
disp('Input file directory: ')
disp(indir)

%Store list of .xls files within indir
indir_ls = dir(indir);
indir_names = {indir_ls.name}';
sheet_ls = strfind(indir_names, '.xls');
for cidx=1:length(sheet_ls)
    empties(cidx,1) = isempty(sheet_ls{cidx,1});
end
xls = empties == 0;
xls_ls = indir_names(xls);
count = num2str(length(xls_ls));
%Display number of input files
disp(['Number of XLS input: ', count])

%--------------------------------------------------------------------------
%Variables independent of spreadsheet, change as necessary

%Effort info
granularity = 'call';
call = 'B NE Pacific';
speciesID = 180528;
%Algorithm info
soft = 'autodet';
version = '1.0';
method = 'Spectrogram Correlation';
%other metadata
userID = 'arice';

%--------------------------------------------------------------------------
%Handling of files within directory

%preliminary information:

proj_len = 5; %number of characters in project, e.g. SOCAL: 5, Hawaii: 6

%loop through the files:
for xidx=1:length(xls_ls)
    det=Detections(); %java XML container
    filename = xls_ls{xidx};
    fparts = strread(filename,'%s','delimiter','_');
    kernel = strtok(fparts{2},'ker');
    thresh = fparts{3}(isstrprop(fparts{3},'digit'));
    short_name = strtok(filename,'.');
    
    %output location (first argument),
    %filename is the same as the input spreadsheet
    xml_out = strcat('G:\Detections\',...
        short_name,'.xml');
    
    %spreadsheet data
    [score_column,start_column] = xlsread(strcat(indir,filename));
    [nada, effort] = xlsread(strcat(indir,filename),2);
    
    %effort info
    effStart = dbSerialDateToISO8601(datenum(effort{2,1}));
    effEnd = dbSerialDateToISO8601(datenum(effort{2,2}));
    %deployment info (from filename)
    prodesi = fparts{1};
    project = prodesi(1:proj_len);
    site = prodesi(proj_len+3:end);
    depl = str2double(prodesi(proj_len+1:proj_len+2));
    
    %Parameters e for names, v for values
    %naming consistent with autodet
    eThresh = 'Threshold';
    vThresh = thresh;
    
    eStartTime = 'Start_Time';  %maybe want to re-name?
    
    eBlock = 'Block_s';
    eBandw = 'Bandwidth_Hz';
    eNeighb = 'Neighboorhood';
    
    vBlock = 2250;
    vBandw = 2.0;
    vNeighb = 5.0;
    
    eTime1 = 'Time1_s';
    eTime2 = 'Time2_s';
    eTime3 = 'Time3_s';
    eTime4 = 'Time4_s';
    eTime5 = 'Time5_s';
    
    vTime1 = 0;
    vTime2 = 1.5;
    vTime3 = 3;
    vTime4 = 4.5;
    vTime5 = 10;
    
    eFreq1 = 'Freq1_Hz';
    eFreq2 = 'Freq2_Hz';
    eFreq3 = 'Freq3_Hz';
    eFreq4 = 'Freq4_Hz';
    eFreq5 = 'Freq5_Hz';
    
    switch kernel
        %set parameters for each kernel
        case '35M'
            vFreq1 = 47.6;
            vFreq2 = 46.8;
            vFreq3 = 46.1;
            vFreq4 = 45.3;
            vFreq5 = 44.9;
            vStartTime='Rounded';
        case '38H'
            vFreq1 = 47.9;
            vFreq2 = 47;
            vFreq3 = 46.1;
            vFreq4 = 45.6;
            vFreq5 = 45;
            vStartTime='Rounded';
        case '40H'
            vFreq1 = 47.6;
            vFreq2 = 46.6;
            vFreq3 = 46;
            vFreq4 = 45.3;
            vFreq5 = 44.9;
            vStartTime='Rounded';
        case '40M'
            vFreq1 = 47.3;
            vFreq2 = 46.6;
            vFreq3 = 45.7;
            vFreq4 = 45.1;
            vFreq5 = 44.8;
            vStartTime='Rounded';
        case '41H'
            vFreq1 = 46.9;
            vFreq2 = 46.2;
            vFreq3 = 45.4;
            vFreq4 = 45.1;
            vFreq5 = 44.7;
            vStartTime='Average';
        case '45M'
            vFreq1 = 47;
            vFreq2 = 45.9;
            vFreq3 = 45;
            vFreq4 = 44.9;
            vFreq5 = 44.3;
            vStartTime='Rounded';
        case '47M'
            vFreq1 = 46.8;
            vFreq2 = 45.8;
            vFreq3 = 45.1;
            vFreq4 = 44.9;
            vFreq5 = 43.9;
            vStartTime='Rounded';
        case '33M'
            vFreq1 = 47.8;
            vFreq2 = 47;
            vFreq3 = 46.2;
            vFreq4 = 45.8;
            vFreq5 = 44.9;
            vStartTime='Rounded';
        case '46M'
            vFreq1 = 46.7;
            vFreq2 = 46.3;
            vFreq3 = 45.6;
            vFreq4 = 44.9;
            vFreq5 = 43.9;
            vStartTime='Rounded';
        case '19A'
            vFreq1 = 48.2;
            vFreq2 = 47.4;
            vFreq3 = 46.8;
            vFreq4 = 46.5;
            vFreq5 = 45.9;
            vStartTime='Rounded';
        case '40N'
            vFreq1 = 47.5;
            vFreq2 = 46.6;
            vFreq3 = 45.9;
            vFreq4 = 45.2;
            vFreq5 = 44.8;
            vStartTime='Rounded';
        case '29H'
            vFreq1 = 47.5;
            vFreq2 = 47.1;
            vFreq3 = 46.4;
            vFreq4 = 46;
            vFreq5 = 45.4;
            vStartTime='Rounded';
        case '26H'
            vFreq1 = 48.4;
            vFreq2 = 47.6;
            vFreq3 = 46.9;
            vFreq4 = 46.4;
            vFreq5 = 45.6;
            vStartTime='Rounded';
         case '18H'
            vFreq1 = 48.9;
            vFreq2 = 48.1;
            vFreq3 = 47.2;
            vFreq4 = 46.7;
            vFreq5 = 45.8;
            vStartTime='Rounded';
    end
    
    %create XML tags for each parameter..(a bit sloppy)
    tags=[Tag(eTime1,vTime1),Tag(eFreq1,vFreq1),...
        Tag(eTime2,vTime2),Tag(eFreq2,vFreq2),...
        Tag(eTime3,vTime3),Tag(eFreq3,vFreq3),...
        Tag(eTime4,vTime4),Tag(eFreq4,vFreq4),...
        Tag(eTime5,vTime5),Tag(eFreq5,vFreq5),...
        Tag(eStartTime,vStartTime),Tag(eBlock,vBlock),...
        Tag(eBandw,vBandw),Tag(eThresh,vThresh),...
        Tag(eNeighb,vNeighb)];
    
    if length(start_column)==length(score_column)
        for i=1:length(start_column)
            start = dbSerialDateToISO8601(datenum(start_column{i}));
            oed=Detection(start, speciesID);
            oed.parameters.setScore(score_column(i));
            oed.popParameters();
            det.addDetection(oed);
        end
    else
        disp('Start time and Score columns do not match up!');
        disp(['Please verify: ',filename]);
        break;
    end
    det.setUserID(userID);
    det.setSite(project,site,depl);
    det.setEffort(effStart, effEnd);
    det.addKind(speciesID,{granularity,call});
    det.setAlgorithm({soft,version, method});
    det.addAlgorithmParameters(tags);
    det.marshal(xml_out);
    disp(['[',num2str(xidx), '/', count, ']',filename,' has been coverted to XML']);
end

