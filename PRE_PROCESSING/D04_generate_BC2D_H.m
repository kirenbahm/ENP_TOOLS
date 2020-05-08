function D04_generate_BC2D_H()

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% BEGIN USER INPUT
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Set paths to directories and files
% -------------------------------------------------------------------------
 
% This 'SWITCH' is used to identify the time increment used on the imported DFS0 files either SZ (daily) or OL (hourly)
INI.OLorSZ = 'SZ';
%INI.OLorSZ = 'OL';

% Input directories and files:

INI.INPUT_DIR  = '../../ENP_FILES/ENP_TOOLS_Sample_Input/'; % use these for unit testing
INI.GIS        = [INI.INPUT_DIR 'Obs_Data_Processed/BC2D_GIS/']; % use these for unit testing
INI.STAGE_DIR  = [INI.INPUT_DIR 'Obs_Data_Processed/STAGE_for_BC2D/']; % use these for unit testing

% Output directory and file:
INI.BC2D_DIR   = '../../ENP_TOOLS_Output/D04_generate_BC2D_H/Obs_Data_Processed/BC2D/'; % use these for unit testing
if ~exist(INI.BC2D_DIR, 'dir')
   mkdir(INI.BC2D_DIR)
end

if strcmpi(INI.OLorSZ,'OL')
	INI.DELT = 3600;
	INI.DIR_DATA   = [INI.INPUT_DIR 'Obs_Data_Processed/STAGE_for_BC2D/DFS0HR/']; % use these for unit testing
	INI.XLSX                 = [INI.BC2D_DIR 'H_POINTS_HR.xlsx'];     % output
	INI.DFS2                 = [INI.BC2D_DIR 'BC2D_H_OL.dfs2'];       % output
	INI.OL_H_MATLAB          = [INI.BC2D_DIR 'OL_H.MATLAB'];          % output
	INI.OL_H_MATLAB_FILLED   = [INI.BC2D_DIR 'OL_H_FILLED.MATLAB'];
	INI.OL_H_STATIONS_MATLAB = [INI.BC2D_DIR 'OL_H_STATIONS.MATLAB']; % output
	INI.H_MATLAB = INI.OL_H_MATLAB;                   % hack to get OL and SZ in same script. fix later.
	INI.H_MATLAB_FILLED = INI.OL_H_MATLAB_FILLED;     % hack to get OL and SZ in same script. fix later.
	INI.H_STATIONS_MATLAB = INI.OL_H_STATIONS_MATLAB; % hack to get OL and SZ in same script. fix later.
elseif strcmpi(INI.OLorSZ,'SZ')
	INI.DELT = 86400;
	INI.DIR_DATA   = [INI.INPUT_DIR 'Obs_Data_Processed/STAGE_for_BC2D/DFS0DD/']; % use these for unit testing
	INI.XLSX                 = [INI.BC2D_DIR 'H_POINTS_DD.xlsx'];     % output
	INI.DFS2                 = [INI.BC2D_DIR 'BC2D_H_SZ.dfs2'];       % output
	INI.SZ_H_MATLAB          = [INI.BC2D_DIR 'SZ_H.MATLAB'];          % output
	INI.SZ_H_MATLAB_FILLED   = [INI.BC2D_DIR 'SZ_H_FILLED.MATLAB'];
	INI.SZ_H_STATIONS_MATLAB = [INI.BC2D_DIR 'SZ_H_STATIONS.MATLAB']; % output
	INI.H_MATLAB = INI.SZ_H_MATLAB;                   % hack to get OL and SZ in same script. fix later.
	INI.H_MATLAB_FILLED = INI.SZ_H_MATLAB_FILLED;     % hack to get OL and SZ in same script. fix later.
	INI.H_STATIONS_MATLAB = INI.SZ_H_STATIONS_MATLAB; % hack to get OL and SZ in same script. fix later.
else
    fprintf('\n\n ERROR:  SWITCH not recognized as OL or SZ - problems may arise...\n\n');
end

INI.SHP_DOMAIN = [INI.GIS 'M06_DOMAIN_SF.shp'];              % input
INI.SHPFILE1   = [INI.GIS 'ALL_STATIONS_SOUTH_FLORIDA.shp']; % input
INI.SHPFILE2   = [INI.GIS 'ALL_STATIONS.shp'];               % input
INI.SHPFILE3   = [INI.GIS 'ALL_STATIONS_061217.shp'];        % input

INI.NSTEPS_FILE = [INI.BC2D_DIR 'NSTEPS.MATLAB'];
% -------------------------------------------------------------------------
% SETUP Location of ENPMS Scripts and Initialize
% -------------------------------------------------------------------------
INI.MATLAB_SCRIPTS = '../ENPMS/';

try
    addpath(genpath(INI.MATLAB_SCRIPTS));
catch
    addpath(genpath(INI.MATLAB_SCRIPTS,0));
end

%Initialize .NET libraries
INI = initializeLIB(INI);

% -------------------------------------------------------------------------
% Settings and options
% -------------------------------------------------------------------------

% Save in MATLAB format? (0 = FALSE, 1 = TRUE)
SAVE_IN_MATLAB = 1;                                 % to save the H data and the ALL_STATIONS data

% Delete existing DFS0 files? (0 = FALSE, 1 = TRUE)
INI.DELETE_EXISTING_DFS0 = 1;

INI.CREATE_FIGURES = 0;

% This function requires a directory where dfs0 are stored and a list of
% coordinates which will be used to generate the groundwater map. In
% additon, the function requires artificial stations far away enough in
% order to cover the entire area. The artificial stations can be developed
% as the average of several stations (or based on statistical analysis of a
% group of files. 

% the function develops OL and SZ water levels for the period between
% 1965-2015. The missing water levels are constructed by grouping selected
% stations, analyzing the probability density function on a monthly basis,
% determining the parameters of the theoretical fit of the CDF and using
% the CDF to generate random values for points which are entirely missing.
% This approach provides relatively 

INI.DATE_I = '1/1/1999'; 
INI.DATE_E = '12/31/2018'; 

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% END USER INPUT
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% *****  OLD VALUES  ******
% INI.X0 = 458400;
% INI.Y0 = 2777500;
% INI.LON= -81.412625;
% INI.LAT = 25.112786;
% INI.NY = -0.1742935;
% *****  OLD VALUES  ******

% *****  NEW VALUES  ******
INI.X0 = 458600;
INI.Y0 = 2777800;
INI.LON= -81.41065021250006;
INI.LAT = 25.11550027870545;
INI.NY = -0.1743006671603;
% *****  NEW VALUES  ******


INI.cell = 1600;
INI.nx = ceil((558000-INI.X0)/1600);
INI.ny = ceil((2867500-INI.Y0)/1600);

% mapshow(INI.SHPFILE1);
% mapshow(INI.SHPFILE2);
% mapshow(INI.SHP_DOMAIN);

% 1   2   3   4   5   6  7  8  9  10 11  12  13 14 15
%str str str str str %f %f str %f %f str str %d	%f str
%'%s %s %s %s %s %f32 %f32 %s %f32 %f32 %s %s %d8 %f32 %s'

%read station information in the current directory
%FNDB = strcat('STATION_DATA','.MATLAB');

INI.MAP_STATIONS = containers.Map();

BC2D_read_shape(INI); % (function input: INI.SHPFILE1,2,3,  output: INI.MAP_STATIONS)

if SAVE_IN_MATLAB    
     INI = BC2D_import_dfs0(INI);
 
     % save data in strucures to load
     M = INI.MAP_H_DATA;
     save(char(INI.H_MATLAB),'M','-v7.3');
 
     M = INI.MAP_STATIONS;
     save(char(INI.H_STATIONS_MATLAB),'M','-v7.3');
     
     %save points in excel to convert to a shape file
     BC2D_save_H_points(INI);
     
     %not needed
     %INI = add_anchor_points (INI); % Commented out due to author comment
     %on being unnecessary
 
     % fill missing daily points using different methods
     INI = BC2D_fill_gaps_H_points(INI);
     M = INI.MAP_H_DATA;
     Q = INI.NSTEPS;
    save(char(INI.NSTEPS_FILE),'Q','-v7.3');
    save(char(INI.H_MATLAB_FILLED),'M','-v7.3');
   
    % create dfs2
    load(char(INI.NSTEPS_FILE),'-mat');
    load(char(INI.H_MATLAB_FILLED),'-mat');
    DATA_2D = BC2D_create_DFS2(INI);
    
    % plot points
    INI.MAP_H_DATA = BC2D_extractData2D(DATA_2D, INI.MAP_H_DATA);
    MAP_H_DATA = INI.MAP_H_DATA;
    save(char(INI.H_STATIONS_MATLAB),'MAP_H_DATA','-v7.3');

else
    load(char(INI.H_STATIONS_MATLAB),'-mat');
    INI.MAP_H_DATA = MAP_H_DATA;
end

BC2D_plot_all(INI);

end
