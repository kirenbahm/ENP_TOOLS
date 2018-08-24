function MAP_STATIONS = summarize_dfs0_FLOW(INI,MAP_STATIONS)
% This script uses the input container (MAP_STATIONS) with the structure
% (STATIONS - values of NAME, X, Y, and MAP_STATIONS_DATA container) and
% updates the MAP_STATIONS_DATA container with the datatypes and the 
% nummber of observations for all DFS0 files located: DATA_ENP/FLOW/DFS0/

% From Function(s):    D01_convert_STATION_DATA.m
% Input Container(s):  MAP_STATIONS (w/ STATIONS, MAP_STATIONS_DATA)
% Input File(s):       DFS0 files within the DATA_ENP/FLOW/DFS0/ directory
%
% Output Container(s): MAP_STATIONS (w/ STATIONS, MAP_STATIONS_DATA) 
% Return Function(s):  D00_dfe_STATION_DATA.m
% -------------------------------------------------------------------------
DIR = [INI.FLOW_DIR 'DFS0/'];
FILES = [DIR '*.dfs0'];                                 % variable with the file description ( .dfs0 extension )and location ( DFS0 directory )
LIST = dir(FILES);                                      % creates the LIST structure of all files that meet the description and location values in DIR, the structure has a number of arrays equal to the number of files and each array has the following: name, folder, date, bytes, isdir, datenum

n = length(LIST);                                       % sets value length of the structure (the number of files in this instance)
for i = 1:n
   FILE_NAME = [DIR LIST(i).name];                      % sets FILE_NAME value a known directory location (same as source) and to the i-th filename on the LIST
   [~,F,~] = fileparts(FILE_NAME);                      % creates the variables D, F, E where D = Directory location of the file, F = the File name, and E = file Extension (.dfs0 here) fpr each iteration of FILE_NAME
   C = strsplit(F,'.');                                 % breaks apart 'F' by the '_' delimeter and creates the 'C' array
   STATION_NAME = C{1};                                 % populates the STATION_NAME variable with position '1' of array 'C'
   TYPE = C{2};                                  % new variable written as script 'Discharge'
   N_OBS = 0;                                           % Sets number of observations to 0
   try
      DFS0 = read_file_DFS0(FILE_NAME);                 % reads in the data from FILE_NAME into variable DFS0, DFS0 is a structure based on the dimensions of the read-in file.
      N_OBS = length(DFS0.V);                           % populates the variable 'N_OBS' with the length of field 'V' of structure 'DFS0'
      STATION = MAP_STATIONS(char(STATION_NAME));       % sets up a structure 'STATION' based on the design of container 'MAP_STATIONS' and matches the 'STATION_NAME' variable from the DFS0 file 
      fprintf('... reading %d/%d: StationID: %s Datatype: %s with %d records.\n', i, n, char(STATION_NAME), char(TYPE),N_OBS);              % Prints to the screen a "working" message notifying user: reading 'iteration #' of 'total iterations' for 'station' : 'data type' with value '0' at 'Lat', 'Long'
      STATION.MAP_STATIONS_DATA(char(TYPE)) = N_OBS;    % Sets the Observation number to '0' for the Discharge 'TYPE' value within the 'MAP_STATIONS_DATA' container
      MAP_STATIONS(char(STATION_NAME)) = STATION;       % Updates the 'STATION' value to 'MAP_STATIONS' container
   catch
      fprintf('... notfound %d/%d: %s: %s: with N: %d: Records\n', i, n, char(STATION_NAME), char(TYPE),N_OBS);
   end
end

end
