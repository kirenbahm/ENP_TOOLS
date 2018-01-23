function [ output_args ] = generateComputedMatlab( input_args )

%generate_oberved_matlab() This function creates MATLAB data file with
%observed data
%   This function reads sheet OBSERVED_DATA_MODEL/ALL_STATION_DATA and the
%   corresponding dfs0 files in 3 folders H_M11HR, H_MSHEHR and Q_M11HR
%   and creates a database of all observed based on the sheet
%   ALL_STATION_DATA. The function does not include files which are not in
%   the sheet and does not include stations without data. The idea is to
%   generate observed data which is within the domain and will be used for
%   comparison

INI.SAVE_IN_MATLAB = 0; 
INI.SAVE_IN_MATLAB = 1; 

% do not change here
[INI.ROOT,NAME,EXT] = fileparts(pwd()); % path string of ROOT Directory/
INI.ROOT = [INI.ROOT '/'];
INI.CURRENT_PATH =[char(pwd()) '/']; % path string of folder MAIN

%---------------------------------------------------------------------
% SET UP PROFILE WITH LOCATION OF DIRECTORIES AND SCRIPTS
%---------------------------------------------------------------------
% ** NOTE: You will need to hardcode your profile in the setup_profile.m
%          script for this to work correctly

PROFILE_NAME = 'test'; % ( kiren inpeverhydrokc )

INI = setup_profile(INI,PROFILE_NAME);

%%%%%%%%%%% initialize names%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

INI.MODEL = 'M06'; %( M01 M06 )
INI.MODEL_LONGNAME = 'M06_M3ENP_SF'; %( M01_M3ENP M06_M3ENP_SF )
INI.VERSION = 'Vxx'; 
INI.ALTERNATIVE = 'M06_test';

INI.simRESULT = [INI.ResultDirHome INI.ALTERNATIVE '.she - Result Files\'];

INI.fileCompCoord = ['../ENP_TOOLS_Sample_Input/Data_Common/OBSERVED_DATA_MODEL_test.xlsx'];
INI.XLSCOMP = [INI.MODEL '_MODEL_COMP'];
INI.DATABASE_COMP = ['./COMPUTED_' INI.ALTERNATIVE '.MATLAB'];

INI.simRESULTmatlab = [INI.simRESULT 'matlab\'];

% files for extracting computed data
INI.fileM11WM = [INI.simRESULT 'MSHE_WM.dfs0'];
INI.fileOL = [INI.simRESULT INI.ALTERNATIVE '_overland.dfs2'];
INI.fileSZ = [INI.simRESULT INI.ALTERNATIVE '_3DSZ.dfs3'];

%INI.CONVERT_M11CHAINAGES = 1;
INI.CONVERT_M11CHAINAGES = 0.3048;

%hidden from the user%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% adds all paths within the root repository
%recursively add local libraries and directories
try
   addpath(genpath(INI.MATLAB_SCRIPTS));
catch
   addpath(genpath(INI.MATLAB_SCRIPTS,0));
end


if INI.SAVE_IN_MATLAB
    
    INI = readFileCompCoord(INI);
    
    INI = readM11_WM(INI);
    
    INI = readMSHE_WM(INI);
    
    mapCompSelected = INI.mapCompSelected;
    
    save(char(INI.DATABASE_COMP),'mapCompSelected','-v7.3');
else
    
    load(char(INI.DATABASE_COMP), '-mat');
    INI.mapCompSelected = mapCompSelected;
end

if 0
    plot_all(INI);
end

end

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
end

end


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
        
catch
    fprintf('\nException in get_TS_GRIDini reading .dfs2, or .dfs3: %s\n', char(FILE_DFS));
    
end
end

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
    fprintf('... Reading SZ Values: %s: %s %i %s %i\n', ds, ' Step: ', i, '/', TS.S.nsteps)
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

function INI = readM11_WM(INI)

mapM11CompP = containers.Map;
fprintf('--- reading file M11 results::%s\n',char(INI.fileM11WM));
DATA = read_file_DFS0(INI.fileM11WM);
SZ = size(DATA.V);
%xlswrite(char(INI.fileCompCoord),DATA.NAME','ALL_COMPUTED','B2');
fprintf('--- M11 results:: %d Computational Points with %d Timesteps\n',SZ(2),SZ(1));

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
        NAME = mapM11chain(char(M11CHAIN));
        fi = fi + 1;
        fprintf('-%d::Computational Node %s:: mapped to::%s\n',fi,char(NAME),char(M11CHAIN));
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
        %fprintf('-%d- Computational Node %s:: mapped to::%s\n',i,char(NAME),char(M11CHAIN));
        XNFOUND{fn} = M11CHAIN;
    end
end

SELECTED = values(mapM11chain)';
SELECTED = cellfun(@(x) cell2mat(x),SELECTED,'un',0);
SELECTED = sort(SELECTED);

XLSH = [INI.MODEL '_M11_CHAINAGES'];
%print selected
xlswrite(char(INI.fileCompCoord),{'SELECTED'},char(XLSH),'B1');
xlswrite(char(INI.fileCompCoord),SELECTED,char(XLSH),'B2');

% XFOUND = sort(XFOUND');
%print found
xlswrite(char(INI.fileCompCoord),{'CHAINAGE'},char(XLSH),'D1');
xlswrite(char(INI.fileCompCoord),XFOUND',char(XLSH),'D2');

% NAME_FOUND = sort(NAME_FOUND');
xlswrite(char(INI.fileCompCoord),{'STATION'},char(XLSH),'E1');
xlswrite(char(INI.fileCompCoord),NAME_FOUND',char(XLSH),'E2');

%print not found
XNFOUND = sort(XNFOUND'); 
xlswrite(char(INI.fileCompCoord),{'NOTFOUND'},char(XLSH),'G1');
xlswrite(char(INI.fileCompCoord),XNFOUND,char(XLSH),'G2');

fprintf('\n--- Check Sheet for summary of requested, found, not found M11 chainages::\n');
fprintf('FILE::%s:: SHEET::%s\n', char(INI.fileCompCoord),['ALL_COMPUTED_' INI.MODEL]);
end 

function INI = readFileCompCoord(INI)
% read the excel file to determine the computed coordinates and save in
% mapComputedDataCoord

INI.mapCompSelected = containers.Map;
[NUM,TXT,RAW] = xlsread(char(INI.fileCompCoord),char(INI.XLSCOMP));
fprintf('--- reading file::%s\n', char(INI.fileCompCoord));

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


end


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


