function A1_load_extracted_timeseries(INI)

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

fprintf('\n\n Beginning A1_load_extraced_timeseries(): %s \n\n',datestr(now));
format compact

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load the file with elevation data
% MAP_ELEVATIONS are stored in the .matlab file
% % fprintf('... Loading elevations:\n %s\n', char(INI.FILE_ELEVATION));
% % load(INI.FILE_ELEVATION,'-mat');

%load the file with observed data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Read all files as specified in MODEL_ALL_RUNS and make a structure
%for each station. The structures are stored in a map with station name as
%MAP KEY and computed+observed data as MAP VALUE. The structure is accessed
%by providing the key as a character string e.g. D = MAP_ALL_DATA('NP205')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Iterate over selected model runs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i = 0; % Initialize model run counter

MAP_ALL_DATA = containers.Map();

% load all computed and observed
i = 0;
KEYS = '';

for D = INI.MODEL_ALL_RUNS
    i = i + 1; % Increment model run counter
    MFILE = [INI.DATADIR 'COMPUTED_' char(D) '.MATLAB'];
    fprintf('... Loading computed data from file:\n\t %s\n', char(MFILE));
%     if exist(MFILE,'file') == 2;
    MAPS(i) = load(char(MFILE), '-mat','mapCompSelected');
%     else
%         fprintf('... Warning: File %s not found, skipping\n', char(MFILE));
%     end
    M = MAPS(i);
    KEYS = [KEYS M.mapCompSelected.keys];
end

% load observed
i = i + 1;
FILE_OBSERVED = INI.FILE_OBSERVED;
fprintf('... Loading observed data from file:\n\t %s\n', char(INI.FILE_OBSERVED));
load(FILE_OBSERVED, '-mat','MAP_OBS');
KEYS = [KEYS MAP_OBS.keys];
KEYS = unique(KEYS);

i = 0;
tStart = INI.ANALYZE_DATE_I;
tEnd = INI.ANALYZE_DATE_F;
nD = length(INI.MODEL_ALL_RUNS)+1;
TIMEVECTOR =  [datenum(tStart):1:datenum(tEnd)]';
TIMESERIES(1:1:length(TIMEVECTOR),1:1:nD) = NaN;

for D = INI.MODEL_ALL_RUNS
    i = i + 1; % Increment model run counter
    mapCompSelected = MAPS(i).mapCompSelected;
    for K = KEYS %{'G211_Q', 'TR_Q'}  %
        fprintf('... processing computed:%s, run:%s\n', char(K),char(D));
        
        if ~isKey(MAP_ALL_DATA,(char(K)))
            STATION = [];
            STATION.STATION_NAME = K;
            MAP_ALL_DATA(char(K)) = STATION;
        end

        if isKey(mapCompSelected,char(K))
            STATION = MAP_ALL_DATA(char(K));
            S = mapCompSelected(char(K));
            if isfield(STATION,'UNIT')
                STATION = MAP_ALL_DATA (char(K));
            else
                STATION.STATION_NAME = S.STATION_NAME;
                STATION.UNIT = S.UNIT;
                STATION.DATATYPE = S.DATATYPE;
                STATION.X_UTM = S.X_UTM;
                STATION.Y_UTM = S.Y_UTM;
                STATION.I = S.I;
                STATION.J = S.J;
                STATION.Z_GRID = NaN;
                STATION.Z_SURVEY = NaN;
                STATION.N_AREA = S.N_AREA;
                STATION.I_AREA = S.I_AREA;
                STATION.SZLAYER(i) = S.SZLAYER;
                STATION.OLLAYER(i) = S.OLLAYER;
                STATION.MODEL(i) = {S.MODEL};
            end
            if isfield(S,'DCOMPUTED')
                STATION.DATA(i).TIMESERIES = S.DCOMPUTED;
                STATION.DATA(i).TIMEVECTOR = S.TIMEVECTOR;
            else
                STATION.DATA(i).TIMESERIES = [];
                STATION.DATA(i).TIMEVECTOR = [];
            end
        end
        
        MAP_ALL_DATA (char(K)) = STATION;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% combine all above data arrays into one container, and trim or expand 
% dates to requested start-end times


i = length(INI.MODEL_ALL_RUNS) + 1;
for K = KEYS
    
    if isKey(MAP_ALL_DATA,char(K))
        STATION = MAP_ALL_DATA(char(K));
        try
            ST = MAP_OBS(char(K));
            STATION.Z_GRID = ST.Z_GRID; % assign from observed
            STATION.Z_SURVEY = ST.Z_SURVEY;
            STATION.DATA(i).TIMESERIES = ST.DOBSERVED;
            STATION.DATA(i).TIMEVECTOR = ST.TIMEVECTOR;
        catch
            STATION.DATA(i).TIMESERIES = [];
            STATION.DATA(i).TIMEVECTOR = [];
        end
    else
        fprintf('\n... Warning: %s in bserved not in computed, skipped \n', char(K));
    end
    
    MAP_ALL_DATA (char(K)) = STATION;


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save the structures which are subsequently used in other postprocessing
%scripts. The data are accessed using load(INI.FILESAVE_TS);

fprintf('\n... Completed A1_load_extracted_timeseries() \n');
fprintf('... Saving data file:\n\t %s\n', char(INI.FILESAVE_TS));
save(INI.FILESAVE_TS,'MAP_ALL_DATA', '-v7.3');

fclose('all');

%test code
try
    STATION = MAP_ALL_DATA (char(K));
    K = '3A28';
    STATION = MAP_ALL_DATA (char(K));
    K = 'G211_Q';
    STATION = MAP_ALL_DATA (char(K));
catch
end
end

