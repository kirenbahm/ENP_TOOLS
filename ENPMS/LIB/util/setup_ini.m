
function INI = setup_ini(INI,U)


% setup_ini(INI) SETS UP additionall options which rarely change but if
% user decides to modify some of the options here, there sill be impact on
% the analysis in subsequent files

INI.DATUM = 'NGVD29';
INI.DATADIR = INI.DATA_COMPUTED;
% % % INI.STATION_DATA   = [U.STATION_DATA];
% % % INI.NO_OBS_STATION_LIST = [U.NO_OBS_STATION_LIST];
% % % INI.MAPF = [U.MAPF];

% Assign the same of Seeapge Map U.MAPF to the Excel outup file:
% % % [D,N,E] = fileparts(char(INI.MAPF));
% % % INI.fileXL = [D '/' INI.ANALYSIS_TAG '/' INI.ANALYSIS_TAG '_' N '.xlsx'];

% path for a log file which will record all exceptions
INI.LOGFILE = [INI.POST_PROC_DIR  INI.ANALYSIS_TAG '/_LOGFILE.TXT'];

% GRAPHICS_PROPERTIES Color order
INI.GRAPHICS_CO = {'r', 'k', 'b', '[0 0.5 0]', ...
                   'm', 'b', 'k', '[0 0.5 0]', ...
                   'c', 'm', 'k', '[0 0.5 0]', ...
                   'b', 'm', 'b','[0 0.5 0]'};
               
% GRAPHICS_PROPERTIES Color order prefered method for better colors
INI.GRAPHICS_CO = {[1 0 0], [0 0 0], [0 0 1], [0 0.5 0], ...
                   [1 0 1], [0 0 1], [0 0 0], [0 0.5 0], ... 
                   [0 1 1], [1 0 1], [0 0 0], [0 0.5 0], ...
                   [0 0 1], [1 0 1], [0 0 1]};
INI.COLORS_ALPHA = 0.5;
INI.GRAPHICS_LS = {'none','-','-','-','-','-.','-.','-.','-.','-.',':','-','-','-','-','-.','-.'};
INI.GRAPHICS_M = {'s','none','none','none','none','none','none','none','none','none','none','none','none','none','none'};
INI.GRAPHICS_MSZ = [ 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3];
INI.GRAPHICS_LW = [ 1 1 1 1 1 1 1 1 1 1 3 3 3 3 3];
INI.GRAPHICS_FS = 12;
INI.GRAPHICS_FN = 'times';

%---------------------------------------------------------------------
% CHOOSE MODEL OUTPUT FILES TO EXTRACT DATA FROM   1=yes, 0=no
%---------------------------------------------------------------------

INI.LOAD_MOLUZ    = 1;  % Detailed Timeseries stored on UZ/OC timesteps (loads all items)
INI.LOAD_M11      = 1;  % Detailed Timeseries (loads all items)
INI.LOAD_MSHE     = 1;  % Detailed Timeseries (loads all items)
INI.LOAD_OL       = 0;  % Overland dfs2 file (loads cells defined in xls spreadsheet)
INI.LOAD_3DSZQ    = 0;  % Saturated zone dfs3 flow file (loads cells defined in xls spreadsheet)

INI.OVERWRITE_MON_PTS = 0; % this regenerates the monitoring points from
%                             the corresponding EXCEL file. If this is 0
%                            monitoring points come from a matlab data file
%                            MONPOINTS.MATLAB
INI.OVERWRITE_GRID_XL = 0; % this regenerates the gridded points from
%                             the corresponding EXCEL file. If this is 0
%                            monitoring points come from a matlab data file
%                            the same as the excel file but ext .MATLAB
%---------------------------------------------------------------------
% CHOOSE GROUP DEFINITIONS FOR EXTRACTING GRIDDED DATASETS
% (This gets used if INI.LOAD_OL=1 or INI.LOAD_3DSZQ=1)
%---------------------------------------------------------------------

%!!! The settings below are in setup_ini() to keep the convention that
% user defined options are in setup_ini(), get_INI() should be used to
% populate, or compute, some variables which may be used in any function by
% passing the structure INI as a function argument (this is to avoid
% global values)

% Overland Flow File
% % % i=1;
% % % INI.CELL_DEF_FILE_DIR_OL   = 'E:\home\ENPMS\ANALYZE_TEMPLATE\';
% % % INI.CELL_DEF_FILE_NAME_OL  = 'Transects_v14';
% % % INI.CELL_DEF_FILE_SHEETNAME_OL{i} = 'OLQ'; i=i+1;
% % % INI.CELL_DEF_FILE_SHEETNAME_OL{i} = 'OL2RIV'; i=i+1;
% % % 
% % % % 3D Saturated Zone Flow file
% % % i=1;
% % % INI.CELL_DEF_FILE_DIR_3DSZQ   = 'E:\home\ENPMS\ANALYZE_TEMPLATE\';
% % % INI.CELL_DEF_FILE_NAME_3DSZQ  = 'Transects_v14';
% % % INI.CELL_DEF_FILE_SHEETNAME_3DSZQ{i} = 'SZQ'; i=i+1;
% % % INI.CELL_DEF_FILE_SHEETNAME_3DSZQ{i} = 'SZunderRIV'; i=i+1;
% % % INI.CELL_DEF_FILE_SHEETNAME_3DSZQ{i} = 'SZ2RIV'; i=i+1;

%---------------------------------------------------------------------
%  INITIALILIZE STRUCTURE INI
%---------------------------------------------------------------------

fprintf('... ANALYZING SIMULATIONS:\n');
if isfield(INI,'MODEL_SIMULATION_SET')
    for i = 1:length(INI.MODEL_SIMULATION_SET)
        A = INI.MODEL_SIMULATION_SET{1,i}{1,1};
        B = INI.MODEL_SIMULATION_SET{1,i}{1,2};
        C = INI.MODEL_SIMULATION_SET{1,i}{1,3};
        INI.MODEL_SIMULATION_SET{1,i}{1,1} = [A B '.she - Result Files'];
        fprintf('SIMULATION: %s LEGEND: %s\n', B, C);
    end
else
    INI.MODEL_SIMULATION_SET = [];
    fprintf('... INI.MODEL_SIMULATION_SET = [], only oberved will be plotted:\n');
end

INI.PATHDIR = INI.MATLAB_SCRIPTS;
INI.MATDIR =  [INI.MATLAB_SCRIPTS 'LIB/'];
INI.SCRIPTDIR   = [INI.MATLAB_SCRIPTS 'DATA_LATEX/'];

% Directory to store all analyses
INI.ANALYSIS_DIR = INI.POST_PROC_DIR;
fprintf('Current directory, all analysis will be stored in: %s\n\n',INI.ANALYSIS_DIR);
INI.ANALYSIS_DIR_TAG = [INI.ANALYSIS_DIR INI.ANALYSIS_TAG];  % postproc directory for postproc run (no edits needed here)
INI.DATA_DIR         = [INI.ANALYSIS_DIR_TAG '/data'];  % data dir in output for extracted matlab files
INI.LATEX_DIR        = [INI.ANALYSIS_DIR_TAG '/latex/'];
INI.FIGURES_DIR      = [INI.ANALYSIS_DIR_TAG '/figures'];  % figures dir in output
INI.FIGURES_DIR_TS   = [INI.ANALYSIS_DIR_TAG '/figures/timeseries'];
INI.FIGURES_DIR_BP   = [INI.ANALYSIS_DIR_TAG '/figures/boxplots'];
INI.FIGURES_DIR_EXC  = [INI.ANALYSIS_DIR_TAG '/figures/exceedance'];
INI.FIGURES_DIR_MAPS = [INI.ANALYSIS_DIR_TAG '/figures/maps'];
INI.FIGURES_RELATIVE_DIR = ['../figures']; % the relative path name to figs dir for includegraphics

% The computed and observed timeseries data for the observation locations -
INI.FILESAVE_TS = [INI.ANALYSIS_DIR_TAG  '/' INI.ANALYSIS_TAG '_TIMESERIES_DATA.MATLAB'];
% The computed and observed statistics data
INI.FILESAVE_STAT = [INI.ANALYSIS_DIR_TAG '/' INI.ANALYSIS_TAG   '_TIMESERIES_STAT.MATLAB'];

%---------------------------------------------------------------
% SET UP DIRECTORIES AND SUPPORTING FILES
%---------------------------------------------------------------
if ~exist(INI.ANALYSIS_DIR,'file'),     mkdir(INI.ANALYSIS_DIR), end  % Create analysis directory if it doesn't exist already
if ~exist(INI.ANALYSIS_DIR_TAG,'file'), mkdir(INI.ANALYSIS_DIR_TAG), end  % create postproc directory for postproc run (no edits needed here)
if ~exist(INI.DATA_DIR,'file'),         mkdir(INI.DATA_DIR), end %Create a data dir in output for extracted matlab files
if ~exist(INI.FIGURES_DIR,'file'),      mkdir(INI.FIGURES_DIR), end  %Create a figures dir in output
if ~exist(INI.FIGURES_DIR_TS,'file'),   mkdir(INI.FIGURES_DIR_TS), end
if ~exist(INI.FIGURES_DIR_BP,'file'),   mkdir(INI.FIGURES_DIR_BP), end
if ~exist(INI.FIGURES_DIR_EXC,'file'),  mkdir(INI.FIGURES_DIR_EXC), end
if ~exist(INI.FIGURES_DIR_MAPS,'file'), mkdir(INI.FIGURES_DIR_MAPS), end
% Set up LaTeX directory and supporting files
if ~exist(INI.LATEX_DIR,'file'),mkdir(INI.LATEX_DIR);end;
if ~exist(INI.ANALYSIS_DIR_TAG, 'dir'), mkdir(char(INI.ANALYSIS_DIR_TAG)),end;

fprintf('DIRECTORIES FOR STORING ANALYSIS:?\n');
fprintf('==========================\n');
fprintf('INI.SCRIPTDIR is %s\n',INI.SCRIPTDIR);
fprintf('INI.LATEX_DIR is %s\n',INI.LATEX_DIR);
fprintf('INI.ANALYSIS_DIR is %s\n',INI.ANALYSIS_DIR);
fprintf('INI.MATDIR is %s\n',INI.MATDIR);
fprintf('==========================\n');

% initialize simulation variables
INI.NSIMULATIONS = length(INI.MODEL_SIMULATION_SET);
MODEL_FULLPATH = [];
MODEL_ALL_RUNS = [];
MODEL_RUN_DESC = [];

% define simulation variables
for i = 1:INI.NSIMULATIONS
    MODEL_FULLPATH{i} = INI.MODEL_SIMULATION_SET{i}{1};
    MODEL_ALL_RUNS{i} = INI.MODEL_SIMULATION_SET{i}{2};
    MODEL_RUN_DESC{i} = INI.MODEL_SIMULATION_SET{i}{3};
end

INI.MODEL_ALL_RUNS = MODEL_ALL_RUNS;
INI.MODEL_RUN_DESC = MODEL_RUN_DESC;
INI.MODEL_FULLPATH = MODEL_FULLPATH;

INI.PostProcStartDay_int = double(int32(floor(datenum(INI.ANALYZE_DATE_I))));
INI.PostProcEndDay_int   = double(int32(floor(datenum(INI.ANALYZE_DATE_F))));
INI.NumPostProcDays = (INI.PostProcEndDay_int-INI.PostProcStartDay_int)+1;
INI.PostProcTime_vector   = datevec(linspace(INI.PostProcStartDay_int,INI.PostProcEndDay_int,INI.NumPostProcDays));

end