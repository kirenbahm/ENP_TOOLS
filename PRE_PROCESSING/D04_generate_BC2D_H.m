function D04_generate_BC2D_H()

% This function requires artificial stations far away enough in
% order to cover the entire area. The artificial stations can be developed
% as the average of several stations (or based on statistical analysis of a
% group of files.


% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% BEGIN USER INPUT
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Set paths to directories and files
% -------------------------------------------------------------------------

% This 'SWITCH' is used to identify the time increment used on the imported DFS0 files either SZ (daily) or OL (hourly)
%INI.OLorSZ = 'SZ';
INI.OLorSZ = 'OL';

% Input directory:
INI.STAGE_DIR  = '../../ENP_FILES/ENP_TOOLS_Sample_Input/Obs_Processed_BC2D/in/';


% Use Fourier for creating BC2D maps, otherwise use Julian Day Average
% see below %    INI.USE_FOURIER_BC2D = false; 

% Output directory (also includes switch setting for Fourier):
INI.BC2D_DIR   = '../../ENP_TOOLS_Output/Obs_Processed_BC2D/out/BC2D-Julian/'; INI.USE_FOURIER_BC2D = false; 
%INI.BC2D_DIR   = '../../ENP_TOOLS_Output/Obs_Processed_BC2D/out/BC2D-Fourier/'; INI.USE_FOURIER_BC2D = true; 


% Location of ENPMS Scripts
INI.MATLAB_SCRIPTS = '../ENPMS/';

% -------------------------------------------------------------------------
% Settings and options
% -------------------------------------------------------------------------

INI.DATE_I = '01/01/2000'; % Should be format MM/dd/yyyy
INI.DATE_E = '12/31/2001'; % Should be format MM/dd/yyyy

% Save in MATLAB format? (0 = FALSE, 1 = TRUE)
SAVE_IN_MATLAB = 1;                                 % to save the H data and the ALL_STATIONS data

% Delete existing DFS0 files? (0 = FALSE, 1 = TRUE)
INI.DELETE_EXISTING_DFS0 = 1;

% Create plots of output? (0 = FALSE, 1 = TRUE)
INI.CREATE_FIGURES = 1;

% Create figures of just timeseries interpolation results? (0 = NO, 1 = YES)
% (Currently works with Fourier method only)
INI.CREATE_RESIDUALS_FIGURES = 0;

% -------------------------------------------------------------------------
% Grid info
% -------------------------------------------------------------------------
INI.X0 = 458600;  % UTM SW grid origin in meters
INI.Y0 = 2777800;
INI.LON= -81.41065021250006;
INI.LAT = 25.11550027870545;
INI.NY = -0.1743006671603; % geographic coordinate grid rotation

INI.cell = 1600;  % cell size of output in meters

INI.nx = ceil((558000-INI.X0)/INI.cell); % UTM grid NE corner coordinates
INI.ny = ceil((2867500-INI.Y0)/INI.cell);

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% END USER INPUT
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% Create output directory if it doesn't already exist
if ~exist(INI.BC2D_DIR, 'dir')
    mkdir(INI.BC2D_DIR)
end

if strcmpi(INI.OLorSZ,'OL')
    INI.DELT = 3600;
    INI.DIR_DATA             = [INI.STAGE_DIR 'DFS0HR/']; % use these for unit testing
    INI.XLSX                 = [INI.BC2D_DIR 'H_POINTS_HR.xlsx'];     % output
    INI.DFS2                 = [INI.BC2D_DIR 'BC2D_H_OL.dfs2'];       % output
    INI.OL_H_MATLAB          = [INI.BC2D_DIR 'OL_H.MATLAB'];          % output
    INI.OL_H_MATLAB_FILLED   = [INI.BC2D_DIR 'OL_H_FILLED.MATLAB'];
    INI.OL_H_STATIONS_MATLAB = [INI.BC2D_DIR 'OL_H_STATIONS.MATLAB']; % output
    INI.H_MATLAB             = INI.OL_H_MATLAB;          % hack to get OL and SZ in same script. fix later.
    INI.H_MATLAB_FILLED      = INI.OL_H_MATLAB_FILLED;   % hack to get OL and SZ in same script. fix later.
    INI.H_STATIONS_MATLAB    = INI.OL_H_STATIONS_MATLAB; % hack to get OL and SZ in same script. fix later.
elseif strcmpi(INI.OLorSZ,'SZ')
    INI.DELT = 86400;
    INI.DIR_DATA             = [INI.STAGE_DIR 'DFS0DD/']; % use these for unit testing
    INI.XLSX                 = [INI.BC2D_DIR 'H_POINTS_DD.xlsx'];     % output
    INI.DFS2                 = [INI.BC2D_DIR 'BC2D_H_SZ.dfs2'];       % output
    INI.SZ_H_MATLAB          = [INI.BC2D_DIR 'SZ_H.MATLAB'];          % output
    INI.SZ_H_MATLAB_FILLED   = [INI.BC2D_DIR 'SZ_H_FILLED.MATLAB'];
    INI.SZ_H_STATIONS_MATLAB = [INI.BC2D_DIR 'SZ_H_STATIONS.MATLAB']; % output
    INI.H_MATLAB             = INI.SZ_H_MATLAB;          % hack to get OL and SZ in same script. fix later.
    INI.H_MATLAB_FILLED      = INI.SZ_H_MATLAB_FILLED;   % hack to get OL and SZ in same script. fix later.
    INI.H_STATIONS_MATLAB    = INI.SZ_H_STATIONS_MATLAB; % hack to get OL and SZ in same script. fix later.
else
    fprintf('\n\n ERROR:  SWITCH not recognized as OL or SZ - problems may arise...\n\n');
end

% Check if required input FOLDERS exist
DirExist = exist(INI.DIR_DATA,'file') == 7;
if(~DirExist)
    fprintf('\nERROR: input directory was not found at %s.\n\n',char(INI.DIR_DATA));
end

INI.NSTEPS_FILE = [INI.BC2D_DIR 'NSTEPS.MATLAB'];

% -------------------------------------------------------------------------
% SETUP Location of ENPMS Scripts and Initialize
% -------------------------------------------------------------------------
try
    addpath(genpath(INI.MATLAB_SCRIPTS));
catch
    addpath(genpath(INI.MATLAB_SCRIPTS,0));
end

%Initialize .NET libraries
INI = initializeLIB(INI);


INI.MAP_STATIONS = containers.Map();

if SAVE_IN_MATLAB
    INI = BC2D_process_dfs0file_list(INI);
    
    % save data in strucures to load
    M = INI.MAP_H_DATA;
    save(char(INI.H_MATLAB),'M','-v7.3');
    
    M = INI.MAP_STATIONS;
    save(char(INI.H_STATIONS_MATLAB),'M','-v7.3');
    
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
    
    % extract points
    INI.MAP_H_DATA = BC2D_extractData2D(DATA_2D, INI.MAP_H_DATA);
    MAP_H_DATA = INI.MAP_H_DATA;
    save(char(INI.H_STATIONS_MATLAB),'MAP_H_DATA','-v7.3');
    
else
    load(char(INI.H_STATIONS_MATLAB),'-mat');
    INI.MAP_H_DATA = MAP_H_DATA;
end

if INI.CREATE_FIGURES
    BC2D_plot_all(INI);
end

fclose('all');
fprintf('\n DONE \n\n');
fprintf('\n\n *** NOTE THAT YOU MAY NEED TO MANUALLY EDIT THE DFS2 GEOGRAPHIC COORDINATES ***');
fprintf(  '\n                   FROM UTM-17 to NAD_1983_UTM_Zone_17N  \n\n');
fprintf('\n\n (also, after pressing OK, you will need to choose Keep Map Projection Coordinates and derive Geographical Coordinates \n');
end
