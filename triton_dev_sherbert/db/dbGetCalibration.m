function [tf, date] = dbGetCalibration(queryH, Id, varargin)
% [tf, date] = dbGetCalibration(queryH, Id, OptionalArgs)
% Retrieve inverse sensitivity function for a given 
% preamp/hydrophone assemblage.  Date is returned as a
% Matlab serial date.
%
% Optional args:
%   'Timestamp', timestamp - 
%        'earliest' - Returns first calibration
%        'latest' - Returns last calibration
%        timestamp - Timestamps may be of the form:
%           Matlab serial date
%           ISO8601 string, e.g. 2012-12-12T12:12:12Z
%           Either one returns the last calibration before the
%           specified date.
%
% WARNING:  Experimental, we have not implemented anything yet
% for multiple calibrations although the database can contain
% calibrations done on different dates.


vidx = 1;
if isnumeric(Id)
    Id = num2str(Id);
end
where = sprintf('where $cal/ID = %s', char(Id));

% default - pick first one
timestamp = 'earliest';

while vidx < length(varargin)
    switch varargin{vidx}
        case 'Timestamp'
            timestamp = varargin{vidx+1};
            vidx = vidx + 2;
        otherwise
            error('Optional argument not implemented');
    end
end
            
queryStr = dbGetCannedQuery('GetCalibrations.xq');
query = sprintf(queryStr, where);

j_result = queryH.Query(query);
xml_result = char(j_result);
if isempty(xml_result)
    error('Unable to retreive calibration %s', Id);
end

%A map of types to send to the wrapper, in Key/Value pairs
%Each key represents an element name, and the value reps their return type.
typemap={
    'TimeStamp','datetime';...
    };
xml = tinyxml2_tethys('parse',xml_result,typemap);


if isempty(xml)
    error('Unable to retreive calibration %s', Id);
end


% How many calibrations did we retrieve
N = length(xml.('te:Calibration'));
calibrationdates = cellfun(@(x)(datenum(x{1})),{xml.('te:Calibration').TimeStamp});
if ~ issorted(calibrationdates)
    [calibrationdates, perm] = calibrationdates;
    xml.('te:Calibration')= xml.('te:Calibration')(perm);
end

switch timestamp
    case 'earliest'
        idx = 1;
    case 'latest'
        idx = N;
    otherwise
        if ischar(timestamp)
            target = dbISO8601toSerialDate(timestamp);
        else
            target = timestmap;
        end
        % Find closest calibration - experimental, might blow up
        delta = calibrationdates - target;
        possible = find(delta > 0);
        if isempty(possible)
            error('No calibration for %s after %s', Id, dbSerialDateToISO8601(target));
        end
        [~, smallest] = min(delta(possible));
        idx = possible(smallest);
end
        
tf = [str2double(strsplit(xml.('te:Calibration')(idx).FrequencyResponse.Hz{1})); ...
      str2double(strsplit(xml.('te:Calibration')(idx).FrequencyResponse.dB{1}))]';
date = datenum(xml.('te:Calibration')(idx).TimeStamp{1});
