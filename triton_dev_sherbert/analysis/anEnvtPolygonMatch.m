function [DetRangeData, NumGrid, Area] = anEnvtPolygonMatch(envinfile, detrange, varargin)
% [DetRangeData, NumGrid, Area] = anEnvtPolygonMatch(envinfile, detrange, arguments)
% Calculates average value of remotely sensed dataset (envinfile) for a  
% specific detection area (detrange) on a given day.  
% DetRangeData is a Nx5 matrix, where N is the number of days with remotely sensed 
% data.  Columns of DetRangeData are: (1) date, (2) average value of remotely sensed 
% dataset, (3) standard deviation of (2), (4) maximum value in the grid, and (5) 
% minimum value in the grid.  
% NumGrid is number of cells used for calculating the average.
% Area is a 2x1 matrix where Area(1) is percent of total area used for calculating 
% daily means that is within the detrange area and Area(2) is percent of
% the detection range area that is not used for calculating daily means.
%
% Inputs: 
%   envinfile: full path to remotely sensed data file created with dbERDDAP
%   detrange: array with detection polygon coordinates [longitude; latitude] 
%
% Optional arguments:
%   'Longitude', string: note whether detecton polygon longitude is on 
%   [-180 180] scale ('ew', default) or [0 360]E scale ('ea').
%   'Ratio', number 0-1 (default is 0.5): what fraction of overlap must
%   there be between remotely sensed grid and detection area for the cell
%   to be counted.
%   'Plots',string: determines if any plots are created; 'grid' plots an
%   overlap between the grid of remotely sensed data and detection area, 
%   'tims' plots timeseries of final remotely sensed values, 'both' plots
%   both figures and 'none' (default) plots neither.
% 
% Example use:
% [DetRangeData, NumGrid, Area] = anEnvtPolygonMatch(envinfile,detrange,'Ratio',.3,'Plots','both');
% It will use all cells where there is more than 30% overlap between
% environmental data cell grid and detection ragne and it will create plots
% of grid overlaps and time series of final data.
%
% Uses Polygons_intersection code packet developed by Guillaume JACQUENOT
% (ver 2009-06-16) and 64-bit recompiled version of Polygon Clipper code 
% originally developed by Sebastian Hölz.
%
% AS 14/3/26


idx = 1;
%Default ratio 50%; no plots; correction for degrees_east
arearatio = .5;
toplot = 'none';
longtype = 'ew';
while idx <= length(varargin)
    switch varargin{idx}
        case 'Longitude'
            longtype = varargin{idx+1};
            idx = idx+2;    
        case 'Ratio'
            arearatio = varargin{idx+1};
            idx = idx+2;
        case 'Plots'
            toplot = varargin{idx+1};
            idx = idx+2;
        otherwise
            error('Bad arugment:  %s', varargin{idx});
    end
end

% Load data pulled using dbERDDAP
load(envinfile);

%Remove any singleton dimensions from the data 
singletonP = data.dims == 1;
if any(singletonP)
    % Copy singletons to a constants structure and remove
    % them from the Axes structure
    for f = {'names', 'units', 'types', 'values'}
        f = f{1};
        data.Constants.(f) = data.Axes.(f)(singletonP);
        data.Axes.(f)(singletonP) = [];
    end
    for idx = 1:length(data.Data.values)
        data.Data.values{idx} = squeeze(data.Data.values{idx});
    end
    data.dims(singletonP) = [];
end

%Get all the latitude and longitude coordinates from center points of envt
%data
overallong = data.Axes.values{1,1};
overallat = data.Axes.values{2,1};

%Create matrix of coordinates that describe square-polygons of pulled
%environmental data
%figure out step of each lat/long bin
latstep = mean(diff(overallat));
latleng = length(overallat);
longstep = mean(diff(overallong));
longlen = length(overallong);
i = 1;
%Create all polygons
for j = 1:longlen
    S(i).P(j).y(1:2) = overallat(i)-latstep/2;
    S(i).P(j).y(3:4) = S(i).P(j).y(1:2)+latstep;
    S(i).P(j).y(5) = S(i).P(j).y(1);
    S(i).P(j).x(1) = overallong(j)-longstep/2;
    S(i).P(j).x(2:3) = overallong(j)+longstep/2;
    S(i).P(j).x(4:5) = overallong(j)-longstep/2;
    S(i).P(j).hole = 0;
end
for i = 2:latleng
    for j=1:longlen
        S(i).P(j).y(1:2) = overallat(i)-latstep/2;
        S(i).P(j).y(3:4) = S(i).P(j).y(1:2)+latstep;
        S(i).P(j).y(5) = S(i).P(j).y(1);
        S(i).P(j).x(1) = overallong(j)-longstep/2;
        S(i).P(j).x(2:3) = overallong(j)+longstep/2;
        S(i).P(j).x(4:5) = overallong(j)-longstep/2;
        S(i).P(j).hole = 0;
    end
end
%Calculate area (madeup units) of one data square
onebox = S(1);
[onebox S_area] = Polygons_intersection_Compute_area(onebox);

%Convert longitudes to be on 360 degrees
if longtype == 'ew'
    neglong = find(detrange(:,1)<0);
    longs = detrange(:,1);
    if length(neglong)>0
        longs = longs(neglong,1)+360;
    end
else longs = detrange(:,1);
end
lats = detrange(:,2);
if or(lats(end)~=lats(1), longs(end)~=longs(1))
    %Create polygon of detection range
    longs(end+1) = longs(1);
    lats(end+1) = lats(1);
end
DetectionArea = polyarea(longs,lats);

fignum = 1;
if or(toplot == 'grid', toplot == 'both'),
    %Draw the polygons to verify this all makes sense
    figure(fignum);
    fignum = fignum+1;
    hold on;
    for zz = 1:size(S,2)
        for vv = 1:size(S(zz).P,2)
            fill(S(zz).P(vv).x,S(zz).P(vv).y,'r');
        end
    end
    fill(longs,lats,'g')
    hold off;
end

%Pull intersections for each general polygon with overall detection range
testpol = []; 
%Initialize variable for storing loaction of grid points that will be
%pulled and total area used
BoxToUse = []; z = 1;
GridArea = 0; OverlapArea = 0; TooSmallArea = 0;
for k = 1:size(S,2) %S is latitude
    for l = 1:size(S(1,1).P,2)  %P is longitude
        %create polygon with one envt box and whole detection range
        testpol(1).P(1) = S(k).P(l);
        testpol(2).P(1).x = longs;
        testpol(2).P(1).y = lats;
        testpol(2).P(1).hole = 0;
        %find all intersection between these two "polygons"
        geo = Polygons_intersection(testpol);
        %test if there actually is an intersection of the two
        for cnt = 1:size(geo,2),
            if size(geo(cnt).index,2)==2,
            %there is intersection and we need to see if it's more than wanted 
            %ratio of area to decide if using that box
                if geo(cnt).area/S_area.A(1)>=arearatio,
                    BoxToUse(z,1:2) = [l k];
                    z = z+1;
                    GridArea = GridArea+S_area.A(1);
                    OverlapArea = OverlapArea+geo(cnt).area;
                else TooSmallArea = TooSmallArea+geo(cnt).area;
                end
            end
        end
        clear testpol;
    end
end

NumGrid = size(BoxToUse,1);
if NumGrid == 0
    disp('There is no overlap in your areas! It looks like you need to get'); 
    disp('a different remotely sensed data set.');
    DetRangeData = [];
    Area(1) = NaN;
    Area(2) = 1;
else
    %Create new matrix using only data from areas within the detection range
    %First chcek there are more than one day of data
    if size(data.dims,2)>2
        for cc=1:data.dims(3)
            %create vector with day of data (1) and mean (2) value over the whole
            %area as well as st dev (3), max (4) and min (5) values
            values = [];
            for dd = 1:size(BoxToUse,1)
                values(dd) = data.Data.values{1}(BoxToUse(dd,1),BoxToUse(dd,2),cc);
            end
            DetRangeData(cc,1) = data.Axes.values{3}(cc);
            DetRangeData(cc,2) = nanmean(values);
            DetRangeData(cc,3) = nanstd(values);
            DetRangeData(cc,4) = nanmax(values);
            DetRangeData(cc,5) = nanmin(values);
        end
    else values = [];
        for dd = 1:size(BoxToUse,1)
            values(dd) = data.Data.values{1}(BoxToUse(dd,1),BoxToUse(dd,2));
        end
        %only one day of data
        DetRangeData(1) = cell2mat(data.Constants.values(2)); %1 is altitude
        DetRangeData(2) = nanmean(values);
        DetRangeData(3) = nanstd(values);
        DetRangeData(4) = nanmax(values);
        DetRangeData(5) = nanmin(values);
    end

    Area(1) = OverlapArea/GridArea*100;     %Percent of area used for envt data that is actually within detrange
    Area(2) = TooSmallArea/DetectionArea*100;  %Percent of area in detection range that is not used for envt data

    if or(toplot == 'tims', toplot == 'both')
        figure(fignum)
        %plot timeseries of variable for this location
        plot(DetRangeData(:,1),DetRangeData(:,2));
        ylabel(cellstr(data.Data.names));
    end
end
end