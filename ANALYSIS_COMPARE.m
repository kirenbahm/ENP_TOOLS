function  main
%---------------------------------------------
%%% DO NOT MODIFY (begin)

tic; % initialize time counter to clock script begin to end
[INI.ROOT,NAME,EXT] = fileparts(pwd()); % path string of ROOT Directory/
INI.ROOT = [INI.ROOT '/'];
INI.CURRENT_PATH =[char(pwd()) '/']; % path string of folder MAIN
INI.A1 = 0; INI.A2 = 0; INI.A2a = 0; INI.A3 = 0; INI.A3a = 0; INI.A3c = 0;
INI.A3exp = 0; INI.A4 = 0; INI.A5 = 0; INI.A6 = 0; INI.A7 = 0;INI.A8 = 0;
i = 0; % initialize simulation count

%%% DO NOT MODIFY (end)
%---------------------------------------------
%{
FUNCTION DESCRIPTION:

Master script for initializing postprocessing variables and calling other
postproc, graphing, and statistics calculation scripts.
Originally from Georgio Tachiev and modified by RJF and KEB at NPS.
Credit also goes to the student that helped organize this for GIT - Tushar Gadkari,
Other credits go to Marcelo Lago, Amy Cook, and Jordan Barr.

%}
%---------------------------------------------------------------------
% SET UP PROFILE WITH LOCATION OF DIRECTORIES AND SCRIPTS
%---------------------------------------------------------------------
% ** NOTE: You will need to hardcode your profile in the setup_profile.m
%          script for this to work correctly

PROFILE_NAME = 'test'; % test kiren inpeverhydrokc

INI = setup_profile(INI,PROFILE_NAME);

%------------------------------------------------------------------------
% CHOOSE THE TAG/NAME FOR YOUR ANALYSIS
%------------------------------------------------------------------------
% This tag will be given to the combined output datasets,
% directory structure, and filenames

INI.ANALYSIS_TAG = 'ENP_TOOLS_Sample_Output';

%---------------------------------------------------------------------
% CHOOSE SIMULATIONS TO BE ANALYZED
%---------------------------------------------------------------------
% This should be modified to allow
% results from different directories or computers to be used without
% copying the data, i.e. INI.ResultDirHome can vary

i = i + 1;  INI.MODEL_SIMULATION_SET{i} = {INI.ResultDirHome, 'M01_test', 'M3ENP'};
i = i + 1;  INI.MODEL_SIMULATION_SET{i} = {INI.ResultDirHome, 'M06_test', 'M3ENP-SF'};

%---------------------------------------------------------------------
% CHOOSE TIME PERIOD THAT PLOTS AND STATISTICS WILL BE GENERATED FOR
%---------------------------------------------------------------------
% BEGIN(I) AND END(F) DATES FOR POSTPROC

INI.ANALYZE_DATE_I = [1999 1 1 0 0 0]; 
INI.ANALYZE_DATE_F = [2010 12 31 0 0 0];

%---------------------------------------------------------------------
% CHOOSE WHICH MODULES TO RUN  1=yes, 0=no
%---------------------------------------------------------------------

INI.A1    = 1; % A1_load_computed_timeseries
INI.A2    = 1; % A2_generate_timeseries_stat
INI.A2a   = 1; % A2a_cumulative_flows
INI.A3    = 1; % A3_create_figures_timeseries
INI.A3c   = 1; % A3_create_figures_cumulative_timeseries
%INI.A3a   = 0; % A3a_boxmat
%INI.A3exp = 0; % A3a_boxmatEXP
INI.A4    = 1; % A4_create_figures_exceedance
INI.A5    = 1; % A5_create_summary_stat
%INI.A6    = 0; % A6_GW_MAP_COMPARE
%INI.A7    = 0; % A7_SEEPAGE_MAP
%INI.A8    = 0; % A7_SEEPAGE_EXCEL % not implemented yet

%---------------------------------------------------------------------
% CHOOSE OPTIONS 1=yes, 0=no
%---------------------------------------------------------------------

INI.USE_NEW_CODE          = 1; % use NEW method for analysis? (developed for M06)
INI.SAVEFIGS              = 0; % save figures in MATLAB format? 
INI.INCLUDE_OBSERVED      = 1; % Include observed in the output figs and tables. Check if this switch works
INI.MAKE_STATISTICS_TABLE = 0;  % Make the statistics tables in LaTeX
INI.MAKE_EXCEEDANCE_PLOTS = 1; % Generate exceedance curve plots? Also generates the exceedance table.
%INI.COMPUTE_SENSITIVITES  = 'YES'; % not used? % Compute statistics and generate tables in Latex? Check if this switch works
%---------------------------------------------------------------------
% FILE LOCATIONS
%---------------------------------------------------------------------

% DATA_COMMON is data which is common for all simulations, it includes the
% main xlsx sheet, all stationd data, and observed data for the domain
INI.DATA_COMMON = '../ENP_TOOLS_Sample_Input/Data_Common/'; % the default for testing ANALYSIS_TEMPLATE

% DATA_COMPUTED is the data which is provided here for testing the
% simulations, it includes also a directory 'Results' which contains dfs
% files for testing compiling model data
INI.DATA_COMPUTED = '../ENP_TOOLS_Sample_Input/Model_Output_Processed/'; % the default for testing ANALYSIS_TEMPLATE

% DATA_POSTPROC is post proc data
INI.POST_PROC_DIR = ['../']; % the default for testing ANALYSIS_TEMPLATE

%---------------------------------------------------------------------
% CHOOSE STATIONS TO BE ANALYZED
%---------------------------------------------------------------------

U.SELECTED_STATION_LIST = [INI.DATA_COMMON '/TEST-STATIONS-short.txt']; 

% Location of observed data timeseries (in matlab dataset form)
if INI.USE_NEW_CODE
   % U.FILE_OBSERVED = './EXAMPLE_DATA/M01_OBSERVED_DATA_test.MATLAB'; % Obs data in NEW format
   U.FILE_OBSERVED = [INI.DATA_COMMON '/M06_OBSERVED_DATA_test.MATLAB'];  % Obs data in NEW format
else
   U.FILE_OBSERVED = [INI.DATA_COMMON '/M06_OBSERVED_DATA_test.MATLAB'];  % Obs data in OLD format
end

% Location of observed data metadata
U.STATION_DATA = [INI.DATA_COMMON 'monpts_20160401.xlsx']; 

% List of station names that have no Obs data, so we can suppress 
% 'missing obs data' messages for stations we already know don't have 
% observed data (ie transects, canal junctions where we output wbud info)
U.NO_OBS_STATION_LIST = [INI.DATA_COMMON 'monpts_with_no_obs_data.txt'];

% map of requested seepage, note the scripts are MAPF specfic because they
% accumulate X and Y seepage values in specific way
U.MAPF = [INI.DATA_COMMON 'SEEPAGE_MAP.dfs2'];;


%---------------------------------------------------------------------
%---------------------------------------------------------------------
%  END USER DEFINITIONS
%---------------------------------------------------------------------
%---------------------------------------------------------------------

% add all paths within the root repository
% recursively add local libraries and directories
try
   addpath(genpath(INI.MATLAB_SCRIPTS));
catch
   addpath(genpath(INI.MATLAB_SCRIPTS,0));
end

%---------------------------------------------------------------------
%  INITIALILIZE STRUCTURE INI
%---------------------------------------------------------------------
INI = setup_ini(INI,U);

%---------------------------------------------------------------------
% GET OBS DATA AND MONPTS
%---------------------------------------------------------------------
% read monitoring points either from excel or matlab
[D,N,X] = fileparts(INI.STATION_DATA);
MATFILE = [INI.DATADIR N '.MATLAB'];

% if there there is an existing MATLAB file read read XL file
% if the user specifies this file to be regenerated read XL file
% else load the MATLAB for faster
% if INI.OVERWRITE_MON_PTS | ~exist(MATFILE,'file')
     % read monitoring points from excel file, slower process
     INI.MAPXLS = readXLSmonpts(0,INI,INI.STATION_DATA,0);
%     %save the file in a structure for reading
     fprintf('\n--- Saving Monitoring Points data in file: %s\n', char(MATFILE))
     MAPXLS = INI.MAPXLS
     save(MATFILE,'MAPXLS','-v7.3');
% else
    % load Monitoring point data from MATLAB for faster processing
%    load(MATFILE, '-mat');
%    INI.MAPXLS = MAPXLS;
% end


INI.SELECTED_STATIONS = get_station_list(INI.SELECTED_STATION_LIST);

INI.NO_OBS_STATIONS = get_station_list(INI.NO_OBS_STATION_LIST);

%---------------------------------------------------------------
% SET UP DIRECTORIES AND SUPPORTING FILES
%---------------------------------------------------------------
if ~exist(INI.ANALYSIS_DIR,'file'),     mkdir(INI.ANALYSIS_DIR), end  % Create analysis directory if it doesn't exist already
if ~exist(INI.ANALYSIS_DIR_TAG,'file'), mkdir(INI.ANALYSIS_DIR_TAG), end  % create postproc directory for postproc run (no edits needed here)
if ~exist(INI.DATA_DIR,'file'),         mkdir(INI.DATA_DIR), end %Create a data dir in output for extracted matlab files
if ~exist(INI.LATEX_DIR,'file'),        mkdir(INI.LATEX_DIR), end
if ~exist(INI.FIGURES_DIR,'file'),      mkdir(INI.FIGURES_DIR), end  %Create a figures dir in output
if ~exist(INI.FIGURES_DIR_TS,'file'),   mkdir(INI.FIGURES_DIR_TS), end
if ~exist(INI.FIGURES_DIR_EXC,'file'),  mkdir(INI.FIGURES_DIR_EXC), end
if ~exist(INI.FIGURES_DIR_MAPS,'file'), mkdir(INI.FIGURES_DIR_MAPS), end

copyfile([INI.SCRIPTDIR 'head.sty'],INI.LATEX_DIR );
copyfile([INI.SCRIPTDIR 'tail.sty'], INI.LATEX_DIR );

%---------------------------------------------------------------
% Run the modules
%---------------------------------------------------------------
INI = analyze_data_set(INI);

fprintf('\n %s Successful completion of all for %.3g seconds\n',datestr(now), toc);

end
