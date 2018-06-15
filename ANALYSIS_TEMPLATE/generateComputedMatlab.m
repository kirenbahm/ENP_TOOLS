function [ output_args ] = generateComputedMatlab( input_args )

%---------------------------------------------------------------------
%---------------------------------------------------------------------
%  README for this function
%---------------------------------------------------------------------
%---------------------------------------------------------------------
%   This function reads computed data from a simulation (.dfs0 and .dfs2 filels) and generates a
%   Matlab database of computed M11 and MSHE data. The file requires the
%   folloing directories to be defined:

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

%The path to each simulation is provided in lines 54 and further
% do not change here
[INI.ROOT,NAME,EXT] = fileparts(pwd()); % path string of ROOT Directory/
INI.ROOT = [INI.ROOT '/'];
INI.CURRENT_PATH =[char(pwd()) '/']; % path string of folder MAIN

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
% 2. Set Location of Common Data  
%---------------------------------------------------------------------
INI.DATA_COMMON = '..\..\ENP_TOOLS_Sample_Input\Data_Common/'; 

%---------------------------------------------------------------------
% 3. Set location to store computed Matlab datafile for each simulation
%---------------------------------------------------------------------
INI.DATA_COMPUTED = '..\..\ENP_TOOLS_Sample_Input\Model_Output_Processed/';

%---------------------------------------------------------------------
% 4. Provide name of the Excel file with all stations (and data items):
%---------------------------------------------------------------------
INI.fileCompCoord = [INI.DATA_COMMON 'OBSERVED_DATA_MODEL_test.xlsx'];
% Set conversion factor for chainages between M11 in feet and in m (check
% the res11 file to determine if chainages are in feet
INI.CONVERT_M11CHAINAGES = 0.3048; %INI.CONVERT_M11CHAINAGES = 1; (valid for ft input)

%---------------------------------------------------------------------
% 5. CHOOSE SIMULATIONS TO BE ANALYZED
%---------------------------------------------------------------------
% This setup allows results from different directories or computers to be used 
% copying the data, i.e. INI.MODEL_SIMULATION_SET{i} can vary with respect
% to Path, Model (M01, M06) and Simulation name (alternative).
% Once data are extracted, simulation files may be deleted

i = 0;
%i = i + 1;  INI.MODEL_SIMULATION_SET{i} = ['..\..\ENP_TOOLS_Sample_Input\Result\', 'M01','_', 'test'];
i = i + 1;  INI.MODEL_SIMULATION_SET{i} = ['..\..\ENP_TOOLS_Sample_Input\Result\', 'M06','_', 'test'];

%---------------------------------------------------------------------
% 6. Process transects
%---------------------------------------------------------------------
INI.READ_TRANSECTS_MLAB = 0;
INI.LOAD_TRANSECTS_MLAB = 0;
INI.LOAD_OL = 0; % Load the OL MATLAB file as a preference if available
INI.LOAD_3DSZQ = 0; % Load the SZ MATLAB file as a preference if available
INI.TRANSECT = [ INI.DATA_COMMON 'TRANSECTS_v16.xlsx'];
 
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

try
    INI = fileAssertions(INI);
    INI = extractComputedData(INI);
catch INI
    S = 'extractComputedData(INI)';
    fprintf('...exception in::%s\n',char(S));
    msgException = getReport(INI,'extended','hyperlinks','on')
end

end

%---------------------------------------------------------------------
% function INI = extractComputedData(INI)
%---------------------------------------------------------------------
function INI = fileAssertions(INI);
% Move all file assertions here

assert(exist(INI.MATLAB_SCRIPTS,'file') == 7, 'Directory not found.' );

assert(exist(INI.DATA_COMMON,'file') == 7, 'Directory not found.' );

assert(exist(INI.DATA_COMPUTED,'file') == 7, 'Directory not found.' );

assert(exist(INI.fileCompCoord,'file') == 2, 'File not found.' );

assert(exist(INI.TRANSECT,'file') == 2, 'File not found.' );

end

%---------------------------------------------------------------------
% function INI = extractComputedData(INI)
%---------------------------------------------------------------------
function INI = extractTRANSECTS_MLAB(INI);

[A B C] = fileparts(INI.TRANSECT);

% Overland Flow File
i=1;
INI.CELL_DEF_FILE_DIR_OL   = INI.DATA_COMMON;
INI.CELL_DEF_FILE_NAME_OL  = B;
INI.CELL_DEF_FILE_SHEETNAME_OL{i} = 'OLQ'; i=i+1;
INI.CELL_DEF_FILE_SHEETNAME_OL{i} = 'OL2RIV'; i=i+1;

% 3D Saturated Zone Flow file
i=1;
INI.CELL_DEF_FILE_DIR_3DSZQ   = INI.DATA_COMMON;
INI.CELL_DEF_FILE_NAME_3DSZQ  = B;
INI.CELL_DEF_FILE_SHEETNAME_3DSZQ{i} = 'SZQ'; i=i+1;
INI.CELL_DEF_FILE_SHEETNAME_3DSZQ{i} = 'SZunderRIV'; i=i+1;
INI.CELL_DEF_FILE_SHEETNAME_3DSZQ{i} = 'SZ2RIV'; i=i+1;

INI.OVERWRITE_GRID_XL = 1; % this regenerates the gridded points from
%                             the corresponding EXCEL file. If this is 0
%                            monitoring points come from a matlab data file
%                            the same as the excel file but ext .MATLAB

i = 0;
for D = INI.MODEL_SIMULATION_SET
    
    % how to save
    TRANSECT_FILE = [INI.MODEL_SIMULATION_SET{1} '_TRANSECT.MATLAB'];
    i = i + 1; % Increment model run counter
    
    MODEL_RESULT_DIR = INI.MODEL_SIMULATION_SET{i};
    
    [D1 D2 D3] = fileparts(char(D));
    P1 = [char(D) '.she - Result Files/' char(D2)];
    FILE_OL  = [P1 '_overland.dfs2'];
    FILE_3DSZ = [P1 '_3DSZ.dfs3'];
    FILE_3DSZQ = [P1 '_3DSZflow.dfs3'];
    assert(exist(FILE_OL,'file') == 2, 'File not found.' );
    assert(exist(FILE_3DSZQ,'file') == 2, 'File not found.' );
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load model output data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Load and group OL gridded data
    L = INI.LOAD_OL;
    MAP_TRANSECT.OL = load_OL_GRIDDED(L,INI,MODEL_RESULT_DIR,FILE_OL);
    if INI.DEBUG
        DDA = MAP_TRANSECT.OL; %get the map
        K = keys(DDA); % list all keys
        S = DDA('T18-OL'); % print one of the keys
    end
    % Load and group 3DSZQ gridded data
    L = INI.LOAD_3DSZQ;
    MAP_TRANSECT.SZ = load_SZ_GRIDDED(L,INI,MODEL_RESULT_DIR,FILE_3DSZQ);
    
    if INI.DEBUG
        DDA = MAP_TRANSECT.SZ; %get the map
        K = keys(DDA); % list all keys
        S = DDA('T19'); % print one of the keys
    end
    INI.TRANSECTS_MLAB = MAP_TRANSECT;
    INI = convert_TRANSECT(INI, i);
    save(char(TRANSECT_FILE),'MAP_TRANSECT','-v7.3');
      
end
end

%---------------------------------------------------------------------
% function INI = convert_TRANSECT(INI)
%---------------------------------------------------------------------

function INI = convert_TRANSECT(INI, i);
% This function converts the Transect Timeseries to a Station representation
% to enable plotting and computing of transect data

M_ALL = INI.mapCompSelected;

M_OL = INI.TRANSECTS_MLAB.OL;
id = '_OL';
M_ALL = convert_map(INI, M_ALL, M_OL, id, i);

M_SZ = INI.TRANSECTS_MLAB.SZ;
id = '_SZ';
M_ALL = convert_map(INI, M_ALL, M_SZ, id, i);

INI.mapCompSelected = M_ALL;

%S = M_ALL('T19');

end

 
function M_ALL = convert_map(INI, M_ALL, MM, id, i)

M = containers.Map();

S = filesep; % file separator platform specific
C = strsplit(INI.MODEL_SIMULATION_SET{i},S); % get path names
INI.simMODEL =  char(C(end)); % use the last one for model name

for K = keys(MM)
    MT = MM(char(K));
    NAME = MT.NAME{1};
    T.STATION_NAME = [char(NAME)]; % = [char(NAME) char(id)];
    T.DATATYPE = MT.DFSTYPE;
    T.UNIT = MT.UNIT;
    T.X_UTM = NaN;
    T.Y_UTM = NaN;
    T.Z = NaN; % provide vector of T.Z including all cells used for transect
    T.I = NaN; % provide vector of T.I including all cells used for transect
    T.J = NaN; % provide vector of T.J including all cells used for transect
    T.M11CHAIN = '';
    T.N_AREA = 'TRANSECTS';
    T.I_AREA = 100;
    T.SZLAYER = NaN;
    T.OLLAYER = NaN;
    T.MODEL = INI.MODEL;
    T.NOTE = ''; 
    T.MSHEM11 ='TRANSECTS';
    T.ALTERNATIVE = INI.simMODEL;
    T.TIMEVECTOR = datenum(MT.TIMEVECTOR);
    T.DCOMPUTED = MT.TIMESERIES;
    M_ALL(char(K)) = T;    
end
end
%---------------------------------------------------------------------
% function INI = extractComputedData(INI)
%---------------------------------------------------------------------

function INI = extractComputedData(INI)
% extractComputedData(INI) reads simulation data and saves all extracted
% data in .MATLAB files

%---------------------------------------------------------------------
%Additional set up of default files user should not modify aything below
%---------------------------------------------------------------------

%Create an excel log file for stations requested and matched to chainages
INI.LOG_XLSX = [INI.DATA_COMPUTED 'LOG.xlsx'];

%---------------------------------------------------------------------
%Iteration over all simulations
%---------------------------------------------------------------------

nn = length(INI.MODEL_SIMULATION_SET);

for i = 1:nn
    S = filesep; % file separator platform specific
    C = strsplit(INI.MODEL_SIMULATION_SET{i},S); % get path names
    INI.simMODEL =  char(C(end)); % use the last one for model name
    INI.MODEL = char(INI.simMODEL(1:3)); %( M01 M06 ) - this string should provide the model
    INI.XLSCOMP = [INI.MODEL '_MODEL_COMP'];
    INI.LOG_XLSX_SH = char(INI.simMODEL);
    INI.ALTERNATIVE = INI.simMODEL;
    
    % read excel file with coordinates
    INI = readFileCompCoord(INI);
    
    INI.simRESULT = [INI.MODEL_SIMULATION_SET{i} '.she - Result Files\'];
    INI.DATABASE_COMP = char(strcat(INI.DATA_COMPUTED,'COMPUTED_',INI.simMODEL,'.MATLAB'));
    
    INI.simRESULTmatlab = [INI.simRESULT 'matlab\'];

    % files for extracting computed data
    INI.fileM11WM = [INI.simRESULT 'MSHE_WM.dfs0'];
    INI.fileOL = char(strcat(INI.simRESULT, INI.simMODEL, '_overland.dfs2'));
    INI.fileSZ = char(strcat(INI.simRESULT, INI.simMODEL, '_3DSZ.dfs3'));
    
    if ~exist(INI.DATA_COMPUTED, 'dir'), mkdir(char(INI.DATA_COMPUTED)),end;
    
    if INI.SAVE_IN_MATLAB
        
        try
            INI = readM11_WM(INI);
        catch INI
            fprintf('\nException in readM11_WM(INI), i=%d\n', i);
            msgException = getReport(INI,'extended','hyperlinks','on')
        end
        
        try
            INI = readMSHE_WM(INI);
        catch INI
            fprintf('\nException in readMSHE_WM(INI), i=%d\n', i);
            msgException = getReport(INI,'extended','hyperlinks','on')
        end
        
        % TRANSECTS_MLAB
        if INI.READ_TRANSECTS_MLAB
            try 
                INI.MAPXLS = INI.TRANSECT;
                INI = extractTRANSECTS_MLAB(INI);
            catch INI
                fprintf('\nException in extractTRANSECTS_MLAB(INI), i=%d\n', i);
                msgException = getReport(INI,'extended','hyperlinks','on')
            end
        end
        
        mapCompSelected = INI.mapCompSelected;
        save(char(INI.DATABASE_COMP),'mapCompSelected','-v7.3');

    else
        load(char(INI.DATABASE_COMP), '-mat');
        INI.mapCompSelected = mapCompSelected;
    end
    
    if INI.PLOT_COMPUTED
        try
            ME = plot_all(INI);
        catch ME
            msgException = getReport(ME,'extended','hyperlinks','on')
        end
    end
end

% %include computing seepage
% % map of requested seepage, note the scripts are MAPF specfic because they
% % accumulate X and Y seepage values in specific way
% U.MAPF = [INI.DATA_COMMON 'SEEPAGE_MAP.dfs2'];;

%     INI.MAPXLS = INI.mapCompSelected; % needed for transect calculations

end

%---------------------------------------------------------------------
% function MAP_COMPUTED_3DSZQ_DATA = load_SZ_GRIDDED
%---------------------------------------------------------------------

function MAP_COMPUTED_3DSZQ = load_SZ_GRIDDED(L,INI,MODEL_RESULT_DIR,FILE_3DSZQ)

MAP_COMPUTED_3DSZQ = containers.Map();

ML_FILE = [INI.simRESULTmatlab '/MAP_COMPUTED_3DSZQ.MATLAB'];
if ~exist(INI.simRESULTmatlab,'file')
    L = 0;% if directoryt doesnt exist, regenerate the matlab TRANSECT data
    mkdir(char(INI.simRESULTmatlab));
end

if ~L
    MAP_COMPUTED_3DSZQ = get_GRIDDED_DATA(FILE_3DSZQ,INI);
    save(char(ML_FILE), 'MAP_COMPUTED_3DSZQ', '-v7.3');
else
    try
        load(char(ML_FILE),'-mat');
    catch
        fprintf('\n... Exception in load_SZ_GRIDDED() \n');
        fprintf('\n... -> MAP_COMPUTED_3DSZQ.MATLAB not loaded, continuing with MAP_COMPUTED_3DSZQ_DATA = 0 \n');
    end;
end

end

%---------------------------------------------------------------------
% function MAP_COMPUTED_OL_DATA =load_OL_GRIDDED(L,INI,MODEL_RESULT_DIR,FILE_OL)
%---------------------------------------------------------------------

function MAP_COMPUTED_OL = load_OL_GRIDDED(L,INI,MODEL_RESULT_DIR,FILE_OL)

MAP_COMPUTED_OL_DATA = containers.Map();

ML_FILE = [INI.simRESULTmatlab '/MAP_COMPUTED_OL.MATLAB'];
if ~exist(INI.simRESULTmatlab,'file')
    L = 0; % if directoryt doesnt exist, regenerate the matlab TRANSECT data
    mkdir(char(INI.simRESULTmatlab));
end

if ~L
    MAP_COMPUTED_OL = get_GRIDDED_DATA(FILE_OL,INI);
    save(char(ML_FILE), 'MAP_COMPUTED_OL', '-v7.3');
else
    try
        load([INI.simRESULTmatlab 'MAP_COMPUTED_OL.MATLAB'],'-mat');
    catch
        fprintf('\n... Exception in load_OL_GRIDDED()');
        fprintf('\n... -> MAP_COMPUTED_OL.MATLAB not loaded, continuing with MAP_COMPUTED_OL_DATA = 0 \n');
    end;
end

end

%---------------------------------------------------------------------
% function INI = plot_all(INI)
%---------------------------------------------------------------------

function INI = plot_all(INI)

M = INI.mapCompSelected; 

KEYS = M.keys;

try
    for K = KEYS
        STATION = M(char(K));
        T = datestr(STATION.TIMEVECTOR);
        E = STATION.DCOMPUTED;
        TTS = timeseries(E,T);
        TTS.name = char(K);
        TTS.TimeInfo.Format = 'mm/yy';
        F = plot(TTS);
    end
catch
    fprintf('...exception in::%s\n', char(K));
    %msgException = getReport(INI,'extended','hyperlinks','on')
end

end

%---------------------------------------------------------------------
% function TS = get_TS_GRIDini(FILE_DFS)
%---------------------------------------------------------------------

function TS = get_TS_GRIDini(FILE_DFS)

fprintf('%s Reading file: %s\n',datestr(now), char(FILE_DFS));
[DIR,FNAME,EXT] = fileparts(FILE_DFS);

try
    if strcmp(EXT,'.dfs2')
        TS = iniDFS2(FILE_DFS);
    end
    
    if strcmp(EXT,'.dfs3')
        TS = iniDFS3(FILE_DFS);
    end
    
catch %ME
    fprintf('\nException in get_TS_GRIDini reading .dfs2, or .dfs3: %s\n', char(FILE_DFS));
    %fprintf('\nException in get_TS_GRIDini reading .dfs2, or .dfs3: %s\n', ME.msg);
end

end

%---------------------------------------------------------------------
% function [S] = iniDFS3(infile)
%---------------------------------------------------------------------

function [S] = iniDFS3(infile)

%{
Open and read info from a DFS3 file
%}

NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfs123.*;
S.DFS = DfsFileFactory.Dfs3FileOpen(infile);

% % Read coordinates from file. Note that values are element center values
% % and therefor 0.5*Dx/y is added to all coordinates
% %S.x = saxis.X0 + saxis.Dx*(0.5+(0:(saxis.XCount-1)))';
% %S.y = saxis.Y0 + saxis.Dy*(0.5+(0:(saxis.YCount-1)))';
% %X0 = 494889.2;
% %Y0 = 2790267;
saxis = S.DFS.SpatialAxis;
%TODO: check x,y are these centers?
S.x = saxis.X0 + saxis.Dx*((0:(saxis.XCount-1)))';
S.y = saxis.Y0 + saxis.Dy*((0:(saxis.YCount-1)))';
S.z = saxis.ZCount;
S.dx = saxis.Dx;
S.dy = saxis.Dy;
S.XCount = saxis.XCount;
S.YCount = saxis.YCount;

for i = 0:S.DFS.ItemInfo.Count-1
    S.item(i+1).itemname = char(S.DFS.ItemInfo.Item(i).Name);
    S.item(i+1).itemtype = char(S.DFS.ItemInfo.Item(i).DataType);
    %S.item(i+1).itemvalue = char(S.myDfs.ItemInfo.Item(i).ValueType); % Instantaneous
    S.item(i+1).itemunit = char(S.DFS.ItemInfo.Item(i).Quantity.UnitAbbreviation);
    S.item(i+1).itemdescription=char(S.DFS.ItemInfo.Item(i).Quantity.ItemDescription);
    %S.item(i+1).unitdescription=char(S.myDfs.ItemInfo.Item(i).Quantity.UnitDescription);
end
S.count = S.DFS.ItemInfo.Count;
S.deltat   = S.DFS.FileInfo.TimeAxis.TimeStep;
S.unitt   = char(S.DFS.FileInfo.TimeAxis.TimeUnit);
S.nsteps   = S.DFS.FileInfo.TimeAxis.NumberOfTimeSteps;
S.DELETE = S.DFS.FileInfo.DeleteValueFloat;
aD = S.DFS.FileInfo.TimeAxis.StartDateTime.Day;
aM = S.DFS.FileInfo.TimeAxis.StartDateTime.Month;
aY = S.DFS.FileInfo.TimeAxis.StartDateTime.Year;
aH = S.DFS.FileInfo.TimeAxis.StartDateTime.Hour;
am = S.DFS.FileInfo.TimeAxis.StartDateTime.Minute;
aS = S.DFS.FileInfo.TimeAxis.StartDateTime.Second;
S.TIMESTEPD = S.DFS.FileInfo.TimeAxis.TimeStep/86400;
S.TSTART = datenum(double([aY aM aD aH am aS]));
S.TV = (S.TSTART:S.TSTART+S.nsteps);

end

%---------------------------------------------------------------------
% function mapMSHESEL = getMSHEmap(INI)
%---------------------------------------------------------------------

function mapMSHESEL = getMSHEmap(INI)

mapMSHESEL = containers.Map;
mapCompSelected = INI.mapCompSelected;
KEYS = mapCompSelected.keys;

for K = KEYS
    STATION = INI.mapCompSelected(char(K));
    MSHETYPE = STATION.MSHEM11;
    if strcmp(MSHETYPE,'M11'), continue, end
    ST_SHE.NAME = STATION.STATION_NAME;    
    ST_SHE.X_UTM = STATION.X_UTM;    
    ST_SHE.Y_UTM = STATION.Y_UTM;    
    ST_SHE.i = STATION.I;    
    ST_SHE.j = STATION.J;  
    ST_SHE.Z = STATION.SZLAYER;
    mapMSHESEL(char(K)) = ST_SHE;
end

end

%---------------------------------------------------------------------
% function INI = readMSHE_WM(INI)
%---------------------------------------------------------------------

function INI = readMSHE_WM(INI)

% read file  INI.fileSZ for head in saturated zone
infile = INI.fileSZ;

% get all MSHE stations
mapMSHESEL = getMSHEmap(INI);

% initialize grid dfs3 file reading
TS.S = get_TS_GRIDini(infile);

TV = (TS.S.TSTART:TS.S.TSTART+TS.S.nsteps);

DATA(1:TS.S.XCount,1:TS.S.YCount) = NaN;

a = size(mapMSHESEL); % size of the vector of evaluated stations

i1 = TS.S.TSTART; % length of time vector
i2 = a(1); % length of extracted cells
i3 = 1; % codes of extracted cells

nsteps = TS.S.nsteps;

T = TS.S.TSTART - 1;
% this is to set the location of the array where to store data if the data
% starts later
i_1 = TS.S.TSTART ;

for i=0:nsteps-1
    %ds = datestr(TIME(i,:),2);
    %fprintf('%s %s %i %s %i\n', ds, ' Step: ', i+1, '/', TS.S.nsteps);
    T = T + TS.S.TIMESTEPD;
    ds = datestr(T);
    
    b = 10; % print only every 10 days
    if ~mod(i,b)
        fprintf('... Reading SZ Values: %s: %s %i %s %i\n', ds, ' Step: ', i, '/', TS.S.nsteps);
    end
    SZ_ELEV = double(TS.S.DFS.ReadItemTimeStep(1,i).To3DArray());
%     OL_DEPTH = double(TS.S.dfs2.ReadItemTimeStep(1,i).To2DArray());
    j = 0;
    for K = mapMSHESEL.keys
        STATION = mapMSHESEL(char(K));
        j; K;
        j = j + 1;
        x_i = min(TS.S.XCount,STATION.i + 1);
        y_j = min(TS.S.YCount,STATION.j + 1);
        x_i = max(0,x_i);
        y_j = max(0,y_j);
        SZ_ELEV_ijz = SZ_ELEV(x_i,y_j,STATION.Z);
%         OL_DEPTH_ij = OL_DEPTH(x_i,y_j);        
        ST(j).NAME = STATION.NAME;
        ST(j).UNIT = TS.S.item(1).itemunit;
        ST(j).DATE(i+1) = T;
        ST(j).SZ_ELEV(i+1) = SZ_ELEV_ijz;
%         ST(j).OL_DEPTH(i+1) = OL_DEPTH_ij;
        ST(j).COMP_DATE(i+1) = T;
    end   
end


for i = 1:length(ST)
    NAME = ST(i).NAME;
    K = NAME;
    fprintf('...computed::%s\n', char(K));
    STATION = INI.mapCompSelected(char(K));
%     STATION.COMP_DATE = ST(i).DATE;
    STATION.MSHE_SZ_ELEV = ST(i).SZ_ELEV;
%     STATION.MSHE_OL_DEPTH = ST(i).OL_DEPTH;
    STATION.MSHE_DATE = ST(i).COMP_DATE;   
    STATION.TIMEVECTOR = ST(i).COMP_DATE';   
    STATION.MSHE_UNIT_SZ_ELEV = char(TS.S.DFS.ItemInfo.Item(0).Quantity.UnitAbbreviation);
%     STATION.MSHE_UNIT_OL_DEPTH = char(TS.S.dfs2.ItemInfo.Item(0).Quantity.UnitAbbreviation) ;
    STATION.MSHE_TYPE_SZ_ELEV = char(TS.S.DFS.ItemInfo.Item(0).Quantity.ItemDescription);
%     STATION.MSHE_TYPE_OL_DEPTH = char(TS.S.dfs2.ItemInfo.Item(0).Quantity.ItemDescription);
    DN = ST(i).SZ_ELEV;
    DN(DN==TS.S.DELETE) = NaN;
    STATION.DCOMPUTED = DN';
    STATION.DATATYPE = STATION.MSHE_TYPE_SZ_ELEV;
    UNIT = STATION.MSHE_UNIT_SZ_ELEV;
    if strcmp(UNIT,'m')
        STATION.DCOMPUTED = STATION.DCOMPUTED/0.3048;
        STATION.UNIT = 'ft';
    end
    INI.mapCompSelected(char(NAME)) = STATION;
end

end

%---------------------------------------------------------------------
% function  mapM11chain = getMapM11Chainages(INI)
%---------------------------------------------------------------------

 function  mapM11chain = getMapM11Chainages(INI)

 % create a map of chainages with Station Names as values
KEYS = INI.mapCompSelected.keys;
mapM11chain = containers.Map;
i = 0;
for K = KEYS
    STATION = INI.mapCompSelected(char(K));
    if isempty(STATION.M11CHAIN), continue, end
    i = i + 1;
    M11CHAIN = STATION.M11CHAIN;
    M11CHAIN = strrep(M11CHAIN,' ','');
    STR_TEMP = strsplit(M11CHAIN,';');
    N = str2num(STR_TEMP{2});
    NSTR = sprintf('%.0f',N);
    M11CHAIN = [STR_TEMP{1} ';' NSTR ';' STR_TEMP{3}];
    mapM11chain(char(M11CHAIN)) = K;
    XSEL{i} = M11CHAIN;
end
 
 
 end
 
%---------------------------------------------------------------------
% function INI = readM11_WM(INI)
%---------------------------------------------------------------------
 
function INI = readM11_WM(INI)

mapM11CompP = containers.Map;

% check if file exist;
if exist(INI.fileM11WM, 'file')
    fprintf('--- Reading file M11 results::%s\n',char(INI.fileM11WM));
    DATA = read_file_DFS0(INI.fileM11WM);
    DATA.V(abs(DATA.V)<1e-8) = NaN; % remove non-physical values < 1e-8
else
    fprintf('WARNING: missing M11 file MSHE_WM for:%s\n',char(INI.fileM11WM));
    return
end

SZ = size(DATA.V);
%xlswrite(char(INI.fileCompCoord),DATA.NAME','ALL_COMPUTED','B2');
fprintf('--- M11 results have %d Computational Points with %d Timesteps\n',SZ(2),SZ(1));

% create a map of chainages with Station Names as values
mapM11chain = getMapM11Chainages(INI);

CF = INI.CONVERT_M11CHAINAGES;
fprintf('--- CONVERSION FACTOR FOR CHAINAGES::%f\n',CF);

fi = 0;
fn = 0;
ii = 0;
for i=1:SZ(2)
    M11CHAIN = DATA.NAME{i};
    M11CHAIN = strrep(M11CHAIN,' ','');
    STR_TEMP = strsplit(M11CHAIN,';');
    N = str2num(STR_TEMP{2})*CF; %if chainage is per foot -> meters
    NSTR = sprintf('%.0f',N);
    M11CHAIN = [STR_TEMP{1} ';' NSTR ';' STR_TEMP{3}];
    
    try
        XSEL{i} = M11CHAIN;
        if isKey(mapM11chain,char(M11CHAIN))
            NAME = mapM11chain(char(M11CHAIN));
        else
            %fprintf('-%d- WARNING: Computed nodes Not-Mapped to requested M11 Stations \t%s:: \t NOT found::\n',i,char(M11CHAIN));
            % dont print too much output not needed, it s recorded in
            % LOG.xlsx
            fn = fn + 1;
            XNFOUND{fn} = M11CHAIN;
            continue
        end
        
        fi = fi + 1;
        fprintf('-%d\t\t Requested M11 Station \t%s \t mapped to:\t%s\n',fi,char(NAME),char(M11CHAIN));
        STATION = INI.mapCompSelected(char(NAME));
        STATION.M11NAME = STATION.STATION_NAME;
        STATION.M11UNIT = DATA.UNIT(i);
        STATION.M11TYPE = DATA.TYPE(i);
        STATION.M11T = DATA.T;
        STATION.M11V = DATA.V(:,i);
        STATION.TIMEVECTOR = DATA.T;
        STATION.DCOMPUTED = STATION.M11V;
        if strcmp(STATION.M11UNIT,'m')
            STATION.DCOMPUTED = STATION.M11V/0.3048;
            STATION.UNIT = 'ft';
            STATION.DATATYPE = 'Elevation';
        end
        if strcmp(STATION.M11UNIT,'m^3/s')
            STATION.DCOMPUTED = STATION.M11V/(0.3048^3);
            STATION.UNIT = 'feet^3/sec';
        end
        INI.mapCompSelected(char(NAME)) = STATION;
        XFOUND{fi} = M11CHAIN;
        NAME_FOUND(fi) = NAME;
    catch
        fn = fn + 1;
        fprintf('-%d- WARNING:: Exception in reading M11 in %s for requested station %s\n',i,char(NAME),char(M11CHAIN));
        XNFOUND{fn} = M11CHAIN;
    end
end

SELECTED = values(mapM11chain)';
SELECTED = cellfun(@(x) cell2mat(x),SELECTED,'un',0);
SELECTED = sort(SELECTED);

XLSH = [INI.LOG_XLSX_SH '_M11_SH'];
%print selected
xlswrite(char(INI.LOG_XLSX),{'SELECTED'},char(XLSH),'B1');
xlswrite(char(INI.LOG_XLSX),SELECTED,char(XLSH),'B2');

% XFOUND = sort(XFOUND');
%print found
xlswrite(char(INI.LOG_XLSX),{'CHAINAGE'},char(XLSH),'D1');
xlswrite(char(INI.LOG_XLSX),XFOUND',char(XLSH),'D2');

% NAME_FOUND = sort(NAME_FOUND');
xlswrite(char(INI.LOG_XLSX),{'STATION'},char(XLSH),'E1');
xlswrite(char(INI.LOG_XLSX),NAME_FOUND',char(XLSH),'E2');

%print not found
XNFOUND = sort(XNFOUND'); 
xlswrite(char(INI.LOG_XLSX),{'NOTFOUND'},char(XLSH),'G1');
xlswrite(char(INI.LOG_XLSX),XNFOUND,char(XLSH),'G2');

fprintf('--- Summary of M11 results from file %s \n',char(INI.fileM11WM));
fprintf('    - %d Requested M11 stations\n', length(mapM11chain));
fprintf('    - %d Computed nodes mapped to requested M11 Stations \n',length(XFOUND));
fprintf('    - %d Computed nodes Not-Mapped to requested M11 Stations\n',length(mapM11chain)-length(XFOUND));
S = strcat(INI.LOG_XLSX, '\', XLSH);
fprintf('    - Review LOG File %s for summary of Requested, Mapped, Not-Mapped M11 chainages::\n', char(S));
fprintf('    - Review Sheet::%s for exact listing of matched M11 computation nodes and stations\n\n', ['ALL_COMPUTED_' INI.MODEL]);

end 

%---------------------------------------------------------------------
% function INI = readFileCompCoord(INI)
%---------------------------------------------------------------------

function INI = readFileCompCoord(INI)
% read the excel file to determine the computed coordinates and save in
% mapComputedDataCoord

INI.mapCompSelected = containers.Map;
[NUM,TXT,RAW] = xlsread(char(INI.fileCompCoord),char(INI.XLSCOMP));
fprintf('--- Reading file::%s with a list of stations to be extracted from raw data\n', char(INI.fileCompCoord));

for i = 2:length(RAW)
    try
        STATION_NAME = char(RAW(i,1));
        %fprintf('--- reading line %d::%s\n', i, char(STATION_NAME))
        stationComputed.STATION_NAME = STATION_NAME;
        stationComputed.DATATYPE = cell2mat(RAW(i,4));
        stationComputed.UNIT = char(RAW(i,5));
        stationComputed.X_UTM = cell2mat(RAW(i,6));
        stationComputed.Y_UTM = cell2mat(RAW(i,7));
        stationComputed.Z = cell2mat(RAW(i,8));
        stationComputed.I = cell2mat(RAW(i,15));
        stationComputed.J = cell2mat(RAW(i,16));
        stationComputed.M11CHAIN = '';
        stationComputed.N_AREA = char(TXT(i,18));
        stationComputed.I_AREA = cell2mat(RAW(i,19));
        stationComputed.SZLAYER = cell2mat(RAW(i,20));
        stationComputed.OLLAYER = cell2mat(RAW(i,21));
        stationComputed.MODEL = char(TXT(i,22));
        stationComputed.NOTE = '';
        if ~isempty(char(TXT(i,23)))
            stationComputed.NOTE = char(TXT(i,23));
        end
            
        if ~isempty(char(TXT(i,17)))
            stationComputed.MSHEM11 = 'M11';
            stationComputed.MODEL = INI.MODEL;
            stationComputed.ALTERNATIVE = INI.ALTERNATIVE;
            M11 = char(RAW(i,17));
            STR_TEMP = strsplit(M11,';');
            % convert the string to the format in dfs0 file.
            N = str2num(STR_TEMP{2});
            NSTR = sprintf('%.0f',N);
            M11CHAIN = [STR_TEMP{1} ';' NSTR ';' stationComputed.DATATYPE];
            M11CHAIN = strrep(M11CHAIN, ' ', '');
            stationComputed.M11CHAIN = M11CHAIN;
        else
            stationComputed.MSHEM11 = 'MSHE';
        end
        INI.mapCompSelected(char(STATION_NAME)) = stationComputed;
    catch
        fprintf('--- exception line in %d::%s\n', i, char(STATION_NAME));
    end
end

fprintf('--- Stations file::%s: has %i stations\n\n', char(INI.fileCompCoord), length(INI.mapCompSelected));

end

%---------------------------------------------------------------------
% function DFS0 = read_file_DFS0(FILE_NAME)
%---------------------------------------------------------------------

function DFS0 = read_file_DFS0(FILE_NAME)
NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfs0.*;
dfs0File  = DfsFileFactory.DfsGenericOpen(FILE_NAME);
dd = double(Dfs0Util.ReadDfs0DataDouble(dfs0File));

yy = double(dfs0File.FileInfo.TimeAxis.StartDateTime.Year);
mo = double(dfs0File.FileInfo.TimeAxis.StartDateTime.Month);
da = double(dfs0File.FileInfo.TimeAxis.StartDateTime.Day);
hh = double(dfs0File.FileInfo.TimeAxis.StartDateTime.Hour);
mi = double(dfs0File.FileInfo.TimeAxis.StartDateTime.Minute);
se = double(dfs0File.FileInfo.TimeAxis.StartDateTime.Second);

START_TIME = datenum(yy,mo,da,hh,mi,se);

DFS0.T = datenum(dd(:,1))/86400 + START_TIME;
%DFS0.TSTR = datestr(DFS0.T); not needed, slow
DFS0.V = dd(:,2:end);

for i = 0:dfs0File.ItemInfo.Count - 1
    DFS0.TYPE(i+1) = {char(dfs0File.ItemInfo.Item(i).Quantity.ItemDescription)};
    DFS0.UNIT(i+1) = {char(dfs0File.ItemInfo.Item(i).Quantity.UnitAbbreviation)};
    DFS0.NAME(i+1) = {char(dfs0File.ItemInfo.Item(i).Name)};
end
% plot(DFS0.T,DFS0.V)
% A = datestr(DFS0.T);
% plot(A,DFS0.V);

dfs0File.Close();

end


