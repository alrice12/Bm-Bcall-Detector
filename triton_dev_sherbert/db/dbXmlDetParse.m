function [timestamps, EndP, info] = dbXmlDetParse(dom, return_elements)
% parse a DOM retrieved via dbGetDetections.

%A map of types to send to the wrapper, in Key/Value pairs
%Each key represents an element name, and the value reps their return type.
typemap={
    'idx','double';...
    'Deployment','double';...
    'Start','datetime';...
    'End','datetime';...
    'SpeciesID','decimal';...
    % 'Score','double';...  lose some digits if not string
    };

xml_result = char(dom);
result=tinyxml2_tethys('parse',xml_result,typemap);

noEnd=true;
timestamps = [];
EndP = [];
info = [];
if ~iscell(result.Detections)
    if isfield(result.Detections.Detection,'End')
        timestamps = zeros(length(result.Detections.Detection),2);
        noEnd=false;
    else
        %only start times
        timestamps = zeros(length(result.Detections.Detection),1);
    end

    rows=size(timestamps,1);

    % Assume only start times until we know better
    EndP = zeros(rows,1);

    %init info
    if nargout >2
        info.deploymentIdx = zeros(length(result.Detections.Detection),1);
        info.deployments=struct();
        if ~isempty(return_elements) %returning a field?
            fieldnms = regexprep(return_elements, '.*/([^/]+$)', '$1');
            for fidx = 1:length(fieldnms)
                info.(fieldnms{fidx}) = cell(rows, 1);
            end
        end
    end

    %populate detections
    for i=1:rows
        timestamps(i,1) = datenum(result.Detections.Detection(i).Start{1});
        if ~noEnd && iscell(result.Detections.Detection(i).End)
            timestamps(i,2) = datenum(result.Detections.Detection(i).End{1});
            EndP(i) = 1;
        end
        if nargout >2 %process info
            info.deploymentIdx(i) = result.Detections.Detection(i).idx{1};
            if ~isempty(return_elements)
                for fidx=1:length(fieldnms) %for each fieldname, populate
                    name = fieldnms{fidx};
                    if isfield(result.Detections.Detection,name) && ~isempty(result.Detections.Detection(i).(name))
                        info.(name){i} = result.Detections.Detection(i).(name){1};
                    end
                end
            end
        end
    end

    if nargout >2
        %populate DataSource in info struct
        for i=1:length(result.Sources.DataSource)
            info.deployments(i,1).Project = result.Sources.DataSource(i).Project{1};
            info.deployments(i,1).Site = result.Sources.DataSource(i).Site{1};
            info.deployments(i,1).Deployment = result.Sources.DataSource(i).Deployment{1};
        end
    end
else
    1;%no detections
end