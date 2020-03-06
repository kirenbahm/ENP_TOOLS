function  ANALYSIS_COMPARE
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

%---------------------------------------------------------------------
%---------------------------------------------------------------------
%  README for this function
%---------------------------------------------------------------------
%---------------------------------------------------------------------

%  Master script for initializing postprocessing variables and calling other
%  postproc, graphing, and statistics calculation scripts.
%  This function reads computed data from simulations as a MATLAB file, 
%  and also reads observed data from MATLAB file
%
% The user will need to setup these items in the script below:
% 1. Location of ENPMS scripts e.g. 'some path\ENP_TOOLS\ENPMS\'
% 2. Location of common data (spreadsheet with chainages ij-coordinates for
%     each model e.g. 'some path/DATA_COMMON/'
% 3. A tag for analysis reference (creates also a directory to store all)
% 4. Location to read inputfiles containing computed Matlab data,
%     and parent directory for postproc output
% 5. Simulations to be analyzed (must be present in INI.DATA_COMPUTED
% 6. Time period for analysis BEGIN(I) AND END(F) DATES FOR POSTPROC
% 7. A list of stations to be analyzed
% 8. Modules for POSTPROC
% 9. Additional settings 

%---------------------------------------------------------------------
%---------------------------------------------------------------------
%  BEGIN USER DEFINITIONS (Items 1-9)
%---------------------------------------------------------------------
%---------------------------------------------------------------------

%---------------------------------------------------------------------
% 1. SETUP Location of ENPMS Scripts
%---------------------------------------------------------------------
INI.MATLAB_SCRIPTS = '..\ENPMS\';
% Initialize path of ENPMS Scripts 
try
    addpath(genpath(INI.MATLAB_SCRIPTS));
catch
    addpath(genpath(INI.MATLAB_SCRIPTS,0));
end

%---------------------------------------------------------------------
% 2. Set Location of Common Data and observed matlab data inputfiles
%---------------------------------------------------------------------
INI.DATA_COMMON = '..\..\ENP_FILES\ENP_TOOLS_Sample_Input\Data_Common/'; 

INI.FILE_OBSERVED = [INI.DATA_COMMON '/SAMPLE_OBS_DATA_20200305.MATLAB'];

%---------------------------------------------------------------------
% 3. Set a tag for this analysis
%     (This tag will be used to name the output directory, combined 
%      output datasets, and other filenames)
%---------------------------------------------------------------------
INI.ANALYSIS_TAG = 'M01-M06_test';
%INI.ANALYSIS_TAG = 'M01-M06_test_short';

%---------------------------------------------------------------------
% 4. Set location to read inputfiles containing computed Matlab data,
%    and parent directory to store postproc output
%---------------------------------------------------------------------
% use this for unit testing
INI.DATA_COMPUTED = '..\..\ENP_FILES\ENP_TOOLS_Sample_Input\Model_Output_Processed\';
INI.POST_PROC_DIR = ['..\..\ENP_TOOLS_Output\ANALYSIS_COMPARE_output\' INI.ANALYSIS_TAG '/'];

% use this for sequential testing
%INI.DATA_COMPUTED = '..\..\ENP_TOOLS_Output_Sequential\Model_Output_Processed\';
%INI.POST_PROC_DIR = ['..\..\ENP_TOOLS_Output_Sequential\' INI.ANALYSIS_TAG '/'];

%---------------------------------------------------------------------
% 5. Choose simulations to be analyzed (must be present in INI.DATA_COMPUTED
%---------------------------------------------------------------------
i = i + 1;  INI.MODEL_SIMULATION_SET{i} = {INI.DATA_COMPUTED, 'M01_test', 'M01'};
i = i + 1;  INI.MODEL_SIMULATION_SET{i} = {INI.DATA_COMPUTED, 'M06_test', 'M06'};
%i = i + 1;  INI.MODEL_SIMULATION_SET{i} = {INI.DATA_COMPUTED, 'M01_test_short', 'M01'};
%i = i + 1;  INI.MODEL_SIMULATION_SET{i} = {INI.DATA_COMPUTED, 'M06_test_short', 'M06'};

%---------------------------------------------------------------------
% 6. Select time period for analysis BEGIN(I) AND END(F) DATES FOR POSTPROC
%---------------------------------------------------------------------

INI.ANALYZE_DATE_I = [1999 1 1 0 0 0];  % begining of analysis period
INI.ANALYZE_DATE_F = [2010 12 31 0 0 0];% ending of analysis period

%---------------------------------------------------------------------
% 7. Select a list of stations to be analyzed
%---------------------------------------------------------------------

INI.SELECTED_STATION_FILE = [INI.DATA_COMMON '/TEST-STATIONS-short.txt']; 

%---------------------------------------------------------------------
% 8. Select modules to run  (1=yes, 0=no)
%---------------------------------------------------------------------

INI.A1    = 1; % A1_load_computed_timeseries - this needs checking if all simulation set exsist
INI.A2    = 1; % A2_generate_timeseries_stat - this needs checking if all simulation set exsist
INI.A2a   = 1; % A2a_cumulative_flows - this needs checking if all simulation set exsist
INI.A3    = 1; % A3_create_figures_timeseries
INI.A3c   = 1; % A3_create_figures_cumulative_timeseries
INI.A3B   = 1; % A3B_BoxPlot
INI.A4    = 1; % A4_create_figures_exceedance
INI.A5    = 1; % A5_create_summary_stat
%INI.A6    = 0; % A6_GW_MAP_COMPARE
%INI.A7    = 0; % A7_SEEPAGE_MAP
%INI.A8    = 0; % A8_SEEPAGE_EXCEL % not implemented yet
INI.A9    = 1; % A9_make_latex_report % 

%---------------------------------------------------------------------
% 9 Additional settings, DEFAULT can be modified for additional functionality 
% (1=yes, 0=no)
%---------------------------------------------------------------------
INI.USE_NEW_CODE          = 1; % use NEW method for analysis? (developed for M06) always 1
INI.SAVEFIGS              = 0; % save figures in MATLAB format? 
INI.INCLUDE_OBSERVED      = 1; % Include observed in the output figs and tables.
INI.INCLUDE_COMPUTED      = 1; % Include computed in the output figs and tables.
INI.LATEX_REPORT_BY_AREA  = 1; % The latex report lists stations by area 
INI.DEBUG                 = 1; % Set this to 1 to generate extra output for debugging

%---------------------------------------------------------------------
%---------------------------------------------------------------------
%  END USER DEFINITIONS
%---------------------------------------------------------------------
%---------------------------------------------------------------------
% Run selected modules
%---------------------------------------------------------------
try
    INI = fileAssertions(INI);
    INI = analyze_data_set(INI);
catch INI
    fprintf('\nException in readMSHE_WM(INI), i=%d\n', i);
    msgException = getReport(INI,'extended','hyperlinks','on');
end

fprintf('\n %s Successful completion of all for %.3g seconds\n',datestr(now), toc);

fprintf('\n\n *** ANALYSIS_COMPARE completed ***\n\n');
end


function INI = fileAssertions(INI);
% Move all file assertions here

assert(exist(INI.MATLAB_SCRIPTS,'file') == 7, 'Directory not found.' );

assert(exist(INI.DATA_COMMON,'file') == 7, 'Directory not found.' );

assert(exist(INI.FILE_OBSERVED,'file') == 2, 'File not found.' );

assert(exist(INI.DATA_COMPUTED,'file') == 7, 'Directory not found.' );

assert(exist(INI.SELECTED_STATION_FILE,'file') == 2, 'File not found.' );

end