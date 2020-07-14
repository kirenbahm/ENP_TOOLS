function D06_generateObservedMatlab()

% This function creates MATLAB data file with observed data
%   This function reads sheet MODEL_DATA_ITEMS/M06_MODEL_COMP and the
%   corresponding dfs0 files in 3 folders H_DD and Q_DD
%   and creates a database of all observed based on the sheet
%   M06_MODEL_COMP. The function does not include files which are not in
%   the sheet and does not include stations without data. The idea is to
%   generate observed data which is within the domain and will be used for
%   comparison
%
% (formerly named A00_generateObservedMatlab_07212018.m)

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% BEGIN USER INPUT
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% Input directory and names of subdirectories containing dfs0 files
% use these for unit testing
%INI.INPUT_DIR = '../../ENP_TOOLS_Sample_Input/Obs_Data_Processed/generateObserved_input/';

% use these for sequential testing
INI.INPUT_DIR = '../../ENP_TOOLS_Output_Sequential/Obs_Data_Processed/';


Q_DD_DIR = 'Flow/DFS0DD';   % (do not put '/' in this name)
H_DD_DIR = 'Stage/DFS0DD';  % (do not put '/' in this name)
FILE_FILTER = '*.dfs0';   % File extension filter for input files

% Model number (don't change this - currently only M06 has been tested)
INI.MODEL = 'M06';  % options: 'M01' or 'M06'

% Excel file with station data, and sheets to be used for input & output
INI.XLSX_STATIONS = '../../ENP_FILES/ENP_TOOLS_Sample_Input/Data_Common/MODEL_DATA_ITEMS_20200609-beta.xlsx';
INI.SHEET_OBS = [INI.MODEL '_' 'MODEL_COMP'];  % station data is READ to this sheet

% Name of database file to be created
DATABASE_OBS = '../../ENP_TOOLS_Output_Sequential/SAMPLE_OBS_DATA_20200000.MATLAB';

% Location of ENPMS Scripts and Initialize
INI.MATLAB_SCRIPTS = '../ENPMS/';

% not sure if this is used anywhere:
INI.SAVE_IN_MATLAB = 1; 


% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% END USER INPUT
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% add tools to path
try
    addpath(genpath(INI.MATLAB_SCRIPTS));
catch
    addpath(genpath(INI.MATLAB_SCRIPTS,0));
end

%Initialize .NET libraries
INI = initializeLIB(INI);

% read all stations from the excel file, stations are within M3ENP_SF
% list and read all hourly files in H_M11HR
INI.DIR_DFS0_FILES = [INI.INPUT_DIR H_DD_DIR '\'];
LIST_DFS0_F = [INI.DIR_DFS0_FILES FILE_FILTER];
LISTING_H_M11  = dir(char(LIST_DFS0_F));

% list and read all hourly files Q_M11HR
INI.DIR_DFS0_FILES = [INI.INPUT_DIR Q_DD_DIR '\'];
LIST_DFS0_F = [INI.DIR_DFS0_FILES FILE_FILTER];
LISTING_Q_M11  = dir(char(LIST_DFS0_F));

LISTINGS = [LISTING_H_M11; LISTING_Q_M11];
MAP_OBS = OM00_read_xlsx_all_stations(INI, LISTINGS);
% concatenate all structures and save into DATA variable

% Save MAP_OBS variable into a .MATLAB file
save(char(DATABASE_OBS),'MAP_OBS','-v7.3');

fprintf('DONE');

end

