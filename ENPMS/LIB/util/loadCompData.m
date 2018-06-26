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

