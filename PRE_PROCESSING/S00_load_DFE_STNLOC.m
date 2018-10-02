function [MAP_STATIONS] = S00_load_DFE_STNLOC()
INI.DFE_STATION_DATA = '../../ENP_TOOLS_Sample_Input/Raw_DFE_Data/';
fileID = fopen([INI.DFE_STATION_DATA 'dfe_station_locations.csv']);

% Column Headers: station, agency, station_type, vertical_datum, park,
% lat_nad83, long_nad83, ground_surface_elevation_ft, basin,
% NGVD29_NAVD88_conversion, comments
formatString = '%s %s %s %s %s %f %f %f %s %f %*[^\n]';
ST = textscan(fileID,formatString,'HeaderLines',1,'Delimiter',',','EmptyValue',NaN);
NStation = length(ST{1});
fclose(fileID);

MAP_STATIONS = containers.Map();

STATION = struct('NAME',cell(1,NStation),'LAT',cell(1,NStation),'LONG',cell(1,NStation),...
    'X',cell(1,NStation),'Y',cell(1,NStation),'DATUM',cell(1,NStation),'ELEVATION',cell(1,NStation),...
    'CONV',cell(1,NStation));

N = ST{1};
lat = ST{6};
long = ST{7};
datum = ST{4};
elevation = ST{8};
NGVD_conversion = ST{10};
emptyCONV=arrayfun(@isnan,NGVD_conversion);   % Empty cell check

% convert NAD83 Lat and Long value to UTM, Zone 17
utm_input = [lat, long];
[X, Y] = ll2utm(utm_input);                     % ll2utm() is a function located in ENPMS that converts lat/long data to utm.

for i = 1:NStation
  % convert NAVD88 ground surface elevation to NGVD29
  if strcmpi(datum(i), 'NGVD29')
      % No changes required to elevation data
  elseif strcmpi(datum(i), 'NAVD88') && emptyCONV(i)==0
      datum{i} = 'NGVD29';
      elevation(i) = elevation(i) + NGVD_conversion(i);
  else
      elevation(i) = nan;
  end
  
  % Load the station location and elevation data to the MAP_STATIONS
  % container:
  STATION(i).NAME = N(i);
  STATION(i).LAT = lat(i);
  STATION(i).LONG = long(i);
  STATION(i).X = X(i);
  STATION(i).Y = Y(i);
  STATION(i).DATUM = datum(i);                    % NGVD29 or Empty
  STATION(i).ELEVATION = elevation(i);            % ground surface elevation in NGVD29
  STATION(i).CONV = NGVD_conversion(i);           % conversion factor to NGVD29 from NAVD88. NGVD29 = NAVD88 + CONVERSION(negative values)
    
  MAP_STATIONS(char(N(i))) = STATION(i);
end

fclose('all');
fprintf('\n Station Location Data: Loaded \n');
end

