function D04_generate_BC2D_H_OL()

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
SAVE_IN_MATLAB = 1;                                 % to save the H data and the ALL_STATIONS data

% Delete existing DFS0 files? (0 = FALSE, 1 = TRUE)
INI.DELETE_EXISTING_DFS0 = 1;

INI.CREATE_FIGURES = 1;

% This function requires a directory where dfs0 are stored and a list of
% coordinates which will be used to generate the groundwater map. In
% additon, the function requires artificial stations far away enough in
% order to cover the entire area. The artificial stations can be developed
% as the average of several stations (or based on statistical analysis of a
% group of files. 

% the function develops OL and SZ water levels for the period between
% 1965-2015. The missing water levels are contructed by grouping selected
% stations, analyzing the probability density function on a monthly basis,
% determining the parameters of the theoretical fit of the CDF and using
% the CDF to generate random values for points which are entirely missing.
% This approach provides relatively 

INI.DIR_DATA = [INI.BC2D_DIR 'DFS0HR/'];
INI.DATE_I = '1/1/1999'; %/1/1/1965
INI.DATE_I = '1/1/1999'; %/1/1/1965

INI.DATE_E = '12/31/2020'; %/12/31/2020
INI.DATE_E = '12/31/2020'; %/12/31/2020

%INI.SHP_DOMAIN = './GIS/M06_DOMAIN_SF.shp';
INI.GIS = [INI.input 'BC2D_GIS/'];
INI.SHP_DOMAIN = [INI.GIS 'M06_DOMAIN_SF.shp'];

INI.SHPFILE1 = [INI.GIS 'ALL_STATIONS_SOUTH_FLORIDA.shp'];
INI.SHPFILE2 = [INI.GIS 'ALL_STATIONS.shp'];
INI.SHPFILE3 = [INI.GIS 'ALL_STATIONS_061217.shp'];

INI.XLSX = [INI.BC2D_DIR 'H_POINTS_HR.xlsx'];
INI.DFS2 = [INI.BC2D_DIR 'BC2D_H_OL.dfs2'];
INI.OL_H_MATLAB = [INI.BC2D_DIR 'OL_H.MATLAB'];
INI.OL_H_STATIONS_MATLAB = [INI.BC2D_DIR 'OL_H_STATIONS.MATLAB'];

INI.X0 = 458400;% 558000; model_x = 458600
INI.Y0 = 2777500;% 2867500; model_y = 2777700
INI.LON= -81.412625;
INI.LAT = 25.112786;
INI.NY = -0.174293525822992; %-0.021205407096825
INI.DELT = 3600;
INI.cell = 1600;
INI.nx = ceil((558000-INI.X0)/1600);
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
SWITCH = 'OL';                  % This 'SWITCH' is used to identify the time increment used on the imported DFS0 files either SZ (daily) or OL (hourly)

if SAVE_IN_MATLAB    
    INI = BC2D_import_dfs0(INI,SWITCH);
    % save data in strucures to load
    M = INI.MAP_H_DATA;
    if exist(INI.BC2D_DIR, 'dir')
        save(char(INI.OL_H_MATLAB),'M','-v7.3');
    else
        mkdir(INI.BC2D_DIR)
        save(char(INI.OL_H_MATLAB),'M','-v7.3');
    end
    M = INI.MAP_STATIONS;
    save(char(INI.OL_H_STATIONS_MATLAB),'M','-v7.3');
    
    %save points in excel to convert to a shape file
    BC2D_save_H_points(INI,SWITCH);
    
    %not needed
    %INI = add_anchor_points (INI); % Commented out due to author comment
    %on being unnecessary

    % fill missing daily points using different methods
    INI = BC2D_fill_gaps_H_points(INI,SWITCH);
    
    DATA_2D = BC2D_create_DFS2(INI);
    
    INI.MAP_H_DATA = BC2D_extractData2D(DATA_2D, INI.MAP_H_DATA);
    % plot points
    MAP_H_DATA = INI.MAP_H_DATA;
    save(char(INI.OL_H_STATIONS_MATLAB),'MAP_H_DATA','-v7.3');
else
    load(char(INI.OL_H_STATIONS_MATLAB),'-mat');
    INI.MAP_H_DATA = MAP_H_DATA;
end

BC2D_plot_all(INI,SWITCH);

end
