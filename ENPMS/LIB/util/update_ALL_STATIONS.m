function MAP_STATIONS = update_ALL_STATIONS(INI,MAP_STATIONS)
% This script uses the input container (MAP_STATIONS) with the structure
% (STATIONS - values of NAME, X, Y, and MAP_STATIONS_DATA container) with
% updated number of observations for 'Discharge' using the function call: 
% summarize_dfs0_FLOW and all datatypes from the function call: 
% summarize_dfs0_STAGE. The shape file is updated with 5 fields: n_H, n_HW,
% n_TW, n_PSU, and n_Q for stage, headwater, tailwater, salinity, and
% discharge. If there are no datatype keys for the MAP_STATIONS_DATA 
% container, the field value for each is defaulted to zero.

% From Function(s):    D01_convert_STATION_DATA.m
%
% Input File(s):       ALL_STATIONS.shp - GIS shapefile[points]
%
% Input Container(s):  MAP_STATIONS (w/ STATIONS, MAP_STATIONS_DATA)
%
% Output File(s):      ALL_STATIONS.shp - GIS shapefile[points]
%                      Located: ./DATA_ENP/_input/GIS/
%
% Return Function(s):  D01_convert_STATION_DATA.m
% -------------------------------------------------------------------------

DIR = [INI.input 'GIS/'];                      % sets GIS directory to the DIR variable. Verify the directory location if this causes an error. Completed directory location.
SHP = [DIR 'DFE_STATION_SUMMARY.shp'];                             % File name of all station GIS info as SHP variable

[S] = shaperead(char(SHP));                                 % char() converts data in SHP variable to character strings. shaperead() is in the Mapping Toolbox, reads in the attribute table {FID, Shape, Station, Type, N, LAT, LONG, X_UTM, Y_UTM, M01, M02, M03, M04, M05, M06} as the matrix [S] 
n = length(S);                                              % returns the length of the largest array dimension for matrix [S]

for i = 1:n
   NAME = S(i).STATION;                                     % Reads in each Station Name -corrected to 'S(i).STATION' from 'S(i).ST' - NOT SURE WHAT ST is for this structure?
   
   try
      STATION = MAP_STATIONS(strtrim(char(NAME)));          % Load each station (NAME) structure from MAP_STATIONS container
      M = STATION.MAP_STATIONS_DATA;                        % M = values from the MAP_STATION_DATA container for a specific station, from 'NAME' STATION struct
      K = M.keys;                                           % Loads the datatype container 'keys' for the selected station
      if isempty(M.keys)
         fprintf('... setting %s records to zero, no matching DFS0 with DFE Station ID: %s \n', char(NAME), strtrim(char(NAME)));
         S(i).LAT = STATION.LAT;                        % Updates location information from DFE data file
         S(i).LONG = STATION.LONG;
         S(i).X_UTM = STATION.X;
         S(i).Y_UTM = STATION.Y;
         S(i).n_H = 0;                                      % Sets the initial value for n_H to '0'
         S(i).n_HW = 0;                                     % Sets the initial value for n_HW to '0'
         S(i).n_TW = 0;                                     % Sets the initial value for n_TW to '0'
         S(i).n_PSU = 0;                                    % Sets the initial value for n_PSU to '0'
         S(i).n_Q = 0;                                      % Sets the initial value for n_Q to '0'
         continue
      else
         for k = K
             nn = M(char(k));
             S(i).LAT = STATION.LAT;                        % Updates location information from DFE data file
             S(i).LONG = STATION.LONG;
             S(i).X_UTM = STATION.X;
             S(i).Y_UTM = STATION.Y;
             S(i).n_H = 0;                                  % Sets the initial value for n_H to '0'
             S(i).n_HW = 0;                                 % Sets the initial value for n_HW to '0'
             S(i).n_TW = 0;                                 % Sets the initial value for n_TW to '0'
             S(i).n_PSU = 0;                                % Sets the initial value for n_PSU to '0'
             S(i).n_Q = 0;                                  % Sets the initial value for n_Q to '0'
             
             if strcmpi(k,'stage')                           % if the selected datatype 'key' from the M.keys array = the statement datatype ('stage' here) it populates the field with the number of observations value calculated from the DFS0 file
                 S(i).n_H = nn;
                 fprintf('... Station match: %s, setting "%s" record quantity. \n', strtrim(char(NAME)), char(k));
             elseif strcmpi(k,'head_water')                      % see note on line: 54
                 S(i).n_HW = nn;
                 fprintf('... Station match: %s, setting "%s" record quantity. \n', strtrim(char(NAME)), char(k));
             elseif strcmpi(k,'tail_water')                      % see note on line: 54
                 S(i).n_TW = nn;
                 fprintf('... Station match: %s, setting "%s" record quantity. \n', strtrim(char(NAME)), char(k));
             elseif strcmpi(k,'salinity')                        % see note on line: 54
                 S(i).n_PSU = nn;
                 fprintf('... Station match: %s, setting "%s" record quantity. \n', strtrim(char(NAME)), char(k));
             elseif strcmpi(k,'discharge')||strcmpi(k,'flow')    % see note on line: 54
                 S(i).n_Q = nn;
                 fprintf('... Station match: %s, setting "%s" record quantity. \n', strtrim(char(NAME)), char(k));
             else
                 fprintf('... NO "%s" datatype match for Station ID: %s: \n', char(k), char(NAME));
             end
         end
      end
   catch
      fprintf('... NO DFS0 match with dfe_station_locations.csv Station ID: %s: \n', char(NAME));
   end
   
end

shapewrite(S,char(SHP));

end
