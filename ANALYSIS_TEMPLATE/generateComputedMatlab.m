function [ output_args ] = generateComputedMatlab( input_args )

%---------------------------------------------------------------------
%---------------------------------------------------------------------
%  README for this function
%---------------------------------------------------------------------
%---------------------------------------------------------------------
%   This function reads computed data from a simulation (.dfs0 and .dfs2 filels) and generates a
%   Matlab database of computed M11 and MSHE data. The file requires the
%   following directories to be defined:

% 1. Location of ENPMS scripts e.g. 'some path\ENP_TOOLS\ENPMS\'
% 2. Location of common data (spreadsheet with chainages ij-coordinates for
% each model e.g. 'some path/DATA_COMMON/'
% 3. Location of where the computed data will be saved, in this directory
% also a LOG.xlsx file is saved with list of MIKE 11 requested, found and
% not found
% 4. List of paths of computed data and simulations to be analyzed
% 5  Assign the excel file with all data items
% 5. Select TRANSECTS_MLAB will be used to extract values
% 6. Select seepage map will be used to extract values  
% 7. Set conversion factor for chainages between M11 in feet and in m (check
% the res11 file to determine if chainages are in feet


%%% DO NOT MODIFY (begin)
[INI.ROOT,NAME,EXT] = fileparts(pwd()); % path string of ROOT Directory/
INI.ROOT = [INI.ROOT '/'];
INI.CURRENT_PATH =[char(pwd()) '/']; % path string of folder MAIN
%%% DO NOT MODIFY (end)


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

%Initialize .NET libraries
INI = initializeLIB(INI);

%---------------------------------------------------------------------
% 2. Set Location of Common Data  
%---------------------------------------------------------------------
INI.DATA_COMMON = '..\..\ENP_FILES\ENP_TOOLS_Sample_Input\Data_Common\'; 

%---------------------------------------------------------------------
% 3. Set location to store computed Matlab datafile for each simulation
%---------------------------------------------------------------------
% use this for unit testing
INI.DATA_COMPUTED = '..\..\ENP_TOOLS_Output\generateComputedMatlab_output\Model_Output_Processed\';

% use this for sequential testing
%INI.DATA_COMPUTED = '..\..\ENP_TOOLS_Output_Sequential\Model_Output_Processed\';

%---------------------------------------------------------------------
% 4. Provide name of the Excel file with all stations (and data items):
%---------------------------------------------------------------------
INI.fileCompCoord = [INI.DATA_COMMON 'MODEL_DATA_ITEMS_20200305.xlsx'];

% Conversion factor for chainage units between Excel file and MSHE_WM.dfs0 file
%INI.CONVERT_M11CHAINAGES = 0.3048; % use 0.3048 if Excel file chainages in meters and MSHE_WM.dfs0 chainages in feet
INI.CONVERT_M11CHAINAGES = 1.0;     % use 1.0 if Excel file chainages in feet and MSHE_WM.dfs0 chainages in feet

%---------------------------------------------------------------------
% 5. CHOOSE SIMULATIONS TO BE ANALYZED
%---------------------------------------------------------------------
% This setup allows results from different directories or computers to be used 
% copying the data, i.e. INI.MODEL_SIMULATION_SET{i} can vary with respect
% to Path, Model (M01, M06) and Simulation name (alternative).
% Once data are extracted, simulation files may be deleted

i = 0;
i = i + 1;  INI.MODEL_SIMULATION_SET{i} = ['..\..\ENP_FILES\ENP_TOOLS_Sample_Input\Result\', 'M01','_', 'test'];
i = i + 1;  INI.MODEL_SIMULATION_SET{i} = ['..\..\ENP_FILES\ENP_TOOLS_Sample_Input\Result\', 'M06','_', 'test'];
%i = i + 1;  INI.MODEL_SIMULATION_SET{i} = ['..\..\ENP_FILES\ENP_TOOLS_Sample_Input\Result\', 'M01','_', 'test_short'];
%i = i + 1;  INI.MODEL_SIMULATION_SET{i} = ['..\..\ENP_FILES\ENP_TOOLS_Sample_Input\Result\', 'M06','_', 'test_short'];

%---------------------------------------------------------------------
% 6. Process transects
%---------------------------------------------------------------------
INI.READ_TRANSECTS_MLAB = 1; % set this switch to execute transects code
INI.LOAD_TRANSECTS_MLAB = 0; % this does not seem to be used for anything?
INI.LOAD_OL = 0;    % this variable also exists in setup_ini.m but is used in a different way % Load the OL MATLAB file as a preference if available
INI.LOAD_3DSZQ = 0; % this variable also exists in setup_ini.m but is used in a different way % Load the SZ MATLAB file as a preference if available
INI.TRANSECT_DEFS_FILE = [ INI.DATA_COMMON 'TRANSECTS_20200403.xlsx'];
 
% define Overland Flow transect sheetnames
ii=1;
INI.TRANSECT_DEFS_SHEETNAMES_OL{ii} = 'OLQ'; ii=ii+1;
INI.TRANSECT_DEFS_SHEETNAMES_OL{ii} = 'OL2RIV'; ii=ii+1;

% define 3D Saturated Zone Flow transect sheetnames
ii=1;
INI.TRANSECT_DEFS_SHEETNAMES_3DSZQ{ii} = 'SZQ'; ii=ii+1;
INI.TRANSECT_DEFS_SHEETNAMES_3DSZQ{ii} = 'SZunderRIV'; ii=ii+1;
INI.TRANSECT_DEFS_SHEETNAMES_3DSZQ{ii} = 'SZ2RIV'; ii=ii+1;

%---------------------------------------------------------------------
% 6. Process and seepage maps
%---------------------------------------------------------------------
INI.READ_SEEPAGE_MAP = 0;
% INI.SEEPAGE_MAP = [ INI.DATA_COMMON 'M01_SEEPAGE_MAP.dfs2'];
% assert(exist(INI.SEEPAGE_MAP,'file') == 2, 'File not found.' );
% INI.SEEPAGE_MAP = [ INI.DATA_COMMON 'M06_SEEPAGE_MAP.dfs2'];
% assert(exist(INI.SEEPAGE_MAP,'file') == 2, 'File not found.' );

%---------------------------------------------------------------------
% Additional settings, DEFAULT can be modified for additional functionality
%---------------------------------------------------------------------

INI.SAVE_IN_MATLAB = 0; % read only database, this is for testing and plotting
INI.SAVE_IN_MATLAB = 1; % (DEFAULT) force recreate and write matlab database 

INI.PLOT_COMPUTED = 1; % The user does not plot computed data
INI.PLOT_COMPUTED = 0; %  (DEFAULT) The user plots computed data 

INI.DEBUG = 0; % go in debug mdoe to executed ebug statements

%---------------------------------------------------------------------
% END OF USER INPUT: start extraction
%---------------------------------------------------------------------

% Check if required input files and folders exist
MatScrExist = exist(INI.MATLAB_SCRIPTS,'file') == 7;
DataCommonExist = exist(INI.DATA_COMMON,'file') == 7;
fileCompCoordExist = exist(INI.fileCompCoord,'file') == 2;
TransectDefsFileExist = exist(INI.TRANSECT_DEFS_FILE,'file') == 2;

% If all required inputs exist, continue script
if(MatScrExist && DataCommonExist && fileCompCoordExist && TransectDefsFileExist)
    INI = extractComputedData(INI);
    
% Else print error messages on files/folders not found
else
    fprintf('\n');
    if(~MatScrExist)
        fprintf('ERROR: INI.MATLAB_SCRIPTS directory was not found at %s.\n',char(INI.MATLAB_SCRIPTS));
    end
    if(~DataCommonExist)
        fprintf('ERROR: INI.DATA_COMMON directory was not found at %s.\n',char(INI.DATA_COMMON));
    end
    if(~fileCompCoordExist)
        fprintf('ERROR: INI.fileCompCoord file was not found at %s.\n',char(INI.fileCompCoord));
    end
    if(~TransectDefsFileExist)
        fprintf('ERROR: INI.TRANSECT_DEFS_FILE file was not found at %s.\n',char(INI.TRANSECT_DEFS_FILE));
    end
    fprintf('\n');
    error('Execution stopped');
end

fprintf('\n\n *** generateComputedMatlab completed ***\n\n');

end

