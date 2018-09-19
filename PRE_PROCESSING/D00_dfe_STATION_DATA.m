function D00_dfe_STATION_DATA()
% This script creates a container (MAP_STATIONS) with the structure 
% (STATIONS); takes the station name (NAME), longitude (X), latitude (Y) 
% from the input file (station_data_from_dataforever.txt), and an 
% additional container (MAP_STATIONS_DATA). The script then sends the 
% container (MAP_STATIONS) to the functions: summarize_dfs0_FLOW, 
% summarize_dfs0_STAGE before saving the data to the MatLAB binary file:
% (STATION_DATA.MATLAB).

% If the SAVE_IN_MATLAB switch (line: ) is '0', the data from the binary 
% file is loaded to the container (MAP_STATIONS).

% All container (MAP_STATION) data is then used to update the shape file
% ALL_STATIONS.shp by calling the function: update_ALL_STATIONS.

% Input File(s):       ALL_STATIONS.shp - GIS shapefile[points]
%                      station_data_from_dataforever.txt 
%                      STATION_DATA.MATLAB
%
% Output File(s):      ALL_STATIONS.shp - GIS shapefile[points] 
%                      STATION_DATA.MATLAB - matlab binary file
%
% Function call(s):    summarize_dfs0_FLOW
%                      summarize_dfs0_STAGE
%                      update_ALL_STATIONS

% -------------------------------------------------------------------------
% path string of ROOT Directory = DRIVE:/GIT/ENP_TOOLS MAIN Directory = PRE_PROCESSING
% -------------------------------------------------------------------------
[ROOT,MAIN,~] = fileparts(pwd());
TEMP = strsplit(ROOT,'\');

INI.ROOT = [TEMP{1} '/' TEMP{2} '/'];

% -------------------------------------------------------------------------
% Add path(s) to ENP_TOOLS and all other 1st level sub-directories
% -------------------------------------------------------------------------
INI.TOOLS_DIR = [INI.ROOT TEMP{3} '/'];
INI.SAMPLE_INPUT_DIR = [INI.ROOT 'ENP_TOOLS_Sample_Input/'];

clear TEMP ROOT MAIN
% -------------------------------------------------------------------------
% Add sub--directory path(s) for ENP_TOOLS directory
% -------------------------------------------------------------------------
INI.PRE_PROCESSING_DIR = [INI.TOOLS_DIR MAIN '/'];
    % Input directories:
INI.input = [INI.PRE_PROCESSING_DIR '_input/'];
    % DFS0 file creation from DFE input file directories
INI.STATION_DIR = [INI.PRE_PROCESSING_DIR 'D00_STATIONS/'];
INI.FLOW_DIR = [INI.PRE_PROCESSING_DIR 'D01_FLOW/'];
INI.STAGE_DIR = [INI.PRE_PROCESSING_DIR 'D02_STAGE/'];
    % BC2D generation directories:
INI.BC2D_DIR = [INI.PRE_PROCESSING_DIR 'G01_BC2D/'];

% -------------------------------------------------------------------------
% SETUP Location of ENPMS Scripts and Initialize
% -------------------------------------------------------------------------
INI.MATLAB_SCRIPTS = '../ENPMS/';

try
    addpath(genpath(INI.MATLAB_SCRIPTS));
catch
    addpath(genpath(INI.MATLAB_SCRIPTS,0));
end

% Save in MATLAB format? (0 = FALSE, 1 = TRUE)
SAVE_IN_MATLAB = 1;

% Delete existing DFS0 files? (0 = FALSE, 1 = TRUE)
INI.DELETE_EXISTING_DFS0 = 1;

% read station information in the current directory

FNDB = strcat('STATION_DATA','.MATLAB');

if SAVE_IN_MATLAB
   MAP_STATIONS = containers.Map();
   fileID = fopen([INI.input 'dfe_station_locations.csv']);
   formatString = '%s %s %f %f %f %f %*[^\n]';
   ST = textscan(fileID,formatString,'HeaderLines',1,'Delimiter',',','EmptyValue',NaN);
   NStation = length(ST{1});
   fclose(fileID);
   for i = 1:NStation
      N = ST{1};
      lat = ST{3};
      long = ST{4};
      utm_input = [lat, long];
%      Added coding for elevation and elevation conversion (if available) 
%      to the structure.
%      elev = ST{5};
%      elev_conv = ST{6};
      [X, Y] = ll2utm(utm_input);       % ll2utm() is a function located in ENPMS that converts lat/long data to utm.
      STATION(i).NAME = N(i);
      STATION(i).LAT = lat(i);
      STATION(i).LONG = long(i);
      STATION(i).X = X(i);
      STATION(i).Y = Y(i);
      MAP_STATIONS_DATA = containers.Map();
      STATION(i).MAP_STATIONS_DATA = MAP_STATIONS_DATA;
      MAP_STATIONS(char(N(i))) = STATION(i);
   end
   MAP_STATIONS = summarize_dfs0_FLOW(INI,MAP_STATIONS);
   
   MAP_STATIONS = summarize_dfs0_STAGE(INI,MAP_STATIONS);
   
   save(char(FNDB),'MAP_STATIONS','-v7.3');
else
   load(char(FNDB),'-mat');
end

MAP_STATIONS = update_ALL_STATIONS(INI,MAP_STATIONS) ;

end

