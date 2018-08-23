function D00_convert_STATION_DATA()
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
% path string of ROOT Directory
% -------------------------------------------------------------------------
[INI.ROOT,MAIN,~] = fileparts(pwd());
INI.ROOT = [INI.ROOT MAIN '/'];

% -------------------------------------------------------------------------
% path(s) to PARENT directory ('DATA_ENP') and all input ('_input') and output ('FLOW', 'STAGE', 'BC2D') file directories
% -------------------------------------------------------------------------
INI.DATA_ENP_DIR = [INI.ROOT 'DATA_ENP/'];
    % Input directories:
INI.input = [INI.DATA_ENP_DIR '_input/'];
    % DFS0 file creation from DFE input file directories
INI.STATION_DIR = [INI.DATA_ENP_DIR 'D00_STATIONS/'];
INI.FLOW_DIR = [INI.DATA_ENP_DIR 'D01_FLOW/'];
INI.STAGE_DIR = [INI.DATA_ENP_DIR 'D02_STAGE/'];
    % BC2D generation directories:
INI.BC2D_DIR = [INI.DATA_ENP_DIR 'G01_BC2D/'];

% -------------------------------------------------------------------------
% SETUP Location of ENPMS Scripts and Initialize
% -------------------------------------------------------------------------
INI.MATLAB_SCRIPTS = '.\ENPMS\';
%INI.MATLAB_SCRIPTS = [INI.ROOT 'ENP_TOOLS\ENPMS\'];

try
    addpath(genpath(INI.MATLAB_SCRIPTS));
catch
    addpath(genpath(INI.MATLAB_SCRIPTS,0));
end

INI.DELETE_EXISTING_DFS0 = 1;

%read station information in the current directory

SAVE_IN_MATLAB = 1;

FNDB = strcat('STATION_DATA','.MATLAB');

if SAVE_IN_MATLAB
   MAP_STATIONS = containers.Map();
   fileID = fopen([INI.input 'station_data_from_dataforever.txt']);
   ST = textscan(fileID,'%s %s %s %s %s %f32 %f32 %s %f32 %f32 %s %s %d8 %f32 %s','Delimiter','^','EmptyValue',NaN);
   fclose(fileID);
   for i = 1:length(ST{1})
      N = ST{1};
      X = ST{6};
      Y = ST{7};
      STATION(i).NAME = N(i);
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

