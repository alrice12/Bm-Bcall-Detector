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
% 'Detector', string - Name of detector, e.g. human
% 'Version', string - What version of the detector
% 'Parameters', string - Parameters given to the detector, for humans,
%   we use the individual's user id.
%
% Attributes associated with detections
% 'SpeciesID', string  - species or category of sound
% 'Call_type', string - type of call/sound
% 'Call_type/@Subtype', string - subtype of call
%
% Comparison consists of either a:
%   scalar - queries for equality
%   cell array {operator, scalar} - Operator is a relational
%       operator in {'=', '<', '<=', '>', '>='} which is compared
%       to the specified scalar.
%
% 'Duration', N - When present, detections without a stop time
%    are interpreted as having fixed duration, and the end
%    time is set to start time + N.  (Default N=0)
%    Example:  60 m duration:  'Duration', datenum([0 0 0 1 0 0])
%    Note that when duration is set, two columns will always be
%    returned, even if there are no end times in the requested
%    detections.
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


event_duration = 0;
meta_conditions = '';  % selection criteria for detection meta data
det_conditions = '';  % selection criteria for detections
return_elements = {}; % List of additional elements that will be returned
effort = 'OnEffort';
idx=1;
% condition prefix/cojunction
% First time used contains where to form the where clause.
% On subsequent uses it is changed to the conjunction and
conj_meta = 'where';  
conj_det = 'where';
while idx < length(varargin)
    switch varargin{idx}
        case 'Document'
            comparison = sprintf('base-uri($det) = "%s"', varargin{idx+1});
            meta_conditions = sprintf('%s%s %s', ...
                meta_conditions, conj_meta, comparison); 
            conj_meta = ' and';
            idx = idx+2;            
        case {'Method', 'Software', 'Version'}
            meta_conditions = ...
                sprintf('%s%s upper-case($det/Algorithm/%s) = upper-case("%s")', ...
                    meta_conditions, conj_meta, varargin{idx}, varargin{idx+1});
            conj_meta = ' and';
            idx = idx+2;
            
        % DataSource details
        case {'Project', 'Site'}
            meta_conditions = ...
                sprintf('%s%s upper-case($det/DataSource/%s) = upper-case("%s")', ...
                    meta_conditions, conj_meta, varargin{idx}, varargin{idx+1});
            conj_meta = ' and';
            idx = idx+2;
        case 'Deployment'
            comparison = dbRelOp(varargin{idx}, '$det/DataSource/%s', varargin{idx+1});
            meta_conditions = sprintf('%s%s %s', ...
                meta_conditions, conj_meta, comparison); 
            conj_meta = ' and';
            idx = idx+2;            
        case { 'Effort/Start', 'Effort/End'}
            comparison = dbRelOpChar(varargin{idx}, ...
                '$det/%s', varargin{idx+1}, false);
            meta_conditions = sprintf('%s%s %s', ...
                meta_conditions, conj_meta, comparison); 
            conj_meta = ' and';
            idx = idx+2;
        case {'Effort'}
            % detections after this are 'On' effort, 'Off' effort, or
            % both *
            switch varargin{idx+1}
                case 'On', effort='OnEffort';
                case 'Off', effort='OffEffort';
                case {'Both', '*'}, effort='*';
                otherwise
                    error('Bad effort specifciation');
            end
            idx=idx+2;
        case 'SpeciesID'
            varargin{idx+1} = sprintf(dbSpeciesFmt('GetInput'), varargin{idx+1});
            det_conditions = ...
                sprintf('%s%s $detection/%s = %s', ...
                det_conditions, conj_det, ...
                varargin{idx}, varargin{idx+1});
            conj_det = ' and';
            idx = idx + 2;            
        case {'Call'}
            det_conditions = ...
                sprintf('%s%s $detection/%s = "%s"', ...
                det_conditions, conj_det, varargin{idx}, varargin{idx+1});
            conj_det = ' and';
            idx = idx+2;
        case {'Subtype'}
            det_conditions = ...
                sprintf('%s%s $detection/Parameters/Subtype = "%s"', ...
                det_conditions, conj_det, varargin{idx}, varargin{idx+1});
            conj_det = ' and';
            idx = idx+2;
        case 'Duration'
            event_duration = varargin{idx+1};
            if ~ isscalar(event_duration)
                error('%s must be scalar', varargin{idx+1})
            end
            idx = idx+2;
            
        case 'Return'
            % Provide additional return values
            return_elements{end+1} = varargin{idx+1};
            idx=idx+2;
            
        otherwise
            error('Bad arugment:  %s', varargin{idx});
    end
end

query_str = dbGetCannedQuery('GetDetections.xq');

source = 'collection("Detections")/ty:Detections';
if length(return_elements) > 0
    additional_info = sprintf('{$detection/%s}\n', return_elements{:});
else
    additional_info = '';
end
query = sprintf(query_str, source, meta_conditions, effort, ...
    det_conditions, additional_info);
dom = queryEngine.QueryReturnDoc(query);

% Assume only start times until we know better
EndP = [];

% Retrieve detection records from document model
if isempty(dom)
    timestamps = [];
    deploymentIdx = [];
    deployments = [];
else
    [timestamps, missingP] = dbParseDates(dom);
    EndCount = sum( ~missingP(:,end));
    
    if EndCount == 0 
        % No end times were detected
        if event_duration == 0
            timestamps(:, 2) = [];  % No duration, remove end time
        else
            % Set interval to specified duration
            % Note that there is no guarantee that this will not create
            % overlapping events.
            timestamps(:, 2) = timestamps(:, 1) + event_duration;
        end
    end
    
    if nargout > 2
        indices = dom.item(0).getElementsByTagName('idx');
        indicesN = indices.getLength();
        info.deploymentIdx = zeros(indicesN, 1);
        for idx=1:indicesN
            info.deploymentIdx(idx) = str2double(indices.item(idx-1).getFirstChild().getNodeValue());
        end
        depdom = dbXPathDomQuery(dom, 'ty:Result/Sources');
        deploymentsN = depdom.item(0).getLength();
        info.deployments = struct('EnsembleName', cell(deploymentsN,1), 'Project', cell(deploymentsN,1), 'Deployment', cell(deploymentsN,1), 'Site', cell(deploymentsN,1), 'Cruise', cell(deploymentsN,1));
        for idx = 1:deploymentsN
            item = depdom.item(0).item(idx-1);
            for childidx = 1:item.getLength()
                child = item.item(childidx-1);
                field = char(child.getNodeName());
                if strcmp(field, '#text')  % we don't care about extraneous text
                    continue
                end
                value = char(child.getFirstChild().getNodeValue());
                dvalue = str2double(value);
                if ~ isnan(dvalue)
                   value = dvalue;
                end
                info.deployments(idx).(field) = value;
            end
        end
        
        N = size(timestamps, 1);
        warnings = {};
        if length(return_elements) > 0
            % Pull out requested elements
            for idx=1:length(return_elements)
                slashes = strfind(return_elements{idx}, '/');
                if isempty(slashes)
                    fieldnm = return_elements{idx}
                else
                    fieldnm = return_elements{idx}(slashes(end)+1:end);
                end
                fielddom = dbXPathDomQuery(dom, sprintf('ty:Result/Detections/Detection/%s', fieldnm));
                fieldN = fielddom.getLength();
                if fieldN ~= N
                    % Some of the detections didn't have this element
                    warnings{end+1} = return_elements{idx};
                end
                info.(fieldnm) = cell(fieldN, 1);
                for item = 1:fieldN
                    info.(fieldnm){item} = char(fielddom.item(item-1).getFirstChild().getNodeValue());
                end                            
            end
            if length(warnings) > 0
                warning(['Fields [', sprintf('%s ', warnings{:}), ...
                    '] are not present in all detections.  ', ...
                    'They will not line up with the detections.']); 
            end
        end
    end
    
end
