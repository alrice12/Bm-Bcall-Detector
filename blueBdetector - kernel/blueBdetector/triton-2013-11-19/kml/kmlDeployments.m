function kml = kmlDeployments(Depl)
% kml = kmlDeployments(DeploymentInfo)
% DeploymentInfo is a structure returned by dbDeploymentInfo
% Convert deployment information to KML for Google Earth
% Use ge_output(Filename, kml) to write KML file

kml = '';
for idx = 1:length(Depl)
    Latitude = Depl(idx).GeoTime.Latitude;
    Longitude = Depl(idx).GeoTime.Longitude;
    if Longitude > 180
        Longitude = Longitude - 360;
    end
    Depth_m = Depl(idx).GeoTime.Depth_m;
    Description = 'Deployment';
    Opts = {};
    if isfield(Depl(idx).GeoTime, 'TimeStamp') && ~ isempty(Depl(idx).GeoTime.TimeStamp)
        DeployTime = Depl(idx).GeoTime.TimeStamp;
        Description = sprintf('%s %s', Description, DeployTime);
        if ~ isempty(Depl(idx).TimeStampEnd)
            RecoverTime = Depl(idx).TimeStampEnd;
            Description = sprintf('%s Recovered %s', Description, RecoverTime);
            Opts = {Opts{:}, 'timeSpanStart', DeployTime, ...
                'timeSpanStop', RecoverTime};
        end
    end
    
    kml = sprintf('%s%s', kml, ...
       ge_point(Longitude, Latitude, Depth_m, ...
        'pointDataCell', {'Lat', sprintf('%f', Latitude);
        'Long', sprintf('%f', Longitude);
        'Depth', sprintf('%f', Depth_m)}, ...
        'altitudeMode', 'relativeToGround', ...
        'name', sprintf('%s-%s %d', ...
            Depl(idx).Project, Depl(idx).Site, Depl(idx).Deployment), ...
        'description', Description, ...
        Opts{:}) ...
        );
end
