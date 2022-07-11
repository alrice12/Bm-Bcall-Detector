function illu = dbGetLunarIllumination(query_eng, lat, long, start, stop, interval, varargin)
% illu = dbGetLunarIllumination(query_eng, lat, long, start, stop, interval, varargin)
% Return information from database about the lunar illumination percentage
% between the start and stop times in the specified interval.  
% illu(:,1) contains serial dates (datenums)
% illu(:,2) contains the percentage of lunar illumination 0-100
%
% Position is specified as decimal longitude [0-360) and latitude [-90 90].
% Negative latitudes indicate the southern hempisphere.
% Longitudes > 180 degrees are west.
%
% Optional arguments
% getDaylight true|false(default)
%   Return illumination during daylight hours as well?
% UTCOffset, N
%   Used to process queries and results in local time.  Specify the
%   offset from universal coordinated time.
%
% Example:  See dbLunarDemo.m
% Caveats:  Cloud cover is not taken into account



import org.apache.xmlrpc.XmlRpcException;

% defaults
getDaylight = false;
UTCOffset = 0;

vidx = 1;
while vidx < length(varargin)
    switch varargin{vidx}
        case 'getDaylight'
            getDaylight = varargin{vidx+1}; vidx=vidx+2;
        case 'UTCOffset'
            UTCOffset = varargin{vidx+1}; vidx=vidx+2;
            if ~isscalar(UTCOffset)
                error('UTCOffset must be scalar')
            end
        otherwise
            error('Bad argument %s', varargin{vidx+1});
    end
end

if interval > 30 && getDaylight == false
  error(['Interval of observations must be in [0, 30] to detect rise/set ' ...
         'times']);
end

if UTCOffset
    % difference from universal coordinated time
    offset = datenum(0,0,0, UTCOffset, 0,0) - datenum(0,0,0,0,0,0);
else
    offset = 0;
end

% Format query string:
queryStr = sprintf(['collection("ext:horizons")/', ...
    'target="moon"/latitude=%f/longitude=%f/', ...
    'start="%s"/stop="%s"/interval="%dm"!'], ...
    lat, long, ...
    datestr(start-offset, 'yyyy-mm-ddTHH:MM:SS'), ...
    datestr(stop-offset, 'yyyy-mm-ddTHH:MM:SS'), interval);

% Run XML query to retrieve illumination information
try
    doc = query_eng.QueryReturnDoc(queryStr);
catch e
    if ~isempty(findstr(e.message, 'getaddrinfo failed'))
        warning('getaddrinfo failed, unable to obtain ephemeris')
        illu = [];
        return
    else
       rethrow(e);
    end
end

% find day/night transitions
% day and or night may be repeated due to events such
% as moon rise/set/transit
[x, illumination] =  dbXPathDomQuery(doc, 'ephemeris/entry/illumination');
[y, tod] = dbXPathDomQuery(doc, 'ephemeris/entry/date');
[z, moon] = dbXPathDomQuery(doc, 'ephemeris/entry/moon');

MoonIndicator = ~strcmp(moon, 'no-moon');  % 0/1 lunar presence
if (getDaylight)
    % Get lunar illumination during day and night
    UseIndicator = MoonIndicator;
else
    % Get lunar illumination during night only
    [a, daylight] = dbXPathDomQuery(doc, 'ephemeris/entry/sun');
    NightIndicator = ~strcmp(daylight, 'day');
    UseIndicator = MoonIndicator & NightIndicator;
end


MoonEntries = sum(UseIndicator);
illu = zeros(MoonEntries, 2);

if (size(illumination) ~= size(tod))
    warning('improper ephemeris return')
    illu = [];
    return
end

idx = 1;
for index=find(UseIndicator')
    illu(idx,1) = datenum(tod{index});
    illu(idx,2) = str2double(illumination{index});
    idx = idx + 1;
end

if offset
    % Show results with appropriate time offset
    illu(:,1) = illu(:,1) + offset;
end
1;

