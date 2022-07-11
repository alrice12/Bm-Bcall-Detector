function [Effort, Characteristics] = dbGetEffort(queryEng, varargin)
% [Effort Characteristics] = dbGetDetections(queryEngine, Arguments)
% Retrieve effort information from Tethys detection effort records.
% Effort is a matrix of Matlab serial dates containing the start and
% end times in each row.  Characteristics is a structure array whose
% elements correspond to each row of the Effort matrix and characterize
% the effort (i.e. which species, site, etc.)
%
% queryEng must be a Tethys database query object, see dbDemo() for an
% example of how to create one.
%
% To query for specific types of effort, use one of the following
% keywords as a string followed by the desired value to be queried:
%
%
% Attributes associate with project metadata:
% 'Project', string or cell array - Name of project data is associated with,
%           e.g. SOCAL. For multiple projects, lists can be entered, e.g.
%           {'SOCAL','CINMS'}
% 'Site', string or cell array - name of location where data was collected,
%           For multiple sites, lists can be entered, e.g.
%           {'A2','M'}
% 'Cruise', comparison - Cruise associated with effort
% 'Deployment', comparison - Which deployment of sensor at a given location
% 'UserID', string - User that prepared data
% Attributes associated with how detections were made:
% 'Effort/Start'|'Effort/End', String - Specify start and or end of
%       detection effort.  Note that this is a direct comparison to the
%       effort start or end, not to the interval.  As an example,
%       effort between 2015-01-01T00:00:00Z and 2015-03-0112:00:00Z would
%       not be picked up if with Effort/Start, {'>=', '2015-02-01T00:00:00Z'}
%       as this is after the start of the deployment.
% 'Software', string - Name of detector software, e.g. analyst, silbido
% 'Version', string - What version of the detector
% 'Parameters', string - Parameters given to the detector, for humans,
%   we use the individual's user id.
% Attributes associated with species effort
% 'SpeciesID' - species/family/order/... name.  Format depends on the last
%    call to dbSpeciesFmt.
% 'Call' - type of call
% 'Subtype' - subtype of call
% 'Group' - Species Group
% 'Granularity' - Type of effort
% 'BinSize_m' - Binsize in minutes
% 'ShowQuery', true|false (Default)- Display the constructed XQuery
%
% Attributes whose argument is comparison can either be a:
%   scalar - queries for equality
%   cell array {operator, scalar} - Operator is a relational
%       operator in {'=', '<', '<=', '>', '>='} which is compared
%       to the specified scalar.
%
% One can also query for a specific document by using the document id
% in the detections collection:
% 'Document', DocID - DocId is 'dbxml:///Detections/document_name'
%     At the time of this writing, document names are derived from the
%     source spreadsheet name.  Document names can also be obtained
%     from the results of this function, by inspecting the XML_Document
%     field of the Characteristics array.
%
% Examples:  Retrieve effort to detect Pacific white-sided dolphins
% from Southern California regardless of project.  Note that when
% multiple attirbutes are specified, all criterai must be satisfied.
%
% dbGetEffort(qengine, 'Project', 'SOCAL', 'SpeciesID', 'Lo')
%
% The same query could be run for the 35th deployment by adding:
%      'Deployment', 35
% or for deployments 35-50 with
%      'Deployment', {'>=', 35}, 'Deployment', {'<=', 50}
%
% Retrieve the effort associated with the submitted document
% SOCAL41N_Humpback_ajc
% dbGetEffort(qengine, ...
%    'Document', 'dbxml:///Detections/SOCAL41N_Humpback_ajc')



%OVERLAP CHECK ONLY WHEN 'SITE' Input
%spatial -- radius input 
%bounding box 

% 


meta_conditions = '';  % selection criteria for detection meta data
det_conditions = '';  % selection criteria for detections
show_query = false; % do not display XQuery
overlap_restr_counter = 0; %if project & site/cruise entered, we check for overlap
check_overlap = true;

idx=1;
% condition prefix/cojunction
% First time used contains where to form the where clause.
% On subsequent uses it is changed to the conjunction and
conj_meta = 'where';
conj_det = 'where';
document = [];
while idx <= length(varargin)
    switch varargin{idx}
        case 'Document'
            comparison = dbListMemberOp('base-uri($detgroup)', varargin{idx+1});
            meta_conditions = sprintf('%s%s %s', ...
                meta_conditions, conj_meta, comparison);
            conj_meta = ' and';
            idx = idx+2;
        case {'Method', 'Software', 'Version'}
            
            if iscell(varargin{idx+1})
                op = varargin{idx+1}{1};
                value = varargin{idx+1}{2};
                switch(op)
                    case '!='
                        meta_conditions = ...
                            sprintf('%s%s upper-case($detgroup/Algorithm/%s) %s upper-case("%s")', ...
                            meta_conditions, conj_meta, varargin{idx},op, value);
                end
            else
                meta_conditions = ...
                    sprintf('%s%s upper-case($detgroup/Algorithm/%s) = upper-case("%s")', ...
                    meta_conditions, conj_meta, varargin{idx}, varargin{idx+1});
            end
            conj_meta = ' and';
            idx = idx+2;
            
        case 'UserID'
            meta_conditions = sprintf('%s%s $detgroup/%s = "%s"', ...
                meta_conditions, conj_meta, ...
                varargin{idx}, varargin{idx+1});
            conj_meta = ' and';
            idx = idx+2;
            %QA
        case 'QualityAssurance'
            %if true, check exists
            if varargin{idx+1} == true
                meta_conditions = sprintf('%s%s exists($detgroup/%s) and not(number(lib:if-empty($detgroup/%s/Description,0)) = 0)', ...
                    meta_conditions, conj_meta, ...
                    varargin{idx},varargin{idx});
            else %otherwise, not exists
                meta_conditions = sprintf('%s%s (not(exists($detgroup/%s)) or number(lib:if-empty($detgroup/%s/Description,0)) = 0)', ...
                    meta_conditions, conj_meta, ...
                    varargin{idx},varargin{idx});
            end
            conj_meta = ' and';
            idx = idx+2;
            % DataSource details
        case {'Project', 'Site'}
            overlap_restr_counter = overlap_restr_counter + 1;
            field = sprintf('$detgroup/DataSource/%s', varargin{idx});
            meta_conditions = ...
                sprintf('%s%s %s', ...
                meta_conditions, conj_meta, dbListMemberOp(field, varargin{idx+1}));
            conj_meta = ' and';
            idx = idx+2;
        case 'Cruise'
            field = sprintf('$detgroup/DataSource/%s', varargin{idx});
            meta_conditions = ...
                sprintf('%s%s %s', ...
                meta_conditions, conj_meta, dbListMemberOp(field, varargin{idx+1}));
            conj_meta = ' and';
            idx = idx+2;
        case { 'Effort/Start', 'Effort/End'}
            comparison = dbRelOp(varargin{idx}, ...
                '$detgroup/%s', varargin{idx+1}, false);
            meta_conditions = sprintf('%s%s %s', ...
                meta_conditions, conj_meta, comparison);
            conj_meta = ' and';
            idx = idx+2;
        case 'Deployment'
            comparison = dbRelOp(varargin{idx}, '$detgroup/DataSource/%s', varargin{idx+1});
            meta_conditions = sprintf('%s%s %s', ...
                meta_conditions, conj_meta, comparison);
            conj_meta = ' and';
            idx = idx+2;
        case 'SpeciesID'
            % Build up list of possible species ids
            if ~ iscell(varargin{idx+1})
                varargin{idx+1} = {varargin{idx+1}};
            end
            % Add fns to translate to TSN from current format
            varargin{idx+1} = cellfun(@(x) ...
                sprintf(dbSpeciesFmt('GetInput'), x), varargin{idx+1}, ...
                'UniformOutput', false);
            comparison = dbListMemberOp(...
                sprintf('$k/%s', varargin{idx}), varargin{idx+1}, false);
            det_conditions = sprintf('%s%s %s', ...
                det_conditions, conj_det, comparison);
            conj_det = ' and';
            idx = idx + 2;
        case {'Call', 'Granularity', 'Group', 'Subtype'},
            switch varargin{idx}
                case 'Subtype'
                    % Call Subtype is part of parameters
                    varargin{idx} = 'Parameters/Subtype';
                case 'Group'
                    % Group is an attribute of SpeciesID
                    varargin{idx} = 'SpeciesID/@Group';
            end
            comparison = dbListMemberOp(...
                sprintf('$k/%s', varargin{idx}), varargin{idx+1});
            det_conditions = ...
                sprintf('%s%s %s', det_conditions, conj_det, comparison);
            conj_det = ' and';
            idx = idx + 2;
        case 'BinSize_m'
            det_conditions = ...
                sprintf('%s%s %s', ...
                det_conditions, conj_det, ...
                dbRelOp(varargin{idx}, '$k/Granularity/@BinSize_m', ...
                varargin{idx+1}));
            conj_det = ' and';
            idx = idx + 2;
        case 'ShowQuery'
            show_query = varargin{idx+1};
            idx = idx+2;
        case 'UserDefined'
            %not implemented for effort
            1;
            idx = idx+2;
            
        case 'OverlappingEffort'
            switch lower(varargin{idx+1})
                case 'error'
                case 'warning'
                    ovrlp_warn = true;
                case 'ignore'
                    check_overlap = false;
            end
        otherwise
            error('Bad arugment:  %s', varargin{idx});
    end
end

if overlap_restr_counter >= 2 && check_overlap
    check_overlap = true;
else
    check_overlap = false;
end

% Build the query string
query_str = dbGetCannedQuery('GetEffort.xq');

source = 'collection("Detections")/ty:Detections';
outfmt = sprintf(dbSpeciesFmt('GetOutput'), '$tmp');

query = sprintf(query_str, source, meta_conditions, det_conditions, outfmt);
%%% Display XQuery
if show_query
    fprintf(query);
end
%
%Run the query and retrieve the document
xmljavastr = queryEng.Query(query);
xml = char(xmljavastr);  % Convert to Matlab string


if false
    % discard namespace and attributes, we don't need them
    % and it clutters up the tree
    options.KeepNS = false;
    options.ReadAttr = true;
    options.NoCells = true;
    options.SeparateAttr = true;
    
    [tree, tree_read] = xml_read(dom, options);  % extract structure
end

%A map of types to send to the wrapper, in Key/Value pairs
%Each key represents an element name, and the value reps their return type.
typemap={
    'idx','double';...
    'Deployment','double';...
    'Start','datetime';...
    'End','datetime';...
    };
tree = tinyxml2_tethys('parse', xml, typemap);

if isempty(tree) || ~isfield(tree, 'Effort')
    Effort = [];
    Characteristics = [];
else
    Characteristics = tree.Effort;
    % convert effort strings to Matlab serial date
    N = length(Characteristics);
    Effort = zeros(N, 2);
    for idx = 1:N
        % Convert date vectors to datenum
        Effort(idx, 1) = datenum(Characteristics(idx).Start{1});
        Effort(idx, 2) = datenum(Characteristics(idx).End{1});
    end
    
    if ~ issorted(Effort(:,1))
        % should be sorted, problems with query
        fprintf('Sorting effort\n');
        [~, perm] = sort(Effort(:,1));
        Effort = Effort(perm,:);
        Characteristics = Characteristics(perm);
    end

    
    species_datasource_map = containers.Map();
    %each key will be a effort species, each value will be a struct containing the
    %datasource
    
    
    
    if check_overlap
        overlaps = containers.Map();
        
        
        species_call_map = containers.Map();
        for cidx = 1:length(Characteristics)
            for kidx = 1:length(Characteristics(cidx).Kind)
                species = Characteristics(cidx).Kind(kidx).SpeciesID{1};
                call = Characteristics(cidx).Kind(kidx).Call{1};
                
                %subtype...
                if isfield(Characteristics(cidx).Kind(kidx),'Parameters') &&~isempty(Characteristics(cidx).Kind(kidx).Parameters);
                    call = strjoin({call,Characteristics(cidx).Kind(kidx).Parameters.Subtype{1}},'.');
                end

                if ~species_call_map.isKey(species)
                    %first time, create the call map for this spp
                    species_call_map(species)= containers.Map();
                end
                %pull out the call map  
                call_map = species_call_map(species);
                if ~call_map.isKey(call)
                    %no index for this call yet
                    call_map(call) = [];
                end
                %pull array out
                idx_array = call_map(call);
                %add to array
                idx_array(end+1) = cidx;
                %send array back to call_map
                call_map(call) = idx_array;
            end
        end

        %now pull out the keys
        spp_keys = species_call_map.keys();
        for sp_k = spp_keys
            %get the call keys for this species
            call_keys = species_call_map(sp_k{1}).keys;
            for call_k = call_keys
                %get the map for this key
                call_map = species_call_map(sp_k{1});
                %pull out the efforts for this call
                effort_indices = call_map(call_k{1});
                efforts = Effort(effort_indices,:);

                %check overlap of efforts
                
                efforts = sortrows(efforts,1);
            
                total = size(efforts,1);
                overlapping = []; %for this call/sp combo
                for j = total-1:-1:1
                    lower_idx = j+1;
                    upper_idx = j;
                    %uprLt = efforts(lower_eff,1);
                    lwrLt = efforts(lower_idx,1);
                    uprRt = efforts(upper_idx,2);
                    %lwrRt = efforts(lower_eff,2);
                    isOverlap = (lwrLt <= uprRt + 0.0375);
                    if isOverlap
                        %note which documents have overlapping effort
                        overlapping(end+1) = lower_idx;
                        overlapping(end+1) = upper_idx;
                    end
                end
                
                overlapping = unique(overlapping);
                
                if ~isempty(overlapping)
                    overlapping_indices = effort_indices(overlapping);
                    overlaps(strjoin([sp_k,call_k])) = unique([Characteristics(overlapping_indices).XML_Document]);
                end
                
                
            end
        end
        
        %report overlapping documents/calls/species to user
        if ~overlaps.isempty
            warning('Overlapping effort detected for the calls/species below:')
            %report range of overlap
            %string to report if overlap was checked
            %add field for overlap in characteristics, as a struct
            %containing:   dates, docs,
            

            for k = overlaps.keys
                fprintf('%s:\n',k{1});
                for doc =overlaps(k{1})
                    fprintf('%s\n',doc{1});
                end
                fprintf('\n');
            end
        end
    
    end%if
    
end




1;


