function INI = A1_load_extracted_timeseries(INI)

%---------------------------------------------
% FUNCTION DESCRIPTION:
%
% This function reads MIKESHE and MIKE11 raw output files and saves
%   selected items into a .MATLAB file.
% The data is saved as 1-dimensional daily timeseries, and currently only
%   saves the last timestep of each day.
% Currently it can read all dfs0 files, and some dfs2 file.
% Can read dfs3 files but is HARDCODED to read only the FIRST LAYER.
% The data saved into the .MATLAB file is in  the form of a container,
%   called MAP_ALL_DATA, that uses the station names as keys.
% Data saved into the container for each station can be found in the
%   function called read_computed_timeseries.
% This function also will load the observed data (previously stored in amother
%   .MATLAB file) and save it with the modeled data.
%
% BUGS:
% COMMENTS:
%
%----------------------------------------
% REVISION HISTORY:
%
%----------------------------------------

fprintf('\n--------------------------------------');
fprintf('\nBeginning A1_load_extracted_timeseries    (%s)',datestr(now));
fprintf('\n--------------------------------------');
format compact

[KEYS, MAPS] = loadCompData(INI);
ind = ismember(INI.SELECTED_STATIONS,KEYS);
INI.SELECTED_STATIONS = INI.SELECTED_STATIONS(ind); % remove non-existing
ind = ismember(KEYS, INI.SELECTED_STATIONS);
KEYS = KEYS(ind); % use only selected stations

%load the file with observed data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Read all files as specified in MODEL_ALL_RUNS and make a structure
%for each station. The structures are stored in a map with station name as
%MAP KEY and computed+observed data as MAP VALUE. The structure is accessed
%by providing the key as a character string e.g. D = MAP_ALL_DATA('NP205')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Iterate over selected model runs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MAP_ALL_DATA = containers.Map();

for K = KEYS % {'T19'} %'G211_Q', 'TR_Q', {'S194_Q'}  % {'BRC_Q'} %KEYS % 
    fprintf('... processing computed:%s,\n', char(K));
    KM = keys(MAPS);
    STATION = initialize_STATION(K, KM);
    
    i = 0;
    for M = KM
        mapS = MAPS(char(M));
        i = i + 1;
        STATION = setStationInfo(i, K, mapS, STATION);
        STATION = setStationData(INI, i, K, mapS, STATION);
    end 
    
    TV = STATION.DATA.TIMEVECTOR;
    if any(TV)
        % assign only if there is one non-zero timevector
        MAP_ALL_DATA(char(K)) = STATION;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save the structures which are subsequently used in other postprocessing
%scripts. The data are accessed using load(INI.FILESAVE_TS);

fprintf('\n... Completed A1_load_extracted_timeseries() \n');
fprintf('... Saving data file:\n\t %s\n', char(INI.FILESAVE_TS));
save(INI.FILESAVE_TS,'MAP_ALL_DATA', '-v7.3');

fclose('all');

if INI.DEBUG
    %test code
    try
        STATION = MAP_ALL_DATA (char(K));
        K = 'S194_Q';
        STATION = MAP_ALL_DATA (char(K));
        K = 'A13';
        STATION = MAP_ALL_DATA (char(K));
    catch
    end
end

end


function STATION = setStationData(INI, i, K, mapS, STATION)

% For a given station the functions iterates over vectors, merges vectors
% of time and data
STATION.DATA(i).TIMEVECTOR = []; % = mergeArraysByDate(i,STATION,T,D);
STATION.DATA(i).TIMESERIES = [];

iniT = datenum(INI.ANALYZE_DATE_I);
endT = datenum(INI.ANALYZE_DATE_F);

if isKey(mapS,char(K))
    S = mapS(char(K));
    
    if isfield(S,'DCOMPUTED')
        T = S.TIMEVECTOR;
        D = S.DCOMPUTED;
        ind = find(T>= iniT & T<=endT); % limit data to begin and end period
        T = T(ind);
        D = D(ind); % erase data outside requested period
        STATION.DATA(i).TIMEVECTOR = T; % = mergeArraysByDate(i,STATION,T,D);
        STATION.DATA(i).TIMESERIES = D;
    end
    
    if isfield(S,'DOBSERVED')
        T = S.TIMEVECTOR;
        D = S.DOBSERVED;
        ind = find(T>= iniT & T<=endT); % limit data to begin and end period
        T = T(ind);
        D = D(ind); % erase data outside requested period
        STATION.DATA(i).TIMEVECTOR = T; % = mergeArraysByDate(i,STATION,T,D);
        STATION.DATA(i).TIMESERIES = D;
    end
end
end

function STATION = mergeArraysByDate(i,STATION,T,D)
% this function is not used, but can be used to merge tieseries with
% diferent timevectors
T0 = STATION.TIMEVECTOR;
Tnew = unique([T0; T]); % concatenate the timevectors and find the unique
STATION.TIMEVECTOR = Tnew; % Assign the new timevector

% merge timeseries
if i == 1
    STATION.TIMESERIES = D;
    return
end

D0 = STATION.TIMESERIES;
n = length(Tnew);
Dnew = NaN(n,i);
A(1:n) = NaN;

for ii = 1:i
    ind = ismember(Tnew,T0);
    if ii < i
        DD = D0(:,ii);
        Dnew(ind,ii) = DD;
    else 
    ind = ismember(Tnew,T);
        Dnew(ind,ii) = D;        
    end
end

STATION.TIMESERIES = Dnew; % Assign the new timeseries

end

function STATION = setStationInfo(i, K, mapS, STATION)

% For a given station the functions iterates over station information and
% sets one information

if isKey(mapS,char(K))
    S = mapS(char(K));
    %STATION.STATION_NAME = S.STATION_NAME;
    
    if strcmp(STATION.UNIT,'')
        if isfield(S,'UNIT')
            STATION.UNIT = S.UNIT;
        end
    end
    
    if strcmp(STATION.DATATYPE,'')
        if isfield(S,'DATATYPE')
            STATION.DATATYPE = S.DATATYPE;
        end
    end
    
    if isnan(STATION.X_UTM)
        if isfield(S,'X_UTM')
            STATION.X_UTM = S.X_UTM;
        end
    end
    
    if isnan(STATION.Y_UTM)
        if isfield(S,'Y_UTM')
            STATION.Y_UTM = S.Y_UTM;
        end
    end
    
    if isnan(STATION.I)
        if isfield(S,'I')
            STATION.I = S.I;
        end
    end
    
    if isnan(STATION.J)
        if isfield(S,'J')
            STATION.J = S.J;
        end
    end
    
    if isnan(STATION.Z)
        if isfield(S,'Z')
            STATION.Z = S.Z;
        end
    end
    
    if isnan(STATION.Z_GRID)
        if isfield(S,'Z_GRID')
            STATION.Z_GRID = NaN;
        end
    end
    
    if isnan(STATION.Z_SURVEY)
        if isfield(S,'Z_SURVEY')
            STATION.Z_SURVEY = NaN;
        end
    end
    
    if strcmp(STATION.N_AREA,'')
        if isfield(S,'N_AREA')
            STATION.N_AREA = S.N_AREA;
        end
    end
    
    if isnan(STATION.I_AREA)
        if isfield(S,'I_AREA')
            STATION.I_AREA = S.I_AREA;
        end
    end
    
    if isnan(STATION.SZLAYER(i))
        if isfield(S,'SZLAYER')
            STATION.SZLAYER(i) = S.SZLAYER;
        end
    end
    
    if isnan(STATION.OLLAYER(i))
        if isfield(S,'OLLAYER')
            STATION.OLLAYER(i) = S.OLLAYER;
        end
    end
    
    if strcmp(STATION.MODEL(i),'')
        if isfield(S,'MODEL')
            STATION.MODEL{i} = S.MODEL;
        end
    end
    
    if strcmp(STATION.NOTE(i),'')
        if isfield(S,'NOTE')
            STATION.NOTE{i} = S.NOTE;
        end
    end
    
    if strcmp(STATION.ALTERNATIVE(i),'')
        if isfield(S,'ALTERNATIVE')
            STATION.ALTERNATIVE{i} = S.ALTERNATIVE;
        end
    end
    
end
end

function [KEYS, MAPS_ALL] = loadCompData(INI);

% load all computed and observed
i = 0;
KEYS = '';

MAPS_ALL = containers.Map();

for D = INI.MODEL_ALL_RUNS
    i = i + 1; % Increment model run counter
    MFILE = [INI.DATA_COMPUTED 'COMPUTED_' char(D) '.MATLAB'];
    fprintf('... Loading computed data from file:\n\t %s\n', char(MFILE));
%     if exist(MFILE,'file') == 2;
    load(char(MFILE), '-mat','mapCompSelected');
    MAPS_ALL(char(D)) = mapCompSelected;
    KEYS = [KEYS mapCompSelected.keys];
end

% load observed
i = i + 1;
FILE_OBSERVED = INI.FILE_OBSERVED;

fprintf('... Loading observed data from file:\n\t %s\n', char(INI.FILE_OBSERVED));

load(FILE_OBSERVED, '-mat','MAP_OBS');

MAPS_ALL('Observed') =  MAP_OBS; % observed data 

KEYS = [KEYS MAP_OBS.keys];

KEYS = unique(KEYS);

end

function STATION = initialize_STATION(K,KM)
 % this functon provides initialiazation of a station instance
 % it is a combination of MIKE SHE, MIKE 11 and Transect objects
    STATION.STATION_NAME = char(K);
    STATION.DATATYPE = '';
    STATION.UNIT = '';
    STATION.X_UTM = NaN;
    STATION.Y_UTM = NaN;
    STATION.Z = NaN;
    STATION.I = NaN;
    STATION.J = NaN;
    STATION.M11CHAIN = '';
    
    STATION.N_AREA = '';
    STATION.I_AREA = NaN;
    
    n = length(KM);
    STATION.SZLAYER(1:n) = NaN;
    STATION.OLLAYER(1:n) = NaN;
    
    STATION.MODEL = repmat({''},n,1);
    STATION.NOTE = repmat({''},n,1);
    STATION.ALTERNATIVE = repmat({''},n,1);
    
    STATION.TIMEVECTOR = [];
    STATION.TIMESERIES = double.empty(n,0);
    
%     STATION.MSHEM11 = '';
%     STATION.ALTERNATIVE = '';
%     M11NAME = '';
%     M11UNIT = '';
%     M11TYPE = '';
%     
%     STATION.MSHE_SZ_ELEV: [1x368 double]
%     STATION.MSHE_DATE: [1x368 double]
%     STATION.TIMEVECTOR: [368x1 double]
%     STATION.MSHE_UNIT_SZ_ELEV: 'm'
%     STATION.MSHE_TYPE_SZ_ELEV: 'Elevation'
%     STATION.DCOMPUTED: [368x1 double]
    
    STATION.Z_GRID = NaN;
    STATION.Z_SURVEY = NaN;
end