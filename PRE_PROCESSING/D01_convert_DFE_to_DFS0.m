function D01_convert_DFE_to_DFS0()
% This script converts data files from the DataForEver
% database (DFE format) output format to the DHI MIKE data format (DFS format)
% The script expects files to be timeseries data with only one
% station-datatype pair in each file. The files are additionally sorted in
% to unique directories based on datatype.

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% BEGIN USER INPUT
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% Location of raw DFE data files (each datatype needs to be in a separate folder)
INI.OBS_FLOW_DFE_DIR  = '../../ENP_TOOLS_Sample_Input/Raw_DFE_Data/Flow_test/';
INI.OBS_STAGE_DFE_DIR = '../../ENP_TOOLS_Sample_Input/Raw_DFE_Data/Stage_test/';


% Suffix of raw DFE data files (used to generate a list of files to process)
INI.OBS_DFE_FILETYPE = '*.dat';


% Location of dfs0 output files (each datatype needs a separate folder)
INI.DIR_FLOW_DFS0     = '../../ENP_TOOLS_Sample_Input/Obs_Data_Processed/D01_FLOW/DFS0/';
INI.DIR_STAGE_DFS0    = '../../ENP_TOOLS_Sample_Input/Obs_Data_Processed/D02_STAGE/DFS0/';

% Location of ENPMS library
INI.MATLAB_SCRIPTS = '../ENPMS/';

% Other options (0 = NO, 1 = YES)
INI.DEBUG = 0;                 % Print extra debugging output?
INI.DELETE_EXISTING_DFS0 = 1;  % Delete existing DFS0 files? Has this option been checked?


% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% END USER INPUT
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% currently inactive options (not tested):
%INI.SAVE_IN_MATLAB = 1;  % Save in MATLAB format? 

try
    addpath(genpath(INI.MATLAB_SCRIPTS));
catch
    addpath(genpath(INI.MATLAB_SCRIPTS,0));
end

MAP_STATIONS = S00_load_DFE_STNLOC();

% iterate over input file datatype directories with DFE *.dat files:
for DType_Flag = {'Water Level','Discharge'}
%for DType_Flag = {'Discharge','Water Elevation'}
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
    D02_process_file_list(INI,MAP_STATIONS,LISTING,DType_Flag);                   % submit output DFS0 directory, input file list, and data type flag for processing
end

fclose('all');
fprintf('\n DONE \n\n');

end
