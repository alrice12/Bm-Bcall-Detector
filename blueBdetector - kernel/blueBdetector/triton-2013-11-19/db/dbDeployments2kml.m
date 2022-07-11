function dbDeployments2kml(query_h, kmlfile, varargin)
% dbDeployments2kml(query_h, kmlfile, Optional Args)
% Write a KML file with all deployments meeting the criteria
% and display them in Google Earth.  
% 
% See dbDeploymentInfo() for optional arguments, the same arguments
% are supported and permit selection criteria for deployments.
%
% Example:
% q = dbInit();  % set up query handler
% dbDeployments2kml(q, 'socal.kml', 'Project', 'SOCAL');

narginchk(2, Inf);

if ~ strcmp(which('kml'), '') == 0
    error('kml toolbox required:  http://www.mathworks.com/matlabcentral/fileexchange/34694-kml-toolbox-v2-6')
end    

Display = false;

% Where have our instruments been deployed
fprintf('Querying...\n');
deployments = dbDeploymentInfo(query_h, varargin{:});
fprintf('Found %d deployments, generating %s\n', length(deployments), kmlfile);

% Create project folders?
projects = unique({deployments.Project});

% Let's use the kmltoolbox to plot things
earth = kml(kmlfile);  

% Create project folders?
projects = unique({deployments.Project});
if length(projects) > 1
    for fidx=1:length(projects)
        fprojects(fidx) = earth.createFolder(projects{fidx});
    end
    folderIdx = zeros(length(deployments), 1);
    for didx= 1:length(deployments)
        folderIdx(didx) =  find(strcmp(deployments(didx).Project, projects));
    end
else
    fprojects(1) = earth;
    folderIdx = ones(length(deployments),1);
end

for idx=1:length(deployments)
    if isnumeric(deployments(idx).Site)
        % xml converter does not look at Schema and converts digits
        % to numbers
        site = num2str(deployments(idx).Site);
    else
        site = deployments(idx).Site;
    end
    siteid = sprintf('%s %s:%d', ...
                deployments(idx).Project, site, deployments(idx).DeploymentID);
            
    % Work around for HARP database inconsistencies
    if isfield(deployments(idx).DeploymentDetails, 'TimeStamp') && ...
            isfield(deployments(idx).RecoveryDetails, 'TimeStamp') && ...
        ~ isempty(deployments(idx).DeploymentDetails.TimeStamp) && ...
        ~ isempty(deployments(idx).RecoveryDetails.TimeStamp) && ...
        isnumeric(deployments(idx).DeploymentDetails.Longitude) && ...
        isnumeric(deployments(idx).DeploymentDetails.Latitude)
        
        if ~isfield(deployments(idx).DeploymentDetails, 'DepthInstrument_m')
            deployments(idx).DeploymentDetails.DepthInstrument_m = 0;
            fprintf('%s Missing depth, using 0 m\n', siteid);
        end
        fprojects(folderIdx(idx)).point(...
            deployments(idx).DeploymentDetails.Longitude, ...
            deployments(idx).DeploymentDetails.Latitude, ...
            -deployments(idx).DeploymentDetails.DepthInstrument_m, ...
            'name', siteid, ...
            'timespanBegin', deployments(idx).DeploymentDetails.TimeStamp, ...
            'timespanEnd', deployments(idx).RecoveryDetails.TimeStamp);
    else
        fprintf('%s Skipping due to missing deployment timestamp\n', siteid);
    end
end

earth.save(kmlfile)
if Display
    earth.run()
end