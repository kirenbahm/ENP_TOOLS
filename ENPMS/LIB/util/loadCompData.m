function [StationsWithData, MapOfAllData] = loadCompData(INI);

% load all computed and observed
i = 0;
StationsWithData = '';

MapOfAllData = containers.Map();

% Iterate over model runs, loading data file for each one
for D = INI.MODEL_ALL_RUNS
    i = i + 1; % Increment model run counter
    MFILE = [INI.DATA_COMPUTED 'COMPUTED_' char(D) '.MATLAB'];
    fprintf('... Loading computed data from file:\n\t %s\n', char(MFILE));
%     if exist(MFILE,'file') == 2;
    load(char(MFILE), '-mat','mapCompSelected');
    % Save data in variable MapOfAllData with model run name as key
    MapOfAllData(char(D)) = mapCompSelected;
    % Append to list of stations we found data for
    StationsWithData = [StationsWithData mapCompSelected.keys];
end

% load observed (and add station names with observed data to station list)
i = i + 1;
FILE_OBSERVED = INI.FILE_OBSERVED;

fprintf('... Loading observed data from file:\n\t %s\n', char(INI.FILE_OBSERVED));

load(FILE_OBSERVED, '-mat','MAP_OBS');

MapOfAllData('Observed') =  MAP_OBS; % observed data 

% Append list of observed station names to STATION_NAMES variable
StationsWithData = [StationsWithData MAP_OBS.keys];

% Filter list of stations from all model runs (and observed) into
% just unique station name list
StationsWithData = unique(StationsWithData);

end

