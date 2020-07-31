function D00_qc_DFE_DATA()

%
% This script reads ascii files from the measurements table in DataForEver
% database (DFE format) and rewrites them in a new directory with QC flags
% added
% This script will also take data from dfs0 files and overwrite any
% modified data to the new DFE format files.
%
% The script expects files to be timeseries data with only one
% station-datatype pair in each file.
%
% Inputs:
%   Ascii files with stage or flow timeseries data output directly from DFE measurement table
%      (each file is a separate station-datatype pair)
%   Optionally:
%      DFS0 format files (one for each station-datatype pair, with station metadata, and 3 items: raw data, flag, and accepted data)
%
% Outputs:
%   Ascii files with stage or flow timeseries data with added qc flags
%   DFS0 format files (one for each station-datatype pair, with station metadata, and 3 items: raw data, flag, and accepted data)
%
% The first time you run this script, 
%   use INI.USE_DFS0_FLAGS = 0 to generate the dfs0 files
% For all subsequent times you run this script,
%   use INI.USE_DFS0_FLAGS = 1 to read (and overwrite) the dfs0 files
%
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% BEGIN USER INPUT
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% Location of input station metadata file (this is the DFE station table)
DFE_STATION_DATA_FILE = '../../ENP_FILES/ENP_TOOLS_Sample_Input/Data_Common/dfe_station_table_20200715.txt';

% -------------------------------------------------------------------------
% Location of input raw DFE measurement files (flow and stage in separate folders, one station per file)
% -------------------------------------------------------------------------
INI.OBS_FLOW_DFE_DIR  = '../../ENP_FILES/ENP_TOOLS_Sample_Input/Obs_Data_Raw/Flow/';
INI.OBS_STAGE_DFE_DIR = '../../ENP_FILES/ENP_TOOLS_Sample_Input/Obs_Data_Raw/Stage/';

% Suffix of raw DFE data files (used to generate a list of files to process)
INI.OBS_DFE_FILETYPE = '*.dat';

% -------------------------------------------------------------------------
% Location of dfs0 files for manual QC editing (each datatype needs a separate folder)
%
%  (When INI.USE_DFS0_FLAGS = 0, these files will be created)
%  (When INI.USE_DFS0_FLAGS = 1, these files will read and then overwritten)
% -------------------------------------------------------------------------
INI.DIR_FLOW_DFS0  = '../../ENP_TOOLS_Output/Obs_Data_QC/Flow/';
INI.DIR_STAGE_DFS0 = '../../ENP_TOOLS_Output/Obs_Data_QC/Stage/';

% -------------------------------------------------------------------------
% Location of ascii output files (each datatype needs a separate folder)
% -------------------------------------------------------------------------
INI.OBS_FLOW_FLAG_DIR  = '../../ENP_TOOLS_Output/Obs_Data_Final/Flow/';
INI.OBS_STAGE_FLAG_DIR = '../../ENP_TOOLS_Output/Obs_Data_Final/Stage/';

% -------------------------------------------------------------------------
% Settings used to determine which values will be flagged
% -------------------------------------------------------------------------
INI.STAGE_LOWER_LIMIT = -10;   % Lower limit for stage in feet
INI.STAGE_UPPER_LIMIT = 50;    % Upper Limit for stage in feet

INI.STAGE_PERIOD_WITH_CONSTANT_LIMIT = 7; %Period of time stage can remain constant, in days, before being flagged

INI.FLOW_LOWER_LIMIT = -10000; % Lower limit for flow in cubic feet per second
INI.FLOW_UPPER_LIMIT = 10000;  % Upper limit for flow in cubic feet per second

% -------------------------------------------------------------------------
% Other options (0 = NO, 1 = YES)
% -------------------------------------------------------------------------
% Use this BEFORE data is manually QC'd:
INI.USE_DFS0_FLAGS = 0;        % Find flags from existing flagged dfs0?

% Use this AFTER data is manually QC'd:
%INI.USE_DFS0_FLAGS = 1;        % Find flags from existing flagged dfs0?

INI.DEBUG = 0;                 % Print extra debugging output?
INI.DELETE_EXISTING_DFS0 = 1;  % Delete existing DFS0 files? Has this option been checked?

% -------------------------------------------------------------------------
% Location of ENPMS library
% -------------------------------------------------------------------------
INI.MATLAB_SCRIPTS = '../ENPMS/';

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% END USER INPUT
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

try
    addpath(genpath(INI.MATLAB_SCRIPTS));
catch
    addpath(genpath(INI.MATLAB_SCRIPTS,0));
end

%Initialize .NET libraries
INI = initializeLIB(INI);

% Make directories that don't already exist
% if ~exist(INI.OBS_FLOW_DFE_DIR, 'dir')
%    mkdir(INI.OBS_FLOW_DFE_DIR)
% end
% if ~exist(INI.OBS_STAGE_DFE_DIR, 'dir')
%    mkdir(INI.OBS_STAGE_DFE_DIR)
% end
if ~exist(INI.OBS_FLOW_FLAG_DIR, 'dir')
   mkdir(INI.OBS_FLOW_FLAG_DIR)
end
if ~exist(INI.OBS_STAGE_FLAG_DIR, 'dir')
   mkdir(INI.OBS_STAGE_FLAG_DIR)
end
if ~exist(INI.DIR_FLOW_DFS0, 'dir')
   mkdir(INI.DIR_FLOW_DFS0)
end
if ~exist(INI.DIR_STAGE_DFS0, 'dir')
   mkdir(INI.DIR_STAGE_DFS0)
end


% get station metadata
MAP_STATIONS = S00_load_DFE_STNLOC(DFE_STATION_DATA_FILE);

% process files
for DType_Flag = {'Water Level','Discharge'} % Water Level must be in feet, Discharge must be in cfs (hardcoded in D05_publish_DFS0.m)
%for DType_Flag = {'Discharge','Water Level'}

    if strcmpi(DType_Flag,'Discharge')
        FILE_FILTER = [INI.OBS_FLOW_DFE_DIR INI.OBS_DFE_FILETYPE];  % list only files with extension *.dat
        LISTING  = dir(char(FILE_FILTER));
        INI.DIR_DFS0_FILES = INI.DIR_FLOW_DFS0;
        fprintf('\n');
        fprintf('Input  .dat files are being read from: %s\n', INI.OBS_FLOW_DFE_DIR);
        fprintf('Output .dat files  will be written to: %s\n', INI.OBS_FLOW_FLAG_DIR);
        fprintf('Output .dfs0 files will be written to: %s\n', INI.DIR_DFS0_FILES);
        
    elseif strcmpi(DType_Flag,'Water Level')
        FILE_FILTER = [INI.OBS_STAGE_DFE_DIR INI.OBS_DFE_FILETYPE];  % list only files with extension *.dat
        LISTING  = dir(char(FILE_FILTER));
        INI.DIR_DFS0_FILES = INI.DIR_STAGE_DFS0;
        fprintf('\n');
        fprintf('Input  .dat files are being read from: %s\n', INI.OBS_STAGE_DFE_DIR);
        fprintf('Output  .dat files will be written to: %s\n', INI.OBS_STAGE_FLAG_DIR);
        fprintf('Output .dfs0 files will be written to: %s\n', INI.DIR_DFS0_FILES);
    end
    
    % submit output DFS0 directory, input file list, and data type flag for processing
    preprocess_data_validity(INI,MAP_STATIONS,LISTING,DType_Flag);
end

fclose('all');
fprintf('\n DONE \n\n');


end

