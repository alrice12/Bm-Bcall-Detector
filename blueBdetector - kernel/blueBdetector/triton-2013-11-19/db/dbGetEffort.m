function [Effort, Characteristics] = dbGetEffort(queryEng, varargin)
% [Effort Characteristics] = dbGetDetections(queryEngine, Arguments)
% Retrieve effort information from Tethys detection effort records.
% Effort is a matrix of Matlab serial dates containing the start and
% end times in each row.  Characteristics is a structure array whose
% elements correspond to each row of the Effort matrix and characterize
% the effort (i.e. which species, site, etc.)
%
% queryEngine must be a Tethys database query object, see dbDemo() for an
% example of how to create one.
%
% To query for specific types of effort, use one of the following
% keywords as a string followed by the desired value to be queried:
% species is the desired species.
%
% Attributes associate with project metadata:
% 'Project', string - Name of project data is associated with
% 'Region', string - Geographic region, e.g. SOCAL
% 'Site', string - name of location where data was collected
% 'Deployment', comparison - Which deployment of sensor at a given location
% Attributes associated with how detections were made:
% 'Detector', string - Name of detector, e.g. human
% 'Version', string - What version of the detector
% 'Parameters', string - Parameters given to the detector, for humans,
%   we use the individual's user id.
% Attributes associated with species effort
% 'SpeciesID' - species/family/order/... name.  Format depends on the last
%    call to dbSpeciesIDFmt.  
% 'Call'
% 'Subtype'
% 'Group' - Species Group
% 'Granularity' - Type of effort
% 'BinSize_m' - Binsize in minutes
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
% dbGetEffort(qengine, 'Region', 'SOCAL', 'Species', 'Lo')
% 
% The same query could be run for the 35th deployment by adding:
%      'Deployment', 35
% or for deployments >= 35 with
%      'Deployment', {'>=', 35}
%
% Retrieve the effort associated with the submitted document
% SOCAL41N_Humpback_ajc
% dbGetEffort(qengine, ...
%    'Document', 'dxmls:///Detections/SOCAL41N_Humpback_ajc')

meta_conditions = '';  % selection criteria for detection meta data
det_conditions = '';  % selection criteria for detections

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
            comparison = sprintf('base-uri($detgroup) = "%s"', varargin{idx+1});
            meta_conditions = sprintf('%s%s %s', ...
                meta_conditions, conj_meta, comparison); 
            conj_meta = ' and';
            idx = idx+2;    
        case {'Method', 'Software', 'Version'}
            meta_conditions = ...
                sprintf('%s%s upper-case($detgroup/Algorithm/%s) = upper-case("%s")', ...
                    meta_conditions, conj_meta, varargin{idx}, varargin{idx+1});
            conj_meta = ' and';
            idx = idx+2;
            
        % DataSource details
        case {'Project', 'Site'}
            meta_conditions = ...
                sprintf('%s%s upper-case($detgroup/DataSource/%s) = upper-case("%s")', ...
                    meta_conditions, conj_meta, varargin{idx}, varargin{idx+1});
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
            varargin{idx+1} = sprintf(dbSpeciesFmt('GetInput'), varargin{idx+1});
            det_conditions = ...
                sprintf('%s%s $k/%s = %s', ...
                det_conditions, conj_det, ...
                varargin{idx}, varargin{idx+1});
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
            det_conditions = ...
                sprintf('%s%s $k/%s = "%s"', ...
                det_conditions, conj_det, ...
                varargin{idx}, varargin{idx+1});
            conj_det = ' and';
            idx = idx + 2;
        case 'BinSize_m'
            det_conditions = ...
                sprintf('%s%s %s', ...
                    det_conditions, conj_det, ...
                    dbRelOp(varargin{idx}, '$k/Granularity/@BinSize_m', ...
                        varargin{idx+1}));                   
                conj_det = 'and';
                idx = idx + 2;
        otherwise
            error('Bad arugment:  %s', varargin{idx});
    end
end

% Build the query string
query_str = dbGetCannedQuery('GetEffort.xq');
source = 'collection("Detections")/ty:Detections';
outfmt = sprintf(dbSpeciesFmt('GetOutput'), '$tmp');

query = sprintf(query_str, source, meta_conditions, det_conditions, outfmt);

% Run the query and retrieve the document
dom = queryEng.QueryReturnDoc(query);

% discard namespace and attributes, we don't need them
% and it clutters up the tree
options.KeepNS = false;
options.ReadAttr = true;
options.NoCells = true;
options.SeparateAttr = true;

[tree, tree_read] = xml_read(dom, options);  % extract structure
if isempty(tree) || ~isfield(tree, 'Effort')
    Effort = [];
    Characteristics = [];
else
    Characteristics = tree.Effort;
    % convert effort strings to Matlab serial date
    Effort = zeros(length(Characteristics), 2);
    Effort(:, 1) = dbISO8601toSerialDate({Characteristics.Start});
    Effort(:, 2) = dbISO8601toSerialDate({Characteristics.End});
    
    if ~ issorted(Effort(:,1))
        % should be sorted, problems with query
        fprintf('Sorting effort\n');
        [dontcare, perm] = sort(Effort(:,1));
        Effort = Effort(perm,:);
        Characteristics = Characteristics(perm);
    end
end




1;


