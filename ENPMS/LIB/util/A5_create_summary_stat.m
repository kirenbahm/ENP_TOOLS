function [ INI ] = A5_create_summary_stat( INI )

fprintf('\n---------------------------------');
fprintf('\nBeginning A5_create_summary_stat    (%s)',datestr(now));
fprintf('\n---------------------------------');

format compact;

FILEDATA = INI.FILESAVE_STAT;
fprintf('\n\n--Loading computed and observed data from file:\n\t %s', char(FILEDATA));
load(FILEDATA, '-mat');

n = length(INI.MODEL_ALL_RUNS);
F.TS_DESCRIPTION(1:n)= INI.MODEL_RUN_DESC(1:n);
F.TS_DESCRIPTION = strrep(F.TS_DESCRIPTION,'_','\_'); % if replace _ with \_ to for latex

%if INI.MAKE_STATISTICS_TABLE
fprintf('... Loading Computed and observed and stat data:\n\t %s', char(INI.FILESAVE_STAT));
load(INI.FILESAVE_STAT, '-mat');
KEYS = keys(MAP_ALL_DATA);
ind = ismember(INI.SELECTED_STATIONS,KEYS);
INI.SELECTED_STATIONS = INI.SELECTED_STATIONS(ind);
STATIONS_LIST = INI.SELECTED_STATIONS;

fprintf('\n\n--Creating summary stats:');

%----------------------------------------
%TODO;  replace F with INI
INI.MAP_STATION_STAT = get_map_station_stat(MAP_ALL_DATA,STATIONS_LIST); % stat for selected stations

uniq = unique (INI.SELECTED_STATIONS);
MAP_KEY = uniq;
for un = 1:length(uniq)
    a=1;
    %empty the cell array
    VALUE = {};
    for st = 1:length(STATIONS_LIST)
        if strcmp(STATIONS_LIST(st), uniq(un))
            VALUE(a) = STATIONS_LIST(st);
            a=a+1;
        end
    end
    MAP_VALUE{un} = VALUE;
end
MAP_STATION_ORDER = containers.Map(MAP_KEY, MAP_VALUE);
fprintf('\n');

end
