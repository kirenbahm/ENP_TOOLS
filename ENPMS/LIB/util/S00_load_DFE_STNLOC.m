function [MAP_STATIONS] = S00_load_DFE_STNLOC(DFE_STATION_DATA_FILE)
% This script creates a container (MAP_STATIONS) with the structure
% (STATIONS); takes the station name (NAME), longitude (X), latitude (Y)
% from the input file

% Expected format of station metadata file (only fields with * are used):
% *   1. station
%     2. agency
%     3. station_type
%     4. basin
% *   5. ground_surface_elevation_ft
% *   6. lat_nad83
% *   7. long_nad83
% *   8. vertical_datum
%     9. utm_x
%    10. utm_y
%    11. last_change
%    12. comments
%    13. location_area
% *  14. NGVD29_NAVD88_conversion
%    15. park
%
% Note that this file can (and should) be generated with the following command:
%  echo "select * from station" | sql > myfile.txt

% field numbers  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15+
formatString = '%s %s %s %s %f %f %f %s %f %f %s %s %s %f %*[^\n]';

% This is the code for the old station data file format:
%    % Column Headers: 1.station, 2.agency, 3.station_type, 4.vertical_datum, 5.park,
%    % 6.lat_nad83, 7.long_nad83, 8.ground_surface_elevation_ft, 9.basin,
%    % 10.NGVD29_NAVD88_conversion, 11.comments
%    formatString = '%s %s %s %s %s %f %f %f %s %f %*[^\n]';


% read text file containing station metadata into variable ST
assert(exist(DFE_STATION_DATA_FILE,'file') == 2, 'File not found: %s', DFE_STATION_DATA_FILE);
fileID = fopen(DFE_STATION_DATA_FILE);
ST_file_data = textscan(fileID,formatString,'HeaderLines',0,'Delimiter','^','EmptyValue',NaN);
fclose(fileID);

% get number of stations read
numStations = length(ST_file_data{1});

% create an empty structure to save station data
STATION = struct(...
   'NAME',cell(1,numStations),...
   'elev_ngvd29_ft',cell(1,numStations),...
   'LAT',cell(1,numStations),...
   'LONG',cell(1,numStations),...
   'utmXmeters',cell(1,numStations),...
   'utmYmeters',cell(1,numStations),...
   'DFE_DATUM',cell(1,numStations),...
   'DFE_DATUM_CONV_FT',cell(1,numStations));

% create empty container to store station data
MAP_STATIONS = containers.Map();

% save data into STATION structure
stnName = upper(ST_file_data{1}); % convert all station names to UPPERCASE
elev_ft = ST_file_data{5};
lat = ST_file_data{6};
long = ST_file_data{7};
dfe_datum = ST_file_data{8};
NGVD_conversion_ft = ST_file_data{14};

% Process lat-long coordinates - derive UTM coordinates from lat-long
% convert NAD83 Lat and Long value to UTM, Zone 17
utm_input = [lat, long];
[utmXmeters, utmYmeters,utmZone] = ll2utm(utm_input); %converts LAT,LON (in degrees) to UTM X and Y (in meters). Datum is hardcoded to NAD83

% because we _assume_ utm zone 17 in our code, do a quick check here:
if utmZone ~= 17
   fprintf('\n *** Error with UTM calculation - lat lon not found or UTM Zone is not 17 for station %s*** \n', stnName);
end

% Create array which flags stations with no datum conversion values (Empty
% cell check)
emptyCONV=arrayfun(@isnan,NGVD_conversion_ft);

% iterate through the ST_file_data station data array,
% put station data in a structure called STATION,
% and save all STATIONs in the MAP_STATIONS container (station name is key)
for i = 1:numStations
   
   % convert NAVD88 ground surface elevation to NGVD29
   % if no elevation or no datum is found, set elevation to nan
   if strcmpi(dfe_datum(i), 'NGVD29')
      elev_ngvd29_ft(i) = elev_ft(i);
   elseif strcmpi(dfe_datum(i), 'NAVD88') && emptyCONV(i)==0 && NGVD_conversion_ft(i)~=0.0
      %dfe_datum{i} = 'NGVD29';
      elev_ngvd29_ft(i) = elev_ft(i) + NGVD_conversion_ft(i);
   else
      elev_ngvd29_ft(i) = nan;
   end
   
   % save data to STATION structure
   STATION(i).NAME = stnName(i); %(converted to upper case)
   STATION(i).LAT = lat(i);
   STATION(i).LONG = long(i);
   STATION(i).utmXmeters = utmXmeters(i);
   STATION(i).utmYmeters = utmYmeters(i);
   STATION(i).elev_ngvd29_ft = elev_ngvd29_ft(i);        % ground surface elevation in NGVD29
   %KB-this is misleading- remove:(hopefully not used later)% STATION(i).DFE_DATUM = dfe_datum(i);                  % Datum listed for station
   STATION(i).DFE_DATUM_CONV_FT = NGVD_conversion_ft(i); % conversion factor to NGVD29 from NAVD88. NGVD29 = NAVD88 + CONVERSION(negative values)
   
   % add STATION structure to MAP_STATIONS container (with name as key)
   MAP_STATIONS(char(stnName(i))) = STATION(i);
end

fclose('all');
fprintf('\n Station Location Data: Loaded \n');
end

