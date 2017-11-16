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

BUGS:
COMMENTS:
REVISION HISTORY:
%}

%---------------------------------------------------------------------
%---------------------------------------------------------------------
%  BEGIN USER DEFINITIONS
%---------------------------------------------------------------------
%---------------------------------------------------------------------

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

INI.ANALYSIS_TAG = 'test_results';

%---------------------------------------------------------------------
% CHOOSE SIMULATIONS TO BE ANALYZED
%---------------------------------------------------------------------
% This should be modified to allow
% results from different directories or computers to be used without
% copying the data, i.e. INI.ResultDirHome can vary

i = i + 1;  INI.MODEL_SIMULATION_SET{i} = {INI.ResultDirHome, 'M01_test', 'Model A'};
i = i + 1;  INI.MODEL_SIMULATION_SET{i} = {INI.ResultDirHome, 'M06_test', 'Model B'};

%---------------------------------------------------------------------
% CHOOSE TIME PERIOD THAT PLOTS AND STATISTICS WILL BE GENERATED FOR
%---------------------------------------------------------------------
% BEGIN(I) AND END(F) DATES FOR POSTPROC

INI.ANALYZE_DATE_I = [1999 1 1 0 0 0]; 
INI.ANALYZE_DATE_F = [2010 12 31 0 0 0];

%---------------------------------------------------------------------
% CHOOSE STATIONS TO BE ANALYZED
%---------------------------------------------------------------------

U.SELECTED_STATION_LIST = './EXAMPLE_DATA/TEST-STATIONS.txt';

%---------------------------------------------------------------------
% CHOOSE WHICH MODULES TO RUN  1=yes, 0=no
%---------------------------------------------------------------------

INI.A1    = 1; % A1_load_computed_timeseries
INI.A2    = 1; % A2_generate_timeseries_stat
INI.A2a   = 1; % A2a_cumulative_flows
INI.A3    = 1; % A3_create_figures_timeseries
INI.A3c   = 1; % A3_create_figures_cumulative_timeseries
% INI.A3a   = 0; % A3a_boxmat
% INI.A3exp = 0; % A3a_boxmatEXP
INI.A4    = 1; % A4_create_figures_exceedance
INI.A5    = 1; % A5_create_summary_stat
% INI.A6    = 1; % A6_GW_MAP_COMPARE
% INI.A7    = 1; % A7_SEEPAGE_MAP
% INI.A8    = 1; % A7_SEEPAGE_EXCEL % not implemented yet

%---------------------------------------------------------------------
% CHOOSE OPTIONS 1=yes, 0=no
%---------------------------------------------------------------------

INI.ANALYSIS_EXTRACTED    = 1; % use Alternative Analysis option with extracted data?
INI.SAVEFIGS              = 0; % save figures in MATLAB format? 
INI.INCLUDE_OBSERVED      = 1; % Include observed in the output figs and tables. Check if this switch works
INI.MAKE_STATISTICS_TABLE = 1;  % Make the statistics tables in LaTeX
INI.MAKE_EXCEEDANCE_PLOTS = 1; % Generate exceedance curve plots? Also generates the exceedance table.
%INI.COMPUTE_SENSITIVITES  = 'YES'; % not used? % Compute statistics and generate tables in Latex? Check if this switch works
%---------------------------------------------------------------------
% FILE LOCATIONS
%---------------------------------------------------------------------

% Location of observed data timeseries (in matlab dataset form)
if ~INI.ANALYSIS_EXTRACTED
    U.FILE_OBSERVED = 'DATA_OBS_20150604.MATLAB';
else
   % U.FILE_OBSERVED = './EXAMPLE_DATA/M01_OBSERVED_DATA_test.MATLAB';
   U.FILE_OBSERVED = './EXAMPLE_DATA/M06_OBSERVED_DATA_test.MATLAB';
end

% Location of observed data metadata
U.STATION_DATA = './EXAMPLE_DATA/monpts_20160401.xlsx';

% List of station names that have no Obs data, so we can suppress 
% 'missing obs data' messages for stations we already know don't have 
% observed data (ie transects, canal junctions where we output wbud info)
U.NO_OBS_STATION_LIST = './EXAMPLE_DATA/monpts_with_no_obs_data.txt';

% map of requested seepage, note the scripts are MAPF specfic because they
% accumulate X and Y seepage values in specific way
U.MAPF = 'SEEPAGE_MAP.dfs2';


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

%THIS IS NOT NEEDED
INI.ANALYSIS_PATH = INI.CURRENT_PATH;


% These are the parent directories where the input dfs0 timeseries files are
% stored. This is used by readxlsmonpts to create the obs data matlab file
% for postproc
INI.dfs0MSHEdir = ['C:\home\MODELS\DHIMODEL\INPUTFILES\MSHE\TIMESERIES\'];
INI.dfs0MSHEdpthdir = ['C:\home\MODELS\DHIMODEL\INPUTFILES\MSHE\TSDEPTH\'];
INI.dfs0M11dir = ['C:\home\MODELS\DHIMODEL\INPUTFILES\M11\TIMESERIES\'];

% These are used to create txt files that can be imported into the model.
% This is in the last part of the readXLSmonpts script, but should probably
% be moved into its own function.
% Set to 1 to create these files, 0 to not create them
INI.MakeDetTSInputFiles = 0;
INI.printMSHEname = ['./detTSmsheALL.txt'];
INI.printM11name = ['./detTSm11ALL.txt'];

%---------------------------------------------------------------------
%  INITIALILIZE STRUCTURE INI
%---------------------------------------------------------------------
INI = setup_ini(INI,U);

%---------------------------------------------------------------
% Run the modules
%---------------------------------------------------------------
INI = analyze_data_set(INI);

fprintf('\n %s Successful completion of all for %.3g seconds\n',datestr(now), toc);

end
