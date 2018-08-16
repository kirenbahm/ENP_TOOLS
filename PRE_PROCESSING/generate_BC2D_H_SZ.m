function generate_BC2D_H_SZ() 

% path string of ROOT Directory
[INI.ROOT,MAIN,~] = fileparts(pwd());
INI.ROOT = [INI.ROOT MAIN '/'];

% path(s) to PARENT directory ('DATA_ENP') and all input ('_input') and output ('FLOW', 'STAGE', 'BC2D') file directories
INI.DATA_ENP_DIR = [INI.ROOT 'DATA_ENP/'];
    % Input directories:
INI.input = [INI.DATA_ENP_DIR '_input/'];
    % DFS0 file creation from DFE input file directories
INI.STATION_DIR = [INI.DATA_ENP_DIR 'D00_STATIONS/'];
INI.FLOW_DIR = [INI.DATA_ENP_DIR 'D01_FLOW/'];
INI.STAGE_DIR = [INI.DATA_ENP_DIR 'D02_STAGE/'];
    % BC2D generation directories:
INI.BC2D_DIR = [INI.DATA_ENP_DIR 'G01_BC2D/'];

%---------------------------------------------------------------------
% 1. SETUP Location of ENPMS Scripts
%---------------------------------------------------------------------
INI.MATLAB_SCRIPTS = 'G:\GIT\ENP_TOOLS\ENPMS\';
%INI.MATLAB_SCRIPTS = [INI.ROOT 'ENP_TOOLS\ENPMS\'];
% Initialize path of ENPMS Scripts 
try
    addpath(genpath(INI.MATLAB_SCRIPTS));
catch
    addpath(genpath(INI.MATLAB_SCRIPTS,0));
end

% location of common scripts, functions, and miscellaneous tools
%addpath(genpath([INI.ROOT 'ENPMS/']));
%addpath(genpath([INI.DATA_ENP_DIR '_utilities/']));                        % add location of common/shared function utilities

INI.DELETE_EXISTING_DFS0 = 1;
% 
% [INI.ROOT,NAME,EXT] = fileparts(pwd()); % path string of ROOT Directory/
% INI.ROOT = [INI.ROOT '/'];
% INI.CURRENT_PATH =[char(pwd()) '/']; % path string of folder MAIN
% addpath(genpath('D:\Users\NYN\Desktop\MODELS_20170101\ANALYSIS\ENPMS'));
% INI.DELETE_EXISTING_DFS0 = 1;
INI.CREATE_FIGURES = 1;
SAVE_IN_MATLAB = 1; % to save the H data and the ALL_STATIONS data

% This function requires a directory where dfs0 are stored and a list of
% coordinates which will be used to generate the groundwater map. In
% additon, the function requires artificial stations far away enough in
% order to cover the entire area. The artificial stations can be developed
% as the average of several stations (or based on statistical analysis of a
% group of files. 

% the function develops OL and SZ water levels for the period between
% 1965-2015. The missing water levels are contsructed by grouping selected
% stations, analyzing the probability density function on a monthly basis,
% determining the parameters of the theoretical fit of the CDF and using
% the CDF to generate random values for points which are entirely missing.
% This approach provides relatively 

INI.DIR_DATA = [INI.STAGE_DIR 'DFS0DD/'];
INI.DATE_I = '1/1/1965'; 
INI.DATE_I = '1/1/1999'; 

INI.DATE_E = '12/31/2020';
INI.DATE_E = '12/31/2020';

INI.GIS = [INI.input 'BC2D_GIS/'];
INI.SHP_DOMAIN = [INI.GIS 'M06_DOMAIN_SF.shp'];

INI.SHPFILE1 = [INI.GIS 'ALL_STATIONS_SOUTH_FLORIDA.shp'];
INI.SHPFILE2 = [INI.GIS 'ALL_STATIONS.shp'];
INI.SHPFILE3 = [INI.GIS 'ALL_STATIONS_061217.shp'];

INI.XLSX = [INI.BC2D_DIR 'H_POINTS_DD.xlsx'];
INI.DFS2 = [INI.BC2D_DIR 'BC2D_H_SZ.dfs2'];
INI.SZ_H_MATLAB = [INI.BC2D_DIR 'SZ_H.MATLAB'];
INI.SZ_H_STATIONS_MATLAB = [INI.BC2D_DIR 'SZ_H_STATIONS.MATLAB'];

INI.X0 = 458400;% 559600; model_x = 458600
INI.Y0 = 2777500;% 2867500; model_y = 2777700
INI.LON= -81.412625;
INI.LAT = 25.112786;
INI.NY = -0.174293525822992; %-0.021205407096825
INI.DELT = 86400;
INI.cell = 1600;
INI.nx = ceil((559600-INI.X0)/1600);
INI.ny = ceil((2867500-INI.Y0)/1600);

% mapshow(INI.SHPFILE1);
% mapshow(INI.SHPFILE2);
% mapshow(INI.SHP_DOMAIN);

try
   addpath(genpath(INI.ROOT)); 
catch
   addpath(genpath(INI.ROOT,0));
end
% 1   2   3   4   5   6  7  8  9  10 11  12  13 14 15
%str str str str str %f %f str %f %f str str %d	%f str
%'%s %s %s %s %s %f32 %f32 %s %f32 %f32 %s %s %d8 %f32 %s'

%read station information in the current directory

FNDB = strcat('STATION_DATA','.MATLAB');

INI.MAP_STATIONS = containers.Map();

BC2D_read_shape(INI);
SWITCH = 'SZ';                  % This 'SWITCH' is used to identify the time increment used on the imported DFS0 files either SZ (daily) or OL (hourly)

if SAVE_IN_MATLAB
    INI = BC2D_import_dfs0(INI,SWITCH);
    % save data in strucures to load
    M = INI.MAP_H_DATA;
    save(char(INI.SZ_H_MATLAB),'M','-v7.3');
    M = INI.MAP_STATIONS;
    save(char(INI.SZ_H_STATIONS_MATLAB),'M','-v7.3');
    
    %save points in excel to convert to a shape file
    BC2D_save_H_points(INI,SWITCH);
    
    %not needed
    %INI = add_anchor_points (INI); % Commented out due to author comment
    %on being unnecessary
    
    % fill missing daily points using different methods
    INI = BC2D_fill_gaps_H_points(INI,SWITCH);
    
%    BC2D_save_dfs0_interpolated(INI);      % There is no script for this function.
    
    DATA_2D = BC2D_create_DFS2(INI);
    
    INI.MAP_H_DATA = BC2D_extractData2D(DATA_2D, INI.MAP_H_DATA);
    % plot points
    MAP_H_DATA = INI.MAP_H_DATA;
    save(char(INI.SZ_H_STATIONS_MATLAB),'MAP_H_DATA','-v7.3');
else
    load(char(INI.SZ_H_STATIONS_MATLAB),'-mat');
    INI.MAP_H_DATA = MAP_H_DATA;
end

BC2D_plot_all(INI,SWITCH);

end
