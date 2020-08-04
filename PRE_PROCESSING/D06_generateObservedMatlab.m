function D06_generateObservedMatlab()

% This function creates MATLAB data file with observed data
%   and creates a database of all observed based on the sheet
%   M06_MODEL_COMP. The function does not include files which are not in
%   the sheet and does not include stations without data. The idea is to
%   generate observed data which is within the domain and will be used for
%   comparison

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% BEGIN USER INPUT
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% Input directory and names of subdirectories containing dfs0 files
INI.DIR_H_DFS0_FILES = '../../ENP_FILES/ENP_TOOLS_Sample_Input/Obs_Processed_MATLAB/in/Stage/';
INI.DIR_Q_DFS0_FILES = '../../ENP_FILES/ENP_TOOLS_Sample_Input/Obs_Processed_MATLAB/in/Flow/';

FILE_FILTER = '*.dfs0';   % File extension filter for input files

% Model number (don't change this - currently only M06 has been tested)
INI.MODEL = 'M06';  % options: 'M01' or 'M06'

% Excel file with station data, and sheets to be used for input & output
INI.XLSX_STATIONS = '../../ENP_FILES/ENP_TOOLS_Sample_Input/Data_Common/MODEL_DATA_ITEMS_20200609-beta.xlsx';
INI.SHEET_OBS = [INI.MODEL '_' 'MODEL_COMP'];  % station data is READ to this sheet

% Location of database file to be created
DATABASE_OBS_FOLDER = '../../ENP_TOOLS_Output/Obs_Processed_MATLAB/out/';

% Name of database file to be created
DATABASE_OBS_FILE = 'SAMPLE_OBS_DATA_20200000.MATLAB';

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

% read all stations 
LIST_DFS0 = [INI.DIR_H_DFS0_FILES FILE_FILTER];
LISTING_H  = dir(char(LIST_DFS0));

LIST_DFS0 = [INI.DIR_Q_DFS0_FILES FILE_FILTER];
LISTING_Q  = dir(char(LIST_DFS0));

% concatenate all structures and save into DATA variable
LISTINGS = [LISTING_H; LISTING_Q];
MAP_OBS = OM00_read_xlsx_all_stations(INI, LISTINGS);

% Create output directory if it doesn't already exist
if ~exist(DATABASE_OBS_FOLDER, 'dir')
   mkdir(DATABASE_OBS_FOLDER)
end

% Save MAP_OBS variable into a .MATLAB file
DATABASE_OBS = [DATABASE_OBS_FOLDER DATABASE_OBS_FILE];

save(char(DATABASE_OBS),'MAP_OBS','-v7.3');

fprintf('DONE\n\n');

end

