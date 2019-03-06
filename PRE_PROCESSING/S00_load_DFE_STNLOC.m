function [MAP_STATIONS] = S00_load_DFE_STNLOC(DFE_STATION_DATA_FILE)
% This script creates a container (MAP_STATIONS) with the structure 
% (STATIONS); takes the station name (NAME), longitude (X), latitude (Y) 
% from the input file 
fileID = fopen(DFE_STATION_DATA_FILE);

% Column Headers: station, agency, station_type, vertical_datum, park,
% lat_nad83, long_nad83, ground_surface_elevation_ft, basin,
% NGVD29_NAVD88_conversion, comments
formatString = '%s %s %s %s %s %f %f %f %s %f %*[^\n]';

% read text file containing station metadata into variable ST
ST = textscan(fileID,formatString,'HeaderLines',1,'Delimiter',',','EmptyValue',NaN);

% get number of stations read
numStations = length(ST{1});
fclose(fileID);

MAP_STATIONS = containers.Map();

% create an empty structure to save station data
STATION = struct('NAME',cell(1,numStations),'LAT',cell(1,numStations),'LONG',cell(1,numStations),...
    'X',cell(1,numStations),'Y',cell(1,numStations),'DATUM',cell(1,numStations),'ELEVATION',cell(1,numStations),...
    'CONV',cell(1,numStations));

% save data into STATION structure
stnName = ST{1};
lat = ST{6};
long = ST{7};
datum = ST{4};
elev_ngvd29_ft = ST{8};
NGVD_conversion = ST{10};

% Empty cell check
emptyCONV=arrayfun(@isnan,NGVD_conversion);   % Empty cell check

% convert NAD83 Lat and Long value to UTM, Zone 17
utm_input = [lat, long];
[utmXmeters, utmYmeters] = ll2utm(utm_input); %converts LAT,LON (in degrees) to UTM X and Y (in meters). Datum is hardcoded to NAD83

% iterate through the ST station data array,
% put station data in a structure called STATION,
% and save all STATIONs in the MAP_STATIONS container (station name is key) 
for i = 1:numStations
  % convert NAVD88 ground surface elevation to NGVD29
  % if no elevation or no datum is found, set elevation to nan
  if strcmpi(datum(i), 'NGVD29')
      % No changes required to elevation data
  elseif strcmpi(datum(i), 'NAVD88') && emptyCONV(i)==0
      datum{i} = 'NGVD29';
      elev_ngvd29_ft(i) = elev_ngvd29_ft(i) + NGVD_conversion(i);
  else
      elev_ngvd29_ft(i) = nan;
  end
  
  % save data to STATION structure
  STATION(i).NAME = stnName(i);
  STATION(i).LAT = lat(i);
  STATION(i).LONG = long(i);
  STATION(i).utmXmeters = utmXmeters(i);
  STATION(i).utmYmeters = utmYmeters(i);
  STATION(i).DATUM = datum(i);                    % NGVD29 or Empty
  STATION(i).ELEV_NGVD29_FT = elev_ngvd29_ft(i);  % ground surface elevation in NGVD29
  STATION(i).CONV = NGVD_conversion(i);           % conversion factor to NGVD29 from NAVD88. NGVD29 = NAVD88 + CONVERSION(negative values)
    
  % save STATION structure to MAP_STATIONS container (with name as key)
  MAP_STATIONS(char(stnName(i))) = STATION(i);
end

fclose('all');
fprintf('\n Station Location Data: Loaded \n');
end

