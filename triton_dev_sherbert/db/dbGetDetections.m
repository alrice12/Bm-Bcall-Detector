function [timestamps, EndP, info] = dbGetDetections(queryEngine, varargin)
% [timestamps, endPredicate, deploymentIdx, deployments] = dbGetDetections(queryEngine, Optional Args)
% Retrieve detections meeting criteria from database.  Detections
% are returned as a timestamps matrix of Matlab serial dates (see
% datenum).  The timestamps will either be single times that represent
% a detection within a binned interval, or span a time interval.  If the
% bin interval time is desired, sue the 'Duration' parameter that is
% documented below.
%
% The optional endP return value allows callers to distinguish between
% interval and instantaneous detections.  Its usage is described at the
% example at the end of this help.
%
% The optional output info is a structure variable.  If requested, it
% contains the following fields:
%   deployments - An array of structures that can be used to identify
%       the deployments associated with the retrieved detections.
%   deploymentIdx - A vector with the same number of rows as detections
%       returned (number of rows in timestamps).  Each item is an index
%       into the deployments array indicating which deployment the
%       detection originated from.
%   Other fields may be populated based on parameters passed to the
%       optional input 'Return'
%
% Inputs:
% queryEngine must be a Tethys database query object, see dbDemo() for an
% example of how to create one.
%
% To query for specific types of detections, use any combination of the
% following keyword/value pairs:
%
% Attributes associated with project metadata:
% 'Project', string - Name of project data is associated with
% 'Site', string - name of location where data was collected
% 'Deployment', comparison - Which deployment of sensor at a given location
%
% Attributes associated with how detections were made:
% 'Effort', ('On') | 'Off', Specify effort type. Query time may slow down
%                           if using 'Off'.
% 'Method', string - Method of detection
%           e.g. analyst, Spectrogram Correlation
% 'Software', string - Name of detector, e.g. analyst, silbido
% 'Version', string - What version of the detector
% 'UserDefined' - used to specify UserDefined parameters, cell array
% containing {'ParamName','ParamValue}. Can also use the 'contains' keyword
% inbetween the two, to search a substring of ParamValue
% 'UserID', string - User responsible for the analysis
%
% 'Effort/Start'|'Effort/End', string comparison - Specify start and or end of
%       detection effort.  Note that this is a direct comparison to the
%       effort start or end, not to the interval.  As an example,
%       effort between 2015-01-01T00:00:00Z and 2015-03-0112:00:00Z would
%       not be picked up if with Effort/Start, {'>=', '2015-02-01T00:00:00Z'}
%       as this is after the start of the deployment.
%
% Attributes associated with detections
% 'SpeciesID', string  - species or category of sound
% 'Group', string - species group e.g. BW43
% 'Call', string - type of call/sound
% 'Subtype', string - subtype of call
%
% Comparison consists of either a:
%   scalar - queries for equality
%   cell array {operator, scalar} - Operator is a relational
%       operator in {'=', '<', '<=', '>', '>='} which is compared
%       to the specified scalar.
%
% One can also query for detections froma specific document by using the
%  document id in the detections collection:
% 'Document', DocID - DocId is 'dbxml:///Detections/document_name'
%     At the time of this writing, document names are derived from the
%     source spreadsheet name.
%
% Other optional arguments:
% 'Return', string - Return an additional field, e.g.
%   'Return', 'File'
% 'Duration', N - When present, detections without a stop time
%    are interpreted as having fixed duration, and the end
%    time is set to start time + N.  (Default N=0)
%    Example:  60 m duration:  'Duration', datenum([0 0 0 1 0 0])
%    Note that when duration is set, two columns will always be
%    returned, even if there are no end times in the requested
%    detections.
% 'ShowQuery', true|false (Default)- Display the constructed XQuery
% 'DomParse', true|false (Default) - parse times using the older, slower
% DOM method. Linux users may need to set to true as the new parser was
% compiled for Windows.
% 'Benchmark', string - path to write performance files if desired.
%
% Example:  Retrieve all detections for Pacific white-sided dolphins
% from Southern California regardless of project.  Note that when
% multiple attirbutes are specified, all criterai must be satisfied.
% [detections, endP] = dbGetDetections(qengine, ...
%                         'Project', 'SOCAL', 'Species', 'Lo');
%
% Output is a one or two column matrix of start and (if available) end
% times of detections.  If the result contains instantaneous detections
% and two columns are returned due to interval detections also being
% present, the time end predicate (endP) can be used to determine
% which is which.  Where endP(row_idx) = 1, detections(row_idx, :) will
% be an interval detection.  Accordingly, a 0 indicates an instantaneous
% detection.
% Example: [detections, endP] = dbGetDetections(...);
% Interval detections: detections(endP, :)
% Instantaneous detections:  detections(~endP, 1)


%parse varargs, pull out flags
[meta_conditions, effort, det_conditions,...
    flags,return_elements] = ...
    dbParseGetDetectionArgs(queryEngine,varargin);

query = dbBuildDetectionXquery(meta_conditions, effort, det_conditions,return_elements);

% Display XQuery
if flags.show_query
    fprintf(query);
end

if flags.benchmark
    tic;
end
tic;
%Execute XQuery
if ~flags.dom_parse
    dom = queryEngine.Query(query);
else
    dom = queryEngine.QueryReturnDoc(query);
end
e=toc;
if flags.benchmark
    q_elapsed = toc;
end

%time it
if flags.benchmark
    tic;
end

if ~flags.dom_parse
    [timestamps,EndP,info] = dbXmlDetParse(dom,return_elements);
else
    [timestamps,EndP,info] = dbDomDetParse(dom,return_elements);
end


if flags.benchmark && ~isempty(timestamps)
    info.elapsed.query = q_elapsed;
    elapsed = toc;
    %fprintf('Parsing elapsed_s: %.03f\n',elapsed);
    info.elapsed.parse = elapsed;
    if ~isfield(flags,'bench_path')
        dbWriteBench(info.elapsed.query,info.elapsed.parse,meta_conditions,det_conditions,length(timestamps));
    else
        dbWriteBench(info.elapsed.query,info.elapsed.parse,meta_conditions,det_conditions,length(timestamps),'Dir',flags.bench_path);
    end
end