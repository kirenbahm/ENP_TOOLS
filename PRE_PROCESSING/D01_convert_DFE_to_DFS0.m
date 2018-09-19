function D01_convert_DFE_to_DFS0()
% Script reads station data and generates a set of dfs0 files which use the
% original timeseries intervals. The script requires a directory which
% which is named DFS0, in this directory the *.out files reside. A dfs0
% file is created for each .out file. The .dfs0 file uses the original
% timestep. 

% -------------------------------------------------------------------------
% path string of ROOT Directory = DRIVE:/GIT/ENP_TOOLS MAIN Directory = PRE_PROCESSING
% -------------------------------------------------------------------------
[ROOT,MAIN,~] = fileparts(pwd());
TEMP = strsplit(ROOT,'\');

INI.ROOT = [TEMP{1} '/' TEMP{2} '/'];

% -------------------------------------------------------------------------
% Add path(s) to ENP_TOOLS and all other 1st level sub-directories
% -------------------------------------------------------------------------
INI.TOOLS_DIR = [INI.ROOT TEMP{3} '/'];
INI.SAMPLE_INPUT_DIR = [INI.ROOT 'ENP_TOOLS_Sample_Input/'];

clear TEMP ROOT MAIN
% -------------------------------------------------------------------------
% Add sub--directory path(s) for ENP_TOOLS directory
% -------------------------------------------------------------------------
INI.PRE_PROCESSING_DIR = [INI.TOOLS_DIR MAIN '/'];
    % Input directories:
INI.input = [INI.PRE_PROCESSING_DIR '_input/'];
    % DFS0 file creation from DFE input file directories
INI.STATION_DIR = [INI.PRE_PROCESSING_DIR 'D00_STATIONS/'];
INI.FLOW_DIR = [INI.PRE_PROCESSING_DIR 'D01_FLOW/'];
INI.STAGE_DIR = [INI.PRE_PROCESSING_DIR 'D02_STAGE/'];
    % BC2D generation directories:
INI.BC2D_DIR = [INI.PRE_PROCESSING_DIR 'G01_BC2D/'];

% -------------------------------------------------------------------------
% SETUP Location of ENPMS Scripts and Initialize
% -------------------------------------------------------------------------
INI.MATLAB_SCRIPTS = '../ENPMS/';

try
    addpath(genpath(INI.MATLAB_SCRIPTS));
catch
    addpath(genpath(INI.MATLAB_SCRIPTS,0));
end

% Save in MATLAB format? (0 = FALSE, 1 = TRUE)
SAVE_IN_MATLAB = 1;

% Delete existing DFS0 files? (0 = FALSE, 1 = TRUE)
INI.DELETE_EXISTING_DFS0 = 1;

% iterate over input file datatype directories with DFE *.dat files:
for DType_Flag = {'Water Level','Discharge'}
%for DType_Flag = {'Discharge','Water Elevation'}
    if strcmpi(DType_Flag,'Discharge')
        INI.DIR_DFS0_FILES = [INI.FLOW_DIR 'DFS0/'];                       % set output location fro DFS0 files to proper directory
        FILE_FILTER = [INI.input 'Flow/*.dat'];                            % list only files with extension *.dat
        DIR_FILES = FILE_FILTER;
        LISTING  = dir(char(DIR_FILES));
    elseif strcmpi(DType_Flag,'Water Level')
        INI.DIR_DFS0_FILES = [INI.STAGE_DIR 'DFS0/'];                      % set output location fro DFS0 files to proper directory
        FILE_FILTER = [INI.input 'Stage/*.dat'];                           % list only files with extension *.dat
        DIR_FILES = FILE_FILTER;
        LISTING  = dir(char(DIR_FILES));
    end
    D02_process_file_list(INI,LISTING,DType_Flag);                   % submit output DFS0 directory, input file list, and data type flag for processing
end

fclose('all');

end
