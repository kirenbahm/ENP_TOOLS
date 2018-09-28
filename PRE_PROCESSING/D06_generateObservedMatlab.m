function D06_generateObservedMatlab()
% This function creates MATLAB data file with
%observed data
%   This function reads sheet OBSERVED_DATA_MODEL/ALL_STATION_DATA and the
%   corresponding dfs0 files in 3 folders H_M11HR, H_MSHEHR and Q_M11HR
%   and creates a database of all observed based on the sheet
%   ALL_STATION_DATA. The function does not include files which are not in
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
INI.INPUT_DIR = '../../ENP_TOOLS_Sample_Input/Obs_Data_Processed/generateObserved_input/';
Q_M11HR_DIR  = 'Q_M11HR';   % (do not put '/' in this name)
H_M11HR_DIR  = 'H_M11HR';   % (do not put '/' in this name)
H_MSHEHR_DIR = 'H_MSHEHR';  % (do not put '/' in this name)
FILE_FILTER = '*.dfs0';   % File extension filter for input files

% Model number (don't change this - currently only M06 has been tested)
INI.MODEL = 'M06';  % options: 'M01' or 'M06'

% Excel file with station data, and sheets to be used for input & output
INI.XLSX_STATIONS = '../../ENP_TOOLS_Sample_Input/Obs_Data_Processed/generateObserved_input/OBSERVED_DATA_MODEL_testPreproc.xlsx';
INI.SHEET_ALL = 'SHP_ALL_STATIONS';           % station data is READ from this sheet
INI.SHEET_OBS = [INI.MODEL '_' 'MODEL_OBS'];  % station data is WRITTEN to this sheet

% Name of database file to be created
DATABASE_OBS = ['../../ENP_TOOLS_Sample_Input/Obs_Data_Processed/generateObserved_output/M06_OBSERVED_DATA_testPreproc.MATLAB'];

% Location to save dfs0 output files
INI.OUTPUT_DFS0_DIR = '../../ENP_TOOLS_Sample_Input/Obs_Data_Processed/generateObserved_output/DFS0/';

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

% read all stations from the excel file, stations are within M3ENP_SF
mapAllStations = OM00_read_xlsx_all_stations(INI);

% list and read all hourly files Q_M11HR
INI.DIR_DFS0_FILES = [INI.INPUT_DIR Q_M11HR_DIR '/'];
LIST_DFS0_F = [INI.DIR_DFS0_FILES FILE_FILTER];
LISTING_Q_M11  = dir(char(LIST_DFS0_F));
DATA_Q_M11HR = OM01_read_dfs0_files(INI,Q_M11HR_DIR,mapAllStations,LISTING_Q_M11);

% list and read all hourly files in H_M11HR
INI.DIR_DFS0_FILES = [INI.INPUT_DIR H_M11HR_DIR '/'];
LIST_DFS0_F = [INI.DIR_DFS0_FILES FILE_FILTER];
LISTING_H_M11  = dir(char(LIST_DFS0_F));
DATA_H_M11HR = OM01_read_dfs0_files(INI,H_M11HR_DIR,mapAllStations,LISTING_H_M11);

% list and read all hourly files in H_MSHEHR
INI.DIR_DFS0_FILES = [INI.INPUT_DIR H_MSHEHR_DIR '/'];
LIST_DFS0_F = [INI.DIR_DFS0_FILES FILE_FILTER];
LISTING_H_MSHE  = dir(char(LIST_DFS0_F));
DATA_H_MSHEHR = OM01_read_dfs0_files(INI,H_MSHEHR_DIR,mapAllStations,LISTING_H_MSHE);

% concatenate all structures and save into DATA variable
DATA = [DATA_Q_M11HR DATA_H_M11HR DATA_H_MSHEHR];

% Save DATA into the MAP_OBS map container
MAP_OBS = containers.Map;
for i = 1:length(DATA)
    STATION_NAME = DATA(i).STATION_NAME;
    MAP_OBS(char(STATION_NAME)) = DATA(i);    
end

% Save MAP_OBS variable into a .MATLAB file
save(char(DATABASE_OBS),'MAP_OBS','-v7.3');


% Save station metadata for stations in MAP_OBS into an Excel sheet
OM04_save_obs_station_xlsx(MAP_OBS,INI);

% Save data from MAP_OBS as individual dfs0 files.
%   note - it might be better to just copy the dfs0 files that were read at
%   the beginning of this script, instead of reading them and rewriting
%   them. should look into this further at some point.
OM05_saveDataDFS0(MAP_OBS,INI.OUTPUT_DFS0_DIR);

end

