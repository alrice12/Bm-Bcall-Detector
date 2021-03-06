function dbDemo(example, varargin)
% dbDemo(example, debug)
% Examples of using the Tethys database.
% 
% example - example N, see switch statement for details.
% debug - turn on debugging mode, functions supporting debugging
%   flags will have them enabled.

% defaults
dbInitArgs = {};
debug = false;


idx = 1;
while idx < length(varargin)
    switch varargin{idx}
        case {'Server', 'Port'}
            dbInitArgs{end+1} = varargin{idx};
            dbInitArgs{end+1} = varargin{idx+1};
            idx = idx + 2;
        case 'Debug'
            debug = varargin{idx+1};
            idx = idx + 2;
        otherwise
            error('Bad argument %s', char(varargin{idx}));
    end
end

% Create a handle to the query engine so that we can communicate
% with Tethys.  Typically, this should be done once per Matlab
% session as opposed to creating it every time a function is called.
% For demonstration purposes, we place it inside the demo function.
queries = dbInit(dbInitArgs{:});

% Use SIO Scripps Whale Acoustics Lab abbreviations
% for species codes as parameters.  Will still output
% Latin names, set Output for abbreviations there as well.
% This must be executed after dbInit
dbSpeciesFmt('Input', 'Abbrev', 'SIO.SWAL.v1');
dbSpeciesFmt('Output', 'Vernacular', 'English');

% Some of the example queries will restrict data to these parameters.
project = 'SOCAL';
deployment = 38;
site = 'M';

% Examples of what can be done in Tethys:
switch example
    case 1
        % all unidentified beaked whale detections associated with a 
        % specific deployment and site in SOCAL.
        event(1).species = 'Zc'; %'UBW';
        event(1).call = '';  % only necessary for generating legend
        event(1).timestamps = dbGetDetections(queries, ...
            'SpeciesID', event(1).species, 'Site', site, 'Project', project, ...
            'Deployment', deployment);
        event(1).effort = dbGetEffort(queries, ...
            'SpeciesID', event(1).species, 'Site', site, 'Project', project, ...
            'Deployment', deployment);
        event(1).resolution_m = 60;  % plot resolution

        event(2).species = 'Anthro';
        event(2).call = 'Active Sonar';
        event(2).timestamps = dbGetDetections(queries, ...
            'SpeciesID', event(2).species, 'Site', site, 'Project', project, ...
            'Call', event(2).call, 'Deployment', deployment);
       event(2).effort = dbGetEffort(queries, ...
            'SpeciesID', event(2).species, 'Site', site, 'Project', project, ...
            'Call', event(2).call, 'Deployment', deployment);
        event(2).resolution_m = 60;
        
        event(3).species = 'Anthro';
        event(3).call = 'Ship';
        event(3).timestamps = dbGetDetections(queries, ...
            'SpeciesID', event(2).species, 'Site', site, 'Project', project, ...
            'Deployment', deployment);
        % Get effort.  As there are multiple call types, multiple effort
        % tuples will be returned.
        event(3).effort = dbGetEffort(queries, ...
            'SpeciesID', event(3).species, 'Site', site, 'Project', project, ...
            'Deployment', deployment);

        event(3).resolution_m = 60;
        
        % Display the plot.  The following function is part of
        % the dbDemo and is not generally available.  The functions
        % it calls are.
        plot_presence(event, debug);
        title(sprintf('%s %s site: %s', project, deployment, site));

        
    case 2
        % Humpbacks, Fin, and Blue whale calls
        event(1).species = 'Mn';  % humpback
        event(2).species = 'Bp';  % fin
        event(3).species = 'Bm';  % blue
        for k =1:3
          % We won't use this in the query, but when we want to add
          % a legend the code will expect a string for the call
          event(k).call = '';
          event(k).timestamps = dbGetDetections(queries, ...
            'SpeciesID', event(k).species, 'Site', site, 'Project', project, ...
            'Deployment', deployment);
          event(k).effort = dbGetEffort(queries, ...
            'SpeciesID', event(k).species, 'Site', site, 'Project', project, ...
            'Deployment', deployment);
          event(k).resolution_m = 60;  % plot resolution
        end

        plot_presence(event, debug);
        title(sprintf('%s %s site: %s', project, deployment, site));

    case 3
        % Show effort for the project, deployment, and site
        % set above
        [effort details] = dbGetEffort(queries, 'Project', project, ...
            'Deployment', deployment, 'Site', site);
        fprintf('Effort summary %s %d site %s\n', project, deployment, site);
        ReportEffort(details);
        
    case 4
        % Show effort for entire database
        [effort, details] = dbGetEffort(queries);
        fprintf('Effort summary across entire database\n');
        ReportEffort(details);
        
    case 5 
        % Diel plot in local time
        species = 'Gg';
        deployment = 38;
        site = 'M';
        
        detections = dbGetDetections(queries, 'Project', project, ...
            'Deployment', deployment, 'Site', site, 'SpeciesID', species);
        [effort, details] = dbGetEffort(queries, 'Project', project, ...
            'Deployment', deployment, 'Site', site, 'SpeciesID', species);
        if ~ isempty(effort)
            % Retrieve coordinates of HARP deployment
            sensor = dbDeploymentInfo(queries, 'Project', project, ...
                'DeploymentID', deployment, 'Site', site);
            % Determine when the sun is down between effort start and end
            EffortSpan = [min(effort(:, 1)), max(effort(:, 2))];
            night = dbDiel(queries, ...
                sensor.DeploymentDetails.Latitude, sensor.DeploymentDetails.Longitude, ...
                EffortSpan(1), EffortSpan(2));

            % Set to zero for GMT, we'll plot in local time
            UtcOffset = -7;  
            % plot diel pattern which we treat as just another detection
            % with special plotting options (no outlines, transparency,
            % & high resolution to prevent a jagged plot over time)
            nightH = visPresence(night, 'Color', 'black', ...
                'LineStyle', 'none', 'Transparency', .15, ...
                'Resolution_m', 1/60, 'DateRange', EffortSpan, ...
                'UTCOffset', UtcOffset);
            % Plot detections
            speciesH = visPresence(detections, 'Color', 'g', ...
                'Resolution_m', 5, 'Effort', effort, ...
                'UTCOffset', UtcOffset);
            legendH = legend(speciesH(1), species);
        else
            fprintf('No data for %s in %s %d Site %s\n', ...
                species, project, deployment, site);
        end
            
    case 6
        Species = 'Lo';
        % Show all detections for a given site
        dbYearly(queries, 'Project', project, 'Site', site, 'SpeciesID', 'Gg');
        
    case 7
        % Show all species and call types in the database
        fprintf('Species having reported effort in the database\n');
        [effort, details] = dbGetEffort(queries);
        kinds = details.Kind;  % kind of effort
        % Pull out a list of species for which we have effort
        species = unique({kinds.SpeciesID});
        
        for sidx = 1:length(species)
            s = species{sidx};
            fprintf('Species: %s\n', s)
            
            % indicator function for which efforts/details are 
            % associated with this species
            speciesP = strcmp({kinds.SpeciesID}, s);
            % Get list of calls associated with effort
            % We could do another query, but we have everything here.
            calls =  unique(horzcat(kinds(speciesP).Call));
            
            fprintf('Call types: \n')
            for cidx=1:length(calls)
                fprintf('  call "%s"', calls{cidx});
                % find subtypes for this call, this is an example
                % using XQuery directly.  See Walmsley, P. (2006) XQuery.
                % O'Reilly, Farnham, to learn about using XQuery.
                % Note that we use %s string place holders to let us
                % format the query for a specific species and call.
                querystr = [ ...
                    'let $subtypes := for $d in collection("Detections")/ty:Detections/Detection\n', ...
                    'where $d/Species = "%s" and $d/Call = "%s"\n' ...
                    'return\n' ...
                    ' let $calltype := distinct-values($d/Call)\n' ...
                    ' for $a in $calltype\n', ...
                    '   return $d/Call/@Subtype\n', ...
                    'return distinct-values($subtypes)'];
                % We use the QueryTethys method which adds a standard
                % set of imports for the Tethys schema abbreviated as 
                % ty: and also imports a set of Tethys library functions
                % that we are not using here.
                subtypes = queries.QueryTethys(sprintf(querystr, s, calls{cidx}));
                % split string into multiple Java arrays
                subtypes = subtypes.split(char(10));
                commaP = false;
                for k=1:subtypes.size(1)
                    if commaP
                        fprintf(', ');
                    end
                    subtype = char(subtypes(k));  % Java->Matlab str
                    if ~isempty(subtype)
                        if ~ commaP
                            fprintf(' - subtypes: '); % first one
                        end
                        fprintf('"%s"', subtype);
                        commaP = true;
                    end
                end
                fprintf('\n');

            end
            fprintf('\n');
        end
        
    case 8
        % Demonstrate a diel plot
        query_eng = queries;
        [detections, endP] = dbGetDetections(query_eng, ...
            'Project', 'SOCAL',  'Site', 'M', 'SpeciesID', 'Lo', ...
            'Call', 'Clicks');
        
        [effort, details] = dbGetEffort(query_eng, 'Project', 'SOCAL', ...
            'Site', 'M',  'SpeciesID', 'Lo');
        EffortSpan = [min(effort(:, 1)), max(effort(:, 2))];
        sensor = dbDeploymentInfo(query_eng, 'Project', 'SOCAL', 'Site', 'M');
        % Get dusk/dawn matrix over effort time using first deployment long/lat
        night = dbDiel(query_eng, sensor(1).DeploymentDetails.Latitude, ...
            sensor(1).DeploymentDetails.Longitude, EffortSpan(1), EffortSpan(2));
        diel_det = dbNormDiel(detections, night, -8);  % normalize to night/day at UTC -8
        % Create 0/1 indicator for each hour, one row per day
        presenceI = dbPresenceAbsence(diel_det, 'Resolution_m', 5);
        visCyclic(presenceI);  % diel plot
        xlabel('Time of day (h in daylight normalized UTC-8)');
        ylabel('Days of presence')
        
    case 9
        % Lunar Illumination plot in local time
        species = 'Grampus griseus';  % Risso's dolphin
        dbSpeciesFmt('Input', 'Latin')
        site = 'M';
        deploymentStart = 34;
        deploymentEnd = 44;
        detections = dbGetDetections(queries, 'Project', project, ...
             'Site', site, 'SpeciesID', species, ...
             'Deployment', {'>=', deploymentStart}, ...
             'Deployment', {'<=', deploymentEnd});
        [effort, details] = dbGetEffort(queries, 'Project', project, ...
            'Site', site, 'SpeciesID', species, ...
            'Deployment', {'>=', deploymentStart}, ...
             'Deployment', {'<=', deploymentEnd});
        details.XML_Document
        if ~ isempty(effort)
            % Retrieve coordinates of HARP deployment
            sensor = dbDeploymentInfo(queries, 'Project', project, ...
                'DeploymentID', deploymentStart, 'Site', site);
            % Determine when the sun is down between effort start and end
            EffortSpan = [min(effort(:, 1)), max(effort(:, 2))];
            
            % Interval minutes must evenly divide 24 hours
            interval = 30;
            getDaylight = false;
            illu = dbGetLunarIllumination(queries, ...
                sensor.DeploymentDetails.Latitude, sensor.DeploymentDetails.Longitude, ...
                EffortSpan(1), EffortSpan(2), interval, 'getDaylight', getDaylight);

            % Set to zero for GMT, we'll plot in local time
            UtcOffset = -7;  
            
            night = dbDiel(queries, ...
                sensor.DeploymentDetails.Latitude, sensor.DeploymentDetails.Longitude, ...
                EffortSpan(1), EffortSpan(2));
            nightH = visPresence(night, 'Color', 'black', ...
                'LineStyle', 'none', 'Transparency', .15, ...
                'Resolution_m', 1/60, 'DateRange', EffortSpan, ...
                'UTCOffset', UtcOffset);
             
            lunarH = visLunarIllumination(illu, 'UTCOffset', UtcOffset);
            
            % Plot detections
            speciesH = visPresence(detections, 'Color', 'b', ...
                'Resolution_m', 5, 'Effort', effort, ...
                'UTCOffset', UtcOffset);
            
            % removed no effort legend due to Matlab plot bug
            legendH = legend(speciesH(1), species);
            
            % get parent of plots
            if ~ isempty(nightH)
                % find axis to which the species detections were plotted
                axH = get(nightH(1), 'Parent');
                
                % Set interval for date ticks
            
                % order is important here.
                % do not use datetick before setting YTick
                % datetick will not recalculate the dates
            
                DateTickInterval = 30;
                set(axH, 'YGrid', 'on', ...
                    'YTick', EffortSpan(1):DateTickInterval:EffortSpan(2));
                datetick(axH, 'y', 1, 'keeplimits', 'keepticks');
            end
        else
            fprintf('No effort for %s in %s %d Site %s\n', ...
                species, project, deployment, site);
        end
  
    case 10
        % Show all of the detection efforts that have been 
        % entered into the database
        % This is an example of a query written in XQuery
        fprintf('List of effort sheets in database\n');
        % Return a Java string
        result = queries.Query(...
            ['for $i in collection("Detections")/Detections ', ...
             ' return <XML_Document> {base-uri($i)} </XML_Document>']);
        % .toCharArray() converts it into a character array that
        % Matlab can deal with
        fprintf('%s\n', result.toCharArray());
         
    case 11
        % Grab chlorophyll and plot next to Blue whale presence h/day
        Project = 'SOCAL';
        Site = 'M';
        %Deployment = 38;
        species = 'Balaenoptera musculus';
%         deployment = dbDeploymentInfo(queries, 'Project', Project, 'Site', Site, 'DeploymentID', Deployment);
%         [eff, effInfo] = dbGetEffort(queries, 'Project', Project, 'Site', Site, 'Deployment', Deployment, 'SpeciesID', species, 'Call', 'D');
%         detections = dbGetDetections(queries, 'Project', Project, 'Site', Site, 'Deployment', Deployment, 'SpeciesID', species, 'Call', 'D');
        deployment = dbDeploymentInfo(queries, 'Project', Project, 'Site', Site);
        [eff, effInfo] = dbGetEffort(queries, 'Project', Project, 'Site', Site, 'SpeciesID', species, 'Call', 'D');
        detections = dbGetDetections(queries, 'Project', Project, 'Site', Site, 'SpeciesID', species, 'Call', 'D');
        
        % We will be working with the 3 day chlorophyll average from
        % erdMBchla3day.  
        resolution_deg = .025;  % spatial resolution in degrees
        start = min(eff(:,1));
        stop = max(eff(:,2));
        daterange = sprintf('(%s):1:(%s)', dbSerialDateToISO8601(start), dbSerialDateToISO8601(stop));
        lat = round(deployment(1).DeploymentDetails.Latitude/resolution_deg)*resolution_deg;
        long = round(deployment(1).DeploymentDetails.Longitude/resolution_deg)*resolution_deg;
        result = dbERDDAP(queries, sprintf('erdMBchla3day?chlorophyll[%s][(0.0):1:(0.0)][(%f):1:(%f)][(%f):1:(%f)]', daterange, lat, lat, long, long));
        [counts, days] = dbPresenceAbsence(detections(:,1));
        weeks = days(1:90:end);      
        dcallH = plot(days, sum(counts,2));
        callAx = gca;

        % Find the parent of the peer axis so that we may put the new axis
        % in the same container.
        parent = get(callAx, 'Parent');


        % Position a second axis on top of our current one.
        % Make it transparent so that we can see what's underneath
        % turn on the tick marks on the X axis and set up an alternative
        % Y axis in another color on the right side.
        envAx = axes('Position', get(callAx, 'Position'),  ... % put over
            'Color', 'none', ... % don't fill it in
            'YAxisLocation', 'right', ...  % Y label/axis location
            'XTick', [], ...  % No labels on x axis
            'YColor', 'm', ...
            'Parent', parent);
        hold(envAx)
        plot(envAx, dbISO8601toSerialDate(result.time), result.chlorophyll, 'm');
        
        set(envAx, 'XTick', []);
        set(callAx, 'XTick', weeks);
        ylabel(envAx, 'Chlorophyll mg/m^{3}')
        ylabel(callAx, 'Num. Hours w/ D-Calls / day');
        datetick(callAx, 'x', 1, 'keeplimits', 'keepticks');
        set(envAx, 'YLim', [0, 7])
        
        keyboard
        
    case 12
        % ERDDAP demonstration
        
        % longitude & latitude bounding box around an instrument
        % deployed on the south eastern bank of the Santa Cruz Basin
        % in the Southern California Bight
        
        % Normally, we would query for a specific instrument, but
        % here we just hardcode the site
        center = [33.515  240.753];  % close to site M
        start = '2010-07-22T00:00:00Z';
        stop = '2010-11-07T08:49:59Z';
        
        % Here is how we would do it for a generic instrument:
        % deployment = dbDeploymentInfo(query_eng, ... details...);
        % Assume that only a single deployment was matched, otherwise
        % we have more work to do
        % center = [deployment.DeploymentDetails.Longitude, ...
        %           deployment.DeploymentDetails.Latitude];
        % start = deployment.DeploymentDetails.TimeStamp;
        % stop = deployment.DeploymentDetails.TimeStamp;        
        
        % Find a bounding box about 5 km away from our center.
        distkm = 5;
        deltadeg = km2deg(distkm);  % Requires Mapping toolbox, about .045 degrees
        box = [center-deltadeg; center+deltadeg];
        
        % Find a list of sea surface tempature datasets within bounding box
        criteria = ['keywords=sea_surface_temperature', ...
            sprintf('&minLat=%f&maxLat=%f&minLong=%f&maxLong=%f', box(:)), ...
            sprintf('&minTime=%s&maxTime=%s', start, stop)];
        datasets = dbERDDAPSearch(queries, criteria);
        
        fprintf('We searched for keyword=sea_surface_temperature in our region & time of interest.\n');
        fprintf('At this point, we would select a dataset.\n');
        fprintf('For this demo, we are selecting the 8 day \n')
        fprintf('sea surface temperature composite in erdMWsstd8day\n');
        
        x = input('Press Enter to continue');
        % Format the ERDDAP query
        
        % todo:  Generate query from data
        data = dbERDDAP(queries, 'erdMWsstd8day?sst[(2012-11-13T00:00:00Z):1:(2012-11-13T00:00:00Z)][(0.0):1:(0.0)][(33.47):1:(33.59)][(240.7):1:(240.80)]');
        

        
    otherwise
        error('Unknown example');
end
       
function plot_presence(event, debug)
% show the presence/absence plot
count = 1;
N = length(event);
figure('Name', ['Presence/absence ', sprintf('%s, ', event.species)]);
colors = cool(N);
% Which queries had effort associated with them?
EffortPred = arrayfun(@(x) ~isempty(x.effort), event);
EffortN = sum(EffortPred);
NoEffortN = N - EffortN;
event_H = cell(EffortN, 1);
event_label = cell(EffortN, 1);
if NoEffortN
    fprintf('Skipping due to lack of effort -----\n');
    for idx = find(EffortPred == 0)
        fprintf('%s %s\n', event(idx).species, event(idx).call);
    end
    fprintf('-------------\n')
end
for idx = find(EffortPred)
    % plot the detections.  Returns handles to patch objects for 
    % detections (1) and effort (2)
    event_H{count} = visPresence(event(idx).timestamps, ...
        'Effort', event(idx).effort, ...
        'Resolution_m', event(idx).resolution_m, 'Color', colors(idx,:), ...
        'BarHeight', 1/EffortN, 'BarOffset', (EffortN-count)/EffortN, 'Debug', debug);
    event_label{count} = sprintf('%s %s', event(idx).species, event(idx).call);
    count = count + 1;
end
% Concatenate all the handles so that we have a matrix where
% row 1 shows detections and row 2 shows effort 
event_handles = cat(1, event_H{:});
event_handles = reshape(event_handles, 2, length(event_handles)/2);

% if no event occurred, then use effort handle
use_effort = event_handles(1,:) == 0;
use_handles = event_handles(1,:);
use_handles(use_effort) = event_handles(2,use_effort);

legend(use_handles, event_label);

% If you want your plots to have the most recent date at the bottom,
% uncomment the next line:
% set(gca, 'YDir', 'reverse');

1;

function ReportEffort(details)
for didx=1:length(details)
    EffortStart = details(didx).Start;
    EffortEnd = details(didx).End;
    fprintf('%s:  effort %s - %s %s, %s\n', ...
        details(didx).XML_Document, ...
        details(didx).Start, details(didx).End, ...
        details(didx).Algorithm.Method, details(didx).UserID);
    KindN = length(details(didx).Kind);
    for kidx= 1:KindN
        if KindN > 1
            % Will either be a structure or cell array depending
            % upon whether the data is homogeneous...
            % Not the best design, but what xml_read is giving us
            % for now.
            if iscell(details(didx).Kind)
                Kind = details(didx).Kind{kidx};
            else
                Kind = details(didx).Kind(kidx);
            end
        else
            Kind = details(didx).Kind;
        end
        
        % May or may not have attributes...
        try
            Group = sprintf(' (%s)', Kind.SpeciesID_attr.Group);
        catch
            Group = '';
        end
        
        if isnumeric(Kind.SpeciesID)
            fprintf('\t%d%s, ', Kind.SpeciesID, Group);
        else
            fprintf('\t%s%s, ', Kind.SpeciesID, Group);
        end
        
        try
            Granularity = sprintf('%s (%d m)', ...
                Kind.Granularity, Kind.Granularity_attr.BinSize_m);
        catch
            Granularity = Kind.Granularity_attr;
        end
        fprintf('%s\t%s\n', ...
            Kind.Call, Granularity);
    end
end



