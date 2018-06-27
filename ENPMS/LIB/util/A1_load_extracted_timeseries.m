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


