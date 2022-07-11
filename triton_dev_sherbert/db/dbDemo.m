function dbDemo(example, varargin)
% dbDemo(exampleN, OptionalArgs)
% Examples of using the Tethys database.
% 
% example - example N, see switch statement for details.
% Optional keyword value pair arguments:
%   'Server' - Override default server name
%   'Port' - Overrride default port
%   'QueryHandler', q - Use an existing query handler rather than
%      a new one.  Note that Server and Port arguments are ignored
%      if this is specified.
%   'Debug', true|false - Produce debug information for some plots.

% defaults
dbInitArgs = {};
debug = false;
queries = [];

idx = 1;
while idx < length(varargin)
    switch varargin{idx}
        case {'Server', 'Port'}
            dbInitArgs{end+1} = varargin{idx};
            dbInitArgs{end+1} = varargin{idx+1};
            idx = idx + 2;
        case 'QueryHandler'
            queries = varargin{idx+1};
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
% For demonstration purposes, we place it inside the demo function
% if the caller has not passed one in.
if isempty(queries)
    queries = dbInit(dbInitArgs{:});
end

% Use SIO Scripps Whale Acoustics Lab abbreviations
% for species codes as parameters.  Will still output
% Latin names, set Output for abbreviations there as well.
% This must be executed after dbInit
dbSpeciesFmt('Input', 'Abbrev', 'SIO.SWAL.v1');
dbSpeciesFmt('Output', 'Vernacular', 'English');

% Some of the example queries will restrict data to these parameters.
project = 'SOCAL';
species = 'Gg';
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
        title(sprintf('%s %d site: %s', project, deployment, site));
        1;
        
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
        title(sprintf('%s %d site: %s', project, deployment, site));

    case 3
        % Show effort for the project, deployment, and site
        % set above
        [effort details] = dbGetEffort(queries, 'Project', project, ...
            'Deployment', deployment, 'Site', site);
        fprintf('Effort summary %s %d site %s\n', project, deployment, site);
        ReportEffort(details);
        
    case 4
        % Show effort for entire database
        % Warning: Will be slow on very large databases!
        [effort, details] = dbGetEffort(queries);
        fprintf('Effort summary across entire database\n');
        ReportEffort(details);
        
    case 5 
        % Diel plot in local time

        
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
            % Find periods of night time.  To get complete night periods,
            % we look one day prior to the start of effort and one day
            % after.
            night = dbDiel(queries, ...
                sensor.DeploymentDetails.Latitude{1}, sensor.DeploymentDetails.Longitude{1}, ...
                EffortSpan(1)-1, EffortSpan(2)+1);

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
        % Show all detections for a given project
        project = 'CINMS';
        dbYearly(queries, 'Project', project);
        
    case 7
        % Show all species and call types with effort in the database

        fprintf('Species having reported effort in the database\n');
        [~, details] = dbGetEffort(queries);
        
        map = containers.Map();        
        for didx = 1:length(details)
            for kidx = 1:length(details(didx).Kind)
                species = details(didx).Kind(kidx).SpeciesID{1};
                call = details(didx).Kind(kidx).Call{1};
                try
                    map(species) = union(map(species), call);
                catch
                    map(species) = {call};  % first one
                end
            end
        end
        
        species = sort(keys(map));
        
        for sidx = 1:length(species)
            s = species{sidx};
            fprintf('Species:  %s\n', s)
            
            fprintf('  Calls:  ')
            calls = map(s);
            % strjoin(' ', map(s)));  <-- better, but relies on 2013A
            for cidx = 1:length(calls)
                if cidx < length(calls)
                    fprintf('%s, ', calls{cidx});
                else
                    fprintf('%s', calls{cidx});
                end
            end
            fprintf('\n');
            
        end
        
    case 8
        % Demonstrate a weekly effort plot, KW Whistles
        species = 'Oo';
        project = 'ALEUT';
        site = 'BD';
        deployment = 02;
        visWeeklyEffort(queries,'Project',project,'Site',site,'Deployment',deployment,...
            'Granularity','encounter','Call','Whistles','SpeciesID',species);
        
        %And a convenience function for diel
        visDiel(queries,'Project',project,'Site',site,'Deployment',deployment,...
            'Granularity','encounter','Call','Whistles','SpeciesID',species);
        
    case 9
        % Lunar Illumination plot in local time

        [detections,~,~] = dbGetDetections(queries, 'Project', project, ...
             'Site', site, 'SpeciesID', species, ...
             'Deployment', deployment);
        [effort, ~] = dbGetEffort(queries, 'Project', project, ...
            'Site', site, 'SpeciesID', species, ...
            'Deployment', deployment);
        if ~ isempty(effort)
            % Retrieve coordinates of HARP deployment
            sensor = dbDeploymentInfo(queries, 'Project', project, ...
                'DeploymentID', deployment, 'Site', site);
            % Determine when the sun is down between effort start and end
            EffortSpan = [min(effort(:, 1)), max(effort(:, 2))];
            
            % Interval minutes must evenly divide 24 hours
            interval = 30;
            getDaylight = false;
            illu = dbGetLunarIllumination(queries, ...
                sensor.DeploymentDetails.Latitude{1}, sensor.DeploymentDetails.Longitude{1}, ...
                EffortSpan(1), EffortSpan(2), interval, 'getDaylight', getDaylight);

            % Set to zero for GMT, we'll plot in local time
            UtcOffset = -7;  
            
            night = dbDiel(queries, ...
                sensor.DeploymentDetails.Latitude{1}, sensor.DeploymentDetails.Longitude{1}, ...
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
        result = queries.QueryTethys(...
            ['for $i in collection("Detections")/ty:Detections ', ...
             ' return <XML_Document> {base-uri($i)} </XML_Document>']);
        % .toCharArray() converts it into a character array that
        % Matlab can deal with
        fprintf('%s\n', result.toCharArray());
         
    case 11
        % Grab chlorophyll and plot next to Blue whale presence h/day
        species = 'Bm';
        deployment_start = 31;
        deployment_stop = 38;
        deployment = dbDeploymentInfo(queries, 'Project', project, 'Site', site);
        [eff, ~] = dbGetEffort(queries, 'Project', project, 'Site', site, 'SpeciesID', species, 'Call', 'D');
        detections = dbGetDetections(queries, 'Project', project, 'Site', site, 'SpeciesID', species, 'Call', 'D');
        
        % We will be working with the 3 day chlorophyll average from
        % erdMBchla3day.  
        resolution_deg = .025;  % spatial resolution in degrees
        start = min(eff(:,1));
        stop = max(eff(:,2));
        daterange = sprintf('(%s):1:(%s)', dbSerialDateToISO8601(start), dbSerialDateToISO8601(stop));
        lat = round(deployment(2).DeploymentDetails.Latitude{1}/resolution_deg)*resolution_deg;
        long = round(deployment(2).DeploymentDetails.Longitude{1}/resolution_deg)*resolution_deg;
        result = dbERDDAP(queries, sprintf('erdMBchla3day?chlorophyll[%s][(0.0):1:(0.0)][(%f):1:(%f)][(%f):1:(%f)]', daterange, lat, lat, long, long));
        [counts, days] = dbPresenceAbsence(detections(:,1));
        weeks = days(1:90:end);      
        dcallH = plot(days, sum(counts,2));
        callAx = gca;
        %turn off upper/right tick marks
        set(gca,'box','off');

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
        hold(envAx);
        
        % access time axis values.
        % find axis named time in list of axes
        timeaxpos = find(strcmp(result.Axes.names, 'time'));
        
        plot(envAx, ...
            result.Axes.values{timeaxpos}, result.Data.values{1}(:), 'm');
        
        set(envAx, 'XTick', []);
        set(callAx, 'XTick', weeks);
        ylabel(envAx, 'Chlorophyll mg/m^{3}')
        ylabel(callAx, 'Num. Hours w/ D-Calls / day');
        datetick(callAx, 'x', 1, 'keeplimits', 'keepticks');
        set(envAx, 'YLim', [0, 7])
                
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
        % We use our start/stop times, and the coordinates created using
        % our bounding box.
        erd_str = ['erdMWsstd8day?sst',...
            sprintf('[(%s):1:(%s)][(0.0):1:(0.0)]',start,stop),...
            sprintf('[(%f):1:(%f)][(%f):1:(%f)]',box(:))];
        
        fprintf('Retrieving sea surfce temperature with function call:\n');
        fprintf('data = dbERDDAP(queries,%s)\n',erd_str);
        data = dbERDDAP(queries, erd_str);
        
        fprintf('The result is a structure containing three fields:\n');
        disp(data);
        
        x = input('Press Enter to continue');
        fprintf('The Axes field is a structure describing each of the 4 axes:\n');
        disp(data.Axes);
        fprintf('Names is the name of each axis, e.g. data.Axes.names(1) is longitude\n');
        fprintf('Units are the measurements, types are the data types, and \n');
        fprintf('values is the actual point on the axis\n\n');
        
        fprintf('the Data field is a struct with similar child fields:\n')
        disp(data.Data)
        fprintf('the values field of Data represents the coordinate values for each dimension\n\n');
        
        
        fprintf('Now lets show an animation of latitude, longitude and sea surface temperature\n');
        fprintf('Note that some days may be missing data, they are displayed in white\n');
        x = input('Press Enter to continue');
        
        
        
        % Find the limits of the sea surface temperature
        targetlims = [min(data.Data.values{1}(:)), ...
            max(data.Data.values{1}(:))];
        
        %replace NaNs (missing values)
        %with dummy value so that they can be a different color
        
        maxval = targetlims(2);
        data.Data.values{1}(isnan(data.Data.values{1})) = maxval+maxval/10;

        
        
        timeax = find(strcmp(data.Axes.names, 'time'));
        h = figure('Name', 'Sea Surface Temperature (SST)','Visible','off');
        
        for tidx=1:data.dims(timeax);  % Animate over time
            imagesc(data.Axes.values{1}, data.Axes.values{2}, ...
                squeeze(data.Data.values{1}(:,:,tidx)), targetlims);
            set(gca, 'YDir', 'normal');
            title(datestr(data.Axes.values{timeax}(tidx), 1));
            xlabel(data.Axes.names{1});
            ylabel(data.Axes.names{2});
            
            %a trick to make NaNs gray
            colordata = colormap;
            colordata(end,:) = [0.9 0.9 0.9];
            colormap(colordata);
            cbh = colorbar;
            ylabel(cbh, 'sst (deg C)')
            frames(tidx) = getframe(h);
        end
        close(h);
        
        %new figure for the movie
        figure('Name','Sea Surface Temperature (SST)');
        movie(gcf,frames,1,8)

    case 13
        % Second ERDDAP demonstration, more sophisticated
        % Find wind coverage across all Channel Islands project
        % HARPS (assumes demo database is running)
        project = 'CINMS';
        deployments = dbDeploymentInfo(queries, 'Project', project);
        % Find temporal extent
        % deployments is a structure array.  We can get back a cell
        % array of DeploymentDetails by using
        % deployments.DeploymentDetails.  However, we want the timestamp
        % associated with each of these.  We use an anynonymous function
        % @(x) x.TimeStamp which just takes its input and returns the
        % timestamp and apply it to each cell of
        % {deployments.DeploymentsDetails}.  The UniformOutput flag
        % tells us that the results should be treated as a cell array.
        %
        %Data collection for this set ended 2011-12-27, so queries
        %exceeding this date will give an error.
        
        starts = cellfun(@(x) x.TimeStamp{1}, ...
            {deployments.DeploymentDetails}, 'UniformOutput', false);
        % We want to find the earliest date, so we'll translate these
        % strings to serial dates, take min, and translate back to a
        % string
        earliest = dbSerialDateToISO8601(...
            min(dbISO8601toSerialDate(starts)));
        
        %For this demonstration, we will pad a year to the effort end date.
        
        latest = dbSerialDateToISO8601(addtodate(dbISO8601toSerialDate(earliest),1,'year'));
        
        
        
        %Below is an example of using the latest date of effort. ERDDAP
        %does not always like being asked for data spanning many years.
        
%         %We take the latest date in a similar way
%         stops = cellfun(@(x) x.TimeStamp, ...
%            {deployments.RecoveryDetails}, 'UniformOutput', false);
%         latest =  max(dbISO8601toSerialDate(stops));
%        

        
        % Similar techniques to get the long/lat bounding box
        latitudes = cellfun(@(x) x.Latitude{1}, ...
            {deployments.DeploymentDetails});
        longitudes = cellfun(@(x) x.Longitude{1}, ...
            {deployments.DeploymentDetails});
        minlat = min(latitudes);
        maxlat = max(latitudes);
        minlong = min(longitudes);
        maxlong = max(longitudes);
        
        % Build the query
        % NASA JPL
        % Cross-calibrated multi-platform (CCMP) Winds, 
        % Atlas FLK v1.1 Derived Surface Winds (Level 3.5a), 
        %   Global, 0.25 Degree, 5-Day Averages
        % See ERDDAP for details on sensors, time coverage, etc.
        dataset = 'jplCcmp35aWindPentad';
        % variable we wish to retrieve
        % wspd - Wind speed at 10 m in m/s
        target = 'wspd';
        % Axes for this variable are [time][latitude][longitude]
        % time resolution 5 days 4 m 50s
        % latitude/longitude .25 degrees
        timeaxis = sprintf('[(%s):1:(%s)]', earliest, latest);
        lataxis = sprintf('[(%f):1:(%f)]', minlat, maxlat);
        longaxis = sprintf('[(%f):1:(%f)]', minlong, maxlong);
        querystr = sprintf('%s?%s%s%s%s', ...
            dataset, target, timeaxis, lataxis, longaxis);
        % Run the query
        % Returns a structure with:
        %  Axes - information about axes
        %  Data - information about the data and the values
        %  dims - data dimensions
        % NOTE:  Axes of returned data are in reverse order
        result = dbERDDAP(queries, querystr);
        
        % Let's animate the windspeed
        
        % Find how the data was organized
        timeax = find(strcmp(result.Axes.names, 'time'));
        longax = find(strcmp(result.Axes.names, 'longitude'));
        latax = find(strcmp(result.Axes.names, 'latitude'));
        
        % code relies on time axis being the 3rd dimension
        % we won't try to generalize the code, but will throw
        % an error if this is not the case
        assert(timeax == 3, 'Time is not the third axis, cannot run')
        
        % Find the limits of the wind speed
        targetlims = [min(result.Data.values{1}(:)), ...
            max(result.Data.values{1}(:))];
        
        maxval = targetlims(2);
        result.Data.values{1}(isnan(result.Data.values{1})) = maxval+maxval/10;

        %don't need to display it until the animation is created.
        %otherwise it will be shown twice.
        h = figure('Name', target,'Visible','off');
        
        fprintf('Creating animation...\n');
        for tidx=1:result.dims(timeax);  % Animate over time
            imagesc(result.Axes.values{1}, result.Axes.values{2}, ...
                squeeze(result.Data.values{1}(:,:,tidx)), targetlims);
            set(gca, 'YDir', 'normal');
            title(datestr(result.Axes.values{timeax}(tidx), 1));
            xlabel(result.Axes.names{1});
            ylabel(result.Axes.names{2});
            
            %a trick to make NaNs gray
            colordata = colormap;
            colordata(end,:) = [.9 .9 .9];
            colormap(colordata);
            cbh = colorbar;
            ylabel(cbh, 'wind speed m/s')
            frames(tidx) = getframe(h);
        end
        close(h)
        if true
            %new figure for the movie
            figure('Name', target);
            %1 time, 6FPS
            movie(gcf,frames,1,8)
        else
            % Write the movie to a file
            % For axes to display correctly, getframe above 
            % should take the argument of the figure handle
            % getframe(h).  Note that this is incompatible with movie
            % so we don't have this set by default.
            video = VideoWriter(dataset);
            video.FrameRate = 4;  % frames/s
            open(video);
            for idx = 1:length(frames)
                writeVideo(video, frames(idx));
            end
            close(video);
        end
        
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
    tm_fmt = 'yyyy-mm-dd HH:MM:SS.FFFZ';
    % handle optional fields
    try
        method = details(didx).Algorithm.Method{1};
    catch
        method = '';
    end
    fprintf('%s:  effort %s - %s %s, %s\n', ...
        details(didx).XML_Document{1}, ...
        datestr(details(didx).Start{1}, tm_fmt), ...
        datestr(details(didx).End{1}, tm_fmt), ...
        method, details(didx).UserID{1});
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
            Group = sprintf(' (%s)', Kind.SpeciesID_attr.Group{1});
        catch
            Group = '';
        end
        
        if isnumeric(Kind.SpeciesID)
            fprintf('\t%d%s, ', Kind.SpeciesID{1}, Group);
        else
            fprintf('\t%s%s, ', Kind.SpeciesID{1}, Group);
        end
        
        try
            Granularity = sprintf('%s (%d m)', ...
                Kind.Granularity{1}, Kind.Granularity_attr.BinSize_m{1});
        catch
            Granularity = Kind.Granularity{1};
        end
        fprintf('%s\t%s\n', ...
            Kind.Call{1}, Granularity);
    end
end



