function [ output_args ] = generateObservedMatlab( input_args )
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
%use dfs0 files
FILE_FILTER = '*.dfs0'; % list only files with extension .out

%%%%%%%%%%% initialize names%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
INI.OBS_DATA_PATH = './EXAMPLE_DATA/OBSERVED_DATA/';

%location of scripts
addpath(genpath('.\ENPMS'));

INI.MODEL = 'M01'; % use M01 or M06 here

%name of excel file to be used
INI.XLSX_STATIONS = './EXAMPLE_DATA/OBSERVED_DATA_MODEL_test.xlsx';
INI.SHEET_ALL = ['SHP' '_' 'ALL_STATIONS'];
INI.SHEET_OBS = [INI.MODEL '_' 'MODEL_OBS'];
INI.SHEET_COMP = [INI.MODEL '_' 'MODEL_COMP'];

%name of database to be created
DATABASE_OBS = ['./' INI.MODEL '_OBSERVED_DATA_test.MATLAB'];

%%%%%%%%%%% end initialize names%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% list all hourly files Q_M11HR
DIR = 'Q_M11HR/';
INI.DIR_DFS0_FILES = [INI.OBS_DATA_PATH DIR];
LIST_DFS0_F = [INI.DIR_DFS0_FILES FILE_FILTER];
LISTING_Q_M11  = dir(char(LIST_DFS0_F));

% list all hourly files in H_M11HR
DIR = 'H_M11HR/';
INI.DIR_DFS0_FILES = [INI.OBS_DATA_PATH DIR];
LIST_DFS0_F = [INI.DIR_DFS0_FILES FILE_FILTER];
LISTING_H_M11  = dir(char(LIST_DFS0_F));

% list all hourly files in H_MSHEHR
DIR = 'H_MSHEHR/';
INI.DIR_DFS0_FILES = [INI.OBS_DATA_PATH DIR];
LIST_DFS0_F = [INI.DIR_DFS0_FILES FILE_FILTER];
LISTING_H_MSHE  = dir(char(LIST_DFS0_F));

% read all stations from the excel file, stations are within M3ENP_SF
mapAllStations = read_xlsx_all_stations(INI);

% read all dfs0 files in 'Q_M11HR/';
DIR = 'Q_M11HR';
DATA_Q_M11HR = read_dfs0_files(INI,DIR,mapAllStations,LISTING_Q_M11);

% read all dfs0 files in 'H_M11HR/';
DIR = 'H_M11HR';
DATA_H_M11HR = read_dfs0_files(INI,DIR,mapAllStations,LISTING_H_M11);

% read all dfs0 files in 'H_MSHEHR/';
DIR = 'H_MSHEHR';
DATA_H_MSHEHR = read_dfs0_files(INI,DIR,mapAllStations,LISTING_H_MSHE);

% concatenate all structures and save
DATA = [DATA_Q_M11HR DATA_H_M11HR DATA_H_MSHEHR];

% Create a Map of Observed; MAP_OBS
MAP_OBS = createMapObs(DATA);

% Save observed DATA for use in scripting usig MATLAB format
save(char(DATABASE_OBS),'MAP_OBS','-v7.3');
% load(char(DATABASE_OBS),'-mat');

% Save in excel all data in MODEL_OBS_DATA
save_obs_station_xlsx(MAP_OBS,INI);
%writetable(struct2table(DATA),'test.xlsx');

end

function MAP_OBS = createMapObs(DATA)
% This function takes all structures and creates a map of observed data by
% station name, which is used as the key for data acess
MAP_OBS = containers.Map;

for i = 1:length(DATA)
    STATION_NAME = DATA(i).STATION_NAME;
    MAP_OBS(char(STATION_NAME)) = DATA(i);    
end

end


function save_obs_station_xlsx(MAP_OBS,INI)

T = {'Station', 'nTime', 'nData', 'Type', 'Unit','X_UTM', 'Y_UTM', 'Z',...
    'Z_GRID', 'Z_SURF', 'Z_SURVEY', 'T_START', 'T_END','MODEL', ...
    'I', 'J', 'M11_CHAIN','N_AREA','I_AREA','SZLAYER','OLLAYER','MODEL_DOM'};

KEYS = MAP_OBS.keys;
i = 0;
for K = KEYS
    i = i + 1;
    STATION = MAP_OBS(char(K));
    S{i} = STATION.STATION_NAME;    
    nt(i) = length(STATION.TIMEVECTOR);
    nv(i) = length(STATION.DOBSERVED);
    t{i} = STATION.DFSTYPE;
    u{i} = STATION.UNIT;
    x(i) = STATION.X_UTM;    
    y(i) = STATION.Y_UTM;    
    z(i) = STATION.Z;
    zg(i) = STATION.Z_GRID;
    zs(i) = STATION.Z_SURF;
    zsv(i) = STATION.Z_SURVEY;
    ts{i} = datestr(STATION.STARTDATE);
    te{i} = datestr(STATION.ENDDATE);
    tm{i} = STATION.DATATYPE;
    na{i} = STATION.N_AREA{:};
    ia(i) = STATION.I_AREA;
    szl(i) = STATION.SZLAYER;
    oll(i) = STATION.OLLAYER;
    mm{i} = INI.MODEL;
    m11{i} = '';
    ic(i) = 0;
    jc(i) = 0;   
end

TABLE_H = [T];
TABLE_D = [S', num2cell(nt'), num2cell(nv'), t', u', num2cell(x'),...
    num2cell(y'), num2cell(z'), num2cell(zg'), num2cell(zs'),...
    num2cell(zsv'), ts', te', tm', num2cell(ic'), num2cell(jc'), m11',...
    na',num2cell(ia'),num2cell(szl'),num2cell(oll'),mm'];
xlRange = 'A1';
xlswrite(char(INI.XLSX_STATIONS),TABLE_H,char(INI.SHEET_OBS),xlRange);
xlRange = 'A2';
xlswrite(char(INI.XLSX_STATIONS),TABLE_D,char(INI.SHEET_OBS),xlRange);

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
DFS0.TYPE = char(dfs0File.ItemInfo.Item(0).Quantity.ItemDescription);
DFS0.UNIT = char(dfs0File.ItemInfo.Item(0).Quantity.UnitAbbreviation);

% plot(DFS0.T,DFS0.V)
% A = datestr(DFS0.T);
% plot(A,DFS0.V);

dfs0File.Close();

end



function [STATION] = read_dfs0_files(INI,DIR,mapAllStations,LISTING)
n = length(LISTING);

if strcmp(DIR,'Q_M11HR')
    DATATYPE = 'M11';
    DELIM = '_Q';
end

if strcmp(DIR,'H_M11HR')
    DATATYPE = 'M11';
    DELIM = '.';
    
end
if strcmp(DIR,'H_MSHEHR')
    DATATYPE = 'MSHE';
    DELIM = '.';    
end

ii = 0;
for i = 1:n
    try
        s = LISTING(i);
        FILENAME = s.name;
        FILEPATH = [INI.OBS_DATA_PATH DIR '/' FILENAME];
        
        % get the name of the file without _Q, .stage .tailwater .headwater
        STR_TEMP = strsplit(FILENAME,DELIM);
        STATION_NAME = STR_TEMP{1};
        try
            TMP_STATION = mapAllStations(char(STATION_NAME));
        catch
            fprintf('... %s not in domain: %d/%d\n', char(STATION_NAME), i, n);
            continue
        end
        % increment only if data within the domain
        M1 = INI.MODEL;
        M2 = TMP_STATION.MODEL;
        if ~any(strcmp(M2,M1))
            fprintf('... %s not in %s domain %d/%d\n', char(STATION_NAME), char(INI.MODEL), i, n);
            continue
        end
        ii = ii + 1;
        STATION(ii) = TMP_STATION;
        if strcmp(STR_TEMP{2},'head_water')
            STATION_NAME = [STATION_NAME '_HW'];
        end
        if strcmp(STR_TEMP{2},'tail_water')
            STATION_NAME = [STATION_NAME '_TW'];
        end
        if strcmp(DELIM,'_Q')
            STATION_NAME = [STATION_NAME '_Q'];
        end        
        STATION(ii).STATION_NAME = STATION_NAME;
        
        %FILE_ID = fopen(char(FILE_NAME));
        fprintf('... reading: %d/%d: %s \n', i, n, char(FILEPATH));
        
        % read database file
        DFS0 = read_file_DFS0(FILEPATH);
        if strcmp(DFS0.UNIT,'ft')
            if isfield(TMP_STATION,'DATUM')
                if strcmp(TMP_STATION.DATUM,'NAVD88')
                    if isnumeric(TMP_STATION.NAVD_CONV)
                        DFS0.V = DFS0.V - TMP_STATION.NAVD_CONV;
                    else
                        fprintf('... WARNING: NO CONVERSION to NAVD88 %d/%d: %s \n', i, n, char(NAME));
                    end
                end
            end
        end
        STATION(ii).TIMEVECTOR = DFS0.T;
        STATION(ii).DOBSERVED = DFS0.V;
        STATION(ii).DFSTYPE = DFS0.TYPE;
        STATION(ii).UNIT = DFS0.UNIT;
        STATION(ii).STARTDATE = DFS0.T(1);
        STATION(ii).ENDDATE = DFS0.T(end);
        STATION(ii).DATATYPE = DATATYPE;        
        
%         DFS0 = assign_TYPE_UNIT(DFS0,NAME);
%         DFS0.NAME = NAME;
%         
%         fprintf('... reducing: %d/%d: %s \n', i, n, char(FILE_NAME))       
%         DFS0 = data_reduce_HR(DFS0);
%         
% % create a hourly file dfs0 file.   
%         [A, B, C] = fileparts(char(FILE_NAME));
%         FILE_NAME = [INI.CURRENT_PATH,'DFS0HR/',B,'.dfs0']; 
%         DFS0.STATION = B;
%         % save the file in a new directory
%         create_DFS0_GENERIC_Q(INI,DFS0,FILE_NAME);
% 
%         % read the new hourly file
%         fprintf('... reading: %d/%d: %s \n', i, n, char(FILE_NAME));
%         DFS0 = read_file_DFS0(FILE_NAME);
%         DFS0 = assign_TYPE_UNIT(DFS0,NAME);
%         DFS0.NAME = NAME;
%         
%         DFS0 = data_compute(DFS0);
%         INI.DIR_DFS0_FILES = strrep(INI.DIR_DFS0_FILES,'DFS0','DFS0HR');
%         % generate Timeseries
%         plot_fig_TS_1(DFS0,INI);
%         
%         % generate Cumulative
%         %plot_fig_CUMULATIVE_1(DFS0,INI);
% 
%         % generate CDF
%         plot_fig_CDF_1(DFS0,INI)
%         
%         % generate PE
%         plot_fig_PE_1(DFS0,INI)
%         
%         % plot Monthly
%        % plot_fig_MM_1(DFS0,INI)
%         
%         % plot Annual       
%         plot_fig_YY_1(DFS0,INI)
%  
    catch
        fprintf('... exception in: %d/%d: %s \n', i, n, char(FILEPATH));
    end
end

end

function [ mapAllStations ] = read_xlsx_all_stations( INI)

%READ_XLSX_ALL_STATION() This function reads ALL_STATION_DATA Sheet
%   The function reads ALL_STATION_DATA sheet and creates a map, it also
%   reads the subdirectories with hourly data and compares if the dfs0
%   files are within the domain and ignores if not, it also erases stations
%   without data

mapAllStations = containers.Map;

[status,sheets,xlFormat] = xlsfinfo(INI.XLSX_STATIONS);
[NUM,TXT,RAW] = xlsread(INI.XLSX_STATIONS,INI.SHEET_ALL);

% find columns with 'MODEL_*;
index_MODEL = ~cellfun(@isempty,strfind(RAW(1,:),'MODEL_'));

for i = 2:length(RAW)
    STATION.STATION_NAME = RAW(i,3);    
    STATION.TIMEVECTOR = [];
    STATION.DOBSERVED = [];
    STATION.DFSTYPE = '';
    STATION.UNIT = '';
    STATION.DATUM = RAW(i,10);
    STATION.X_UTM = cell2mat(RAW(i,11));    
    STATION.Y_UTM = cell2mat(RAW(i,12));   
    STATION.NOTE = RAW(i,14);
    STATION.NAVD_CONV = cell2mat(RAW(i,15));
    if strcmp(RAW(i,7),' ')
        STATION.Z = NaN;
    else
        STATION.Z = cell2mat(RAW(i,7));
    end
    STATION.Z_GRID = NaN;
    STATION.Z_SURF = NaN;
    STATION.Z_SURVEY = NaN;
    STATION.STARTDATE = [];
    STATION.ENDDATE = [];
    STATION.DATATYPE = '';
    STATION.N_AREA = RAW(i,17); 
    STATION.I_AREA = cell2mat(RAW(i,18));  
    STATION.SZLAYER = cell2mat(RAW(i,19));   
    STATION.OLLAYER = cell2mat(RAW(i,20)); 
    STATION.MODEL = (RAW(i,index_MODEL));   % assign models which use this
    mapAllStations(char(RAW(i,3))) = STATION;
end


end