function [deployments, dom] = dbDeploymentInfo(query_eng, varargin)
% [deployments, dom] = dbDeploymentInfo(query_eng, OptArgs)
% Returns an array where each element is a structure
% with fields about fixed deployments.  Records are selected 
% based on the following optional arguments which fall into two
% categories
%
% Equality checks:  Specified value must be equal (case independent)
% to the string provided
% 'Project', string
% 'Region', string
% 'Site', string
%
% Floating point comparisions:  
% 'DeploymentId', Comparison
% 'DeploymentDetails/Latitude', Comparison
% 'DeploymentDetails/Longitude', Comparison
% 'DeploymentDetails/Depth_m', Comparison
% Comparison consists of either a:
%   scalar - queries for equality
%   cell array {operator, scalar} - Operator is a relational
%       operator in {'=', '<', '<=', '>', '>='} which is compared
%       to the specified scalar.


meta_conditions = '';  % selection criteria for detection meta data

% condition prefix/cojunction
% First time used contains where to form the where clause.
% On subsequent uses it is changed to the conjunction and
conj_meta = 'where';
idx=1;
while idx < length(varargin)
    switch varargin{idx}
        % Deployment details
        case {'Project', 'Region', 'Site'}
            meta_conditions = ...
                sprintf('%s%s upper-case($deployment/%s) = upper-case("%s")', ...
                meta_conditions, conj_meta, varargin{idx}, varargin{idx+1});
            conj_meta = ' and';
            idx = idx+2;
        case {'DeploymentID', 'DeploymentDetails/Latitude', ...
                'DeploymentDetails/Longitude', 'DeploymentDetails/DepthInstrument_m'}
            comparison = dbRelOp(varargin{idx}, ...
                '$deployment/%s', varargin{idx+1});
            meta_conditions = sprintf('%s%s %s', ...
                meta_conditions, conj_meta, comparison); 
            conj_meta = ' and';
            idx = idx+2;
        case {'DeploymentDetails/TimeStamp'}
            comparison = dbRelOpChar(varargin{idx}, ...
                '$deployment/%s', varargin{idx+1});
            meta_conditions = sprintf('%s%s %s', ...
                meta_conditions, conj_meta, comparison); 
            conj_meta = ' and';
            idx = idx+2;
        otherwise
            error('Bad argument %s', varargin{idx});
    end
end

% Run the query 
query_template = dbGetCannedQuery('GetDeployments.xq');
query_str = sprintf(query_template, meta_conditions);
%fprintf('------\n%s\n-----', query_str);  % show the query
dom = query_eng.QueryReturnDoc(query_str);
% convert to Matlab structure
[tree, tree_name] = xml_read(dom);
if isempty(tree) || (isfield(tree, 'CONTENT') && isempty(tree.CONTENT))
    deployments = [];
else
    deployments = tree.ty_COLON_Deployment;
end
1;
