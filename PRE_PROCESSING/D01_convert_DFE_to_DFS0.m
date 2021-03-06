function D01_convert_DFE_to_DFS0()
%
% This script converts ascii files from the measurements table in DataForEver
% database (DFE format) output format to the DHI MIKE data format (DFS format)
%
% The script expects files to be timeseries data with only one
% station-datatype pair in each file.
%
% The dfs0 datatype 'flow'  will be assigned to all files in the OBS_FLOW_DFE_DIR  directory.
% The dfs0 datatype 'stage' will be assigned to all files in the OBS_STAGE_DFE_DIR directory.
%
% The script also expects an ascii file of station metadata from the DFE
% stations table, and will add appropriate station metadata to each
% timeseries file
%
% Inputs:
%   Ascii file with station metadata output directoy from DFE station table
%   Ascii files with stage or flow timeseries data output directly from DFE measurement table
%      (each file is a separate station-datatype pair)
%
% Outputs:
%   DFS0 format files (one for each station-datatype pair, with station metadata)
%
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% BEGIN USER INPUT
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% Location of input station metadata file (this is the DFE station table)
DFE_STATION_DATA_FILE = '../../ENP_FILES/ENP_TOOLS_Sample_Input/Data_Common/dfe_station_table_20200715.txt';

% -------------------------------------------------------------------------
% Location of input QC'd DFE measurement files (flow and stage in separate folders, one station per file)
% -------------------------------------------------------------------------
INI.OBS_FLOW_DFE_DIR  = '../../ENP_TOOLS_Output/Obs_Data_Final/Flow/';
INI.OBS_STAGE_DFE_DIR = '../../ENP_TOOLS_Output/Obs_Data_Final/Stage/';

% Suffix of QC'd DFE measurement files (used to generate a list of files to process)
INI.OBS_DFE_FILETYPE = '*.dat';

% -------------------------------------------------------------------------
% Location of dfs0 output files (each datatype needs a separate folder)
% -------------------------------------------------------------------------

INI.DIR_FLOW_DFS0     = '../../ENP_TOOLS_Output/Obs_Data_Final_DFS0/Flow/DFS0/';
INI.DIR_STAGE_DFS0    = '../../ENP_TOOLS_Output/Obs_Data_Final_DFS0/Stage/DFS0/';

% -------------------------------------------------------------------------
% Location of ENPMS library
% -------------------------------------------------------------------------
INI.MATLAB_SCRIPTS = '../ENPMS/';

% -------------------------------------------------------------------------
% Other options (0 = NO, 1 = YES)
% -------------------------------------------------------------------------
INI.DEBUG = 0;                 % Print extra debugging output?
INI.DELETE_EXISTING_DFS0 = 1;  % Delete existing DFS0 files? Has this option been checked?


% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% END USER INPUT
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
if ~exist(INI.DIR_FLOW_DFS0, 'dir')
   mkdir(INI.DIR_FLOW_DFS0)
end
if ~exist(INI.DIR_STAGE_DFS0, 'dir')
   mkdir(INI.DIR_STAGE_DFS0)
end

% currently inactive options (not tested):
%INI.SAVE_IN_MATLAB = 1;  % Save in MATLAB format? 

try
    addpath(genpath(INI.MATLAB_SCRIPTS));
catch
    addpath(genpath(INI.MATLAB_SCRIPTS,0));
end

%Initialize .NET libraries
INI = initializeLIB(INI);

MAP_STATIONS = S00_load_DFE_STNLOC(DFE_STATION_DATA_FILE);

% iterate over input file datatype directories with DFE *.dat files:
for DType_Flag = {'Water Level','Discharge'} % Water Level must be in feet, Discharge must be in cfs (hardcoded in D05_publish_DFS0.m)
    if strcmpi(DType_Flag,'Discharge')
        FILE_FILTER = [INI.OBS_FLOW_DFE_DIR INI.OBS_DFE_FILETYPE];                            % list only files with extension *.dat
        LISTING  = dir(char(FILE_FILTER));
        INI.DIR_DFS0_FILES = INI.DIR_FLOW_DFS0;
        fprintf('\n');
        fprintf('Input files being read from: %s\n', INI.OBS_FLOW_DFE_DIR);
        fprintf('Output files written to: %s\n',     INI.DIR_DFS0_FILES);
    elseif strcmpi(DType_Flag,'Water Level')
        FILE_FILTER = [INI.OBS_STAGE_DFE_DIR INI.OBS_DFE_FILETYPE];                           % list only files with extension *.dat
        LISTING  = dir(char(FILE_FILTER));
        INI.DIR_DFS0_FILES = INI.DIR_STAGE_DFS0;
        fprintf('\n');
        fprintf('Input files being read from: %s\n', INI.OBS_STAGE_DFE_DIR);
        fprintf('Output files written to: %s\n',     INI.DIR_DFS0_FILES);
    end
    preproc_process_file_list(INI,MAP_STATIONS,LISTING,DType_Flag);                   % submit output DFS0 directory, input file list, and data type flag for processing
end

fclose('all');
fprintf('\n DONE \n\n');

end
