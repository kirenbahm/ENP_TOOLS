function [INI] = get_INI(INI)

% setup_ini(INI) SETS UP additionall options which rarely change but if
% user decides to modify some of the options here, there sill be impact on
% the analysis in subsequent files

% get_INI(INI) calculates the remaining input variables
% the user should not modify anything in get_INI(INI)

fprintf('... ANALYZING SIMULATIONS:\n');
for i = 1:length(INI.MODEL_SIMULATION_SET)
    A = INI.MODEL_SIMULATION_SET{1,i}{1,1};
    B = INI.MODEL_SIMULATION_SET{1,i}{1,2};
    C = INI.MODEL_SIMULATION_SET{1,i}{1,3};
    INI.MODEL_SIMULATION_SET{1,i}{1,1} = [A B '.she - Result Files'];
    fprintf('SIMULATION: %s LEGEND: %s\n', B, C);
end

INI.PATHDIR = INI.MATLAB_SCRIPTS;
INI.MATDIR =  [INI.MATLAB_SCRIPTS 'LIB/'];
INI.SCRIPTDIR   = [INI.MATLAB_SCRIPTS 'DATA_LATEX/'];
%INI.DATADIR = [INI.MATLAB_SCRIPTS 'DATA_OBSERVATIONS/'];
INI.DATADIR = ['../EXAMPLE_DATA/'];

% read monitoring points either from excel or matlab
[D,N,X] = fileparts(INI.STATION_DATA);
MATFILE = [INI.DATADIR N '.MATLAB'];

% if there there is an existing MATLAB file read read XL file
% if the user specifies this file to be regenerated read XL file
% else load the MATLAB for faster
if INI.OVERWRITE_MON_PTS | ~exist(MATFILE,'file')
    % read monitoring points from excel file, slower process
    INI.MAPXLS = readXLSmonpts(0,INI,INI.STATION_DATA,0);
    %save the file in a structure for reading
    fprintf('\n--- Saving Monitoring Points data in file: %s\n', char(MATFILE))
    MAPXLS = INI.MAPXLS
    save(MATFILE,'MAPXLS','-v7.3');
else
    % load Monitoring point data from MATLAB for faster processing
    load(MATFILE, '-mat');
    INI.MAPXLS = MAPXLS;
end

% Directory to store all analyses
INI.ANALYSIS_DIR = INI.ANALYSIS_PATH;
fprintf('Current directory, all analysis will be stored in: %s\n\n',INI.ANALYSIS_DIR);
INI.ANALYSIS_DIR_TAG = [INI.ANALYSIS_DIR INI.ANALYSIS_TAG];  % postproc directory for postproc run (no edits needed here)
INI.DATA_DIR         = [INI.ANALYSIS_DIR_TAG '/data'];  % data dir in output for extracted matlab files
INI.FIGURES_DIR      = [INI.ANALYSIS_DIR_TAG '/figures'];  % figures dir in output
INI.FIGURES_DIR_TS   = [INI.ANALYSIS_DIR_TAG '/figures/timeseries'];
INI.FIGURES_DIR_EXC  = [INI.ANALYSIS_DIR_TAG '/figures/exceedance'];
INI.FIGURES_DIR_MAPS = [INI.ANALYSIS_DIR_TAG '/figures/maps'];
INI.FIGURES_RELATIVE_DIR = ['../figures']; % the relative path name to figs dir for includegraphics
INI.LATEX_DIR        = [INI.ANALYSIS_DIR_TAG '/latex'];
%INI.fileXL = [INI.ANALYSIS_DIR_TAG '/' INI.fileXL];

% The computed and observed timeseries data for the observation locations -
INI.FILESAVE_TS = [INI.ANALYSIS_DIR '/' INI.ANALYSIS_TAG  '/' INI.ANALYSIS_TAG '_TIMESERIES_DATA.MATLAB'];
% The computed and observed statistics data
INI.FILESAVE_STAT = [INI.ANALYSIS_DIR '/' INI.ANALYSIS_TAG  '/' INI.ANALYSIS_TAG   '_TIMESERIES_STAT.MATLAB'];

%---------------------------------------------------------------
% SET UP DIRECTORIES AND SUPPORTING FILES
%---------------------------------------------------------------
if ~exist(INI.ANALYSIS_DIR,'file'),     mkdir(INI.ANALYSIS_DIR), end  % Create analysis directory if it doesn't exist already
if ~exist(INI.ANALYSIS_DIR_TAG,'file'), mkdir(INI.ANALYSIS_DIR_TAG), end  % create postproc directory for postproc run (no edits needed here)
if ~exist(INI.DATA_DIR,'file'),         mkdir(INI.DATA_DIR), end %Create a data dir in output for extracted matlab files
if ~exist(INI.FIGURES_DIR,'file'),      mkdir(INI.FIGURES_DIR), end  %Create a figures dir in output
if ~exist(INI.FIGURES_DIR_TS,'file'),   mkdir(INI.FIGURES_DIR_TS), end
if ~exist(INI.FIGURES_DIR_EXC,'file'),  mkdir(INI.FIGURES_DIR_EXC), end
if ~exist(INI.FIGURES_DIR_MAPS,'file'), mkdir(INI.FIGURES_DIR_MAPS), end
% Set up LaTeX directory and supporting files
if ~exist(INI.LATEX_DIR,'file'),        mkdir(INI.LATEX_DIR);end;

fprintf('DIRECTORIES FOR STORING ANALYSIS:?\n');
fprintf('==========================\n');
fprintf('INI.SCRIPTDIR is %s\n',INI.SCRIPTDIR);
fprintf('INI.LATEX_DIR is %s\n',INI.LATEX_DIR);
fprintf('INI.ANALYSIS_DIR is %s\n',INI.ANALYSIS_DIR);
fprintf('INI.MATDIR is %s\n',INI.MATDIR);
fprintf('==========================\n');
copyfile([INI.SCRIPTDIR 'head.sty'],INI.LATEX_DIR );
copyfile([INI.SCRIPTDIR 'tail.sty'], INI.LATEX_DIR );
% copyfile([INI.SCRIPTDIR 'blank.jpg'],INI.FIGURES_DIR );
% copyfile([INI.SCRIPTDIR 'blank.bb'], INI.FIGURES_DIR );
% copyfile([INI.SCRIPTDIR 'blank.png'],INI.FIGURES_DIR );
% copyfile([INI.SCRIPTDIR 'figs-station_groups/APrimaryStationGroup.png'],INI.FIGURES_DIR_MAPS );
% copyfile([INI.SCRIPTDIR 'figs-station_groups/BSecondaryStationGroup.png'],INI.FIGURES_DIR_MAPS );
% copyfile([INI.SCRIPTDIR 'figs-station_groups/CBoundaryStationGroup.png'],INI.FIGURES_DIR_MAPS );
% copyfile([INI.SCRIPTDIR 'figs-station_groups/DCanalNetworkStationGroup.png'],INI.FIGURES_DIR_MAPS );

% INI.SELECTED_STATION_LIST = [INI.ANALYSIS_DIR '/' INI.SELECTED_STATION_LIST];
% INI.FILE_OBSERVED = [INI.ANALYSIS_DIR '/' INI.FILE_OBSERVED]; %  all selected stations
% INI.STATION_DATA  = [INI.STATION_DATA INI.STATION_DATA];

INI.NSIMULATIONS = length(INI.MODEL_SIMULATION_SET);
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