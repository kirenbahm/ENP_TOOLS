function MAP_STATIONS = summarize_dfs0_STAGE(INI,MAP_STATIONS)
% This script uses the input container (MAP_STATIONS) with the structure
% (STATIONS - values of NAME, X, Y, and MAP_STATIONS_DATA container) and
% updates the MAP_STATIONS_DATA container with the datatypes and the 
% nummber of observations for all DFS0 files located: DATA_ENP/STAGE/DFS0/

% From Function(s):    D01_convert_STATION_DATA.m
% Input Container(s):  MAP_STATIONS (w/ STATIONS, MAP_STATIONS_DATA)
% Input File(s):       DFS0 files within the DATA_ENP/STAGE/DFS0/ directory
%
% Output Container(s): MAP_STATIONS (w/ STATIONS, MAP_STATIONS_DATA) 
% Return Function(s):  D00_dfe_STATION_DATA.m
% -------------------------------------------------------------------------
DIR = [INI.STAGE_DIR 'DFS0/'];
FILES = [DIR '*.dfs0'];                                 % variable with the file description ( .dfs0 extension )and location ( DFS0 directory )
LIST = dir(FILES);

n = length(LIST);
for i = 1:n
   FILE_NAME = [DIR LIST(i).name];
   [~,F,~] = fileparts(FILE_NAME);
   C = strsplit(F,'.');
   STATION_NAME = C{1};
   TYPE = C{2};
   N_OBS = 0;
   try
      DFS0 = read_file_DFS0(FILE_NAME);
      N_OBS = length(DFS0.V);
      STATION = MAP_STATIONS(char(STATION_NAME));
      fprintf('... reading %d/%d: StationID: %s Datatype: %s with %d records.\n', i, n, char(STATION_NAME), char(TYPE), N_OBS);              % Prints to the screen a "working" message notifying user: reading 'iteration #' of 'total iterations' for 'station' : 'data type' with value '0' at 'Lat', 'Long'
      STATION.MAP_STATIONS_DATA(char(TYPE)) = N_OBS;
      MAP_STATIONS(char(STATION_NAME)) = STATION;
   catch
      fprintf('... notfound %d/%d: %s: %s: with N: %d: Records\n', i, n, char(STATION_NAME), char(TYPE),N_OBS);
   end
end

end
