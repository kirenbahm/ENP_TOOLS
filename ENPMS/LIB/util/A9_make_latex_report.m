function [ INI ] = A9_make_latex_report( INI )
%---------------------------------------------
fprintf('\n--------------------------------');
fprintf('\nBeginning A9_make_latex_report    (%s)',datestr(now));
fprintf('\n--------------------------------');

format compact;

FILEDATA = INI.FILESAVE_STAT;
fprintf('\n\n--Loading computed and observed data from file:\n\t %s', char(FILEDATA));
load(FILEDATA, '-mat');

% create directory and copy needed files
if ~exist(INI.LATEX_DIR,'file'),  mkdir(INI.LATEX_DIR), end
copyfile([INI.SCRIPTDIR 'head.sty'], INI.LATEX_DIR );
copyfile([INI.SCRIPTDIR 'tail.sty'], INI.LATEX_DIR );

%n = length(INI.MODEL_ALL_RUNS);
%F.TS_DESCRIPTION(1:n)= INI.MODEL_RUN_DESC(1:n);
F.TS_DESCRIPTION = strrep(INI.MODEL_RUN_DESC,'_','\_'); % if replace _ with \_ to for latex

KEYS = keys(MAP_ALL_DATA);
ind = ismember(INI.SELECTED_STATIONS,KEYS);
INI.SELECTED_STATIONS = INI.SELECTED_STATIONS(ind);
STATIONS_LIST = INI.SELECTED_STATIONS;

fprintf('\n\n--Creating summary stats:');
MAP_STATION_STAT = get_map_station_stat(MAP_ALL_DATA,STATIONS_LIST); % stat for selected stations

uniq = unique (INI.SELECTED_STATIONS);
MAP_KEY = uniq;

for un = 1:length(uniq)
    a=1;
    VALUE = {};  %empty the cell array
    for st = 1:length(INI.SELECTED_STATIONS)
        if strcmp(INI.SELECTED_STATIONS(st), uniq(un))
            VALUE(a) = INI.SELECTED_STATIONS(st);
            a=a+1;
        end
    end
    MAP_VALUE{un} = VALUE;
end
MAP_STATION_ORDER = containers.Map(MAP_KEY, MAP_VALUE);

if INI.LATEX_REPORT_BY_AREA
    generate_latex_files_by_area(MAP_STATION_ORDER,MAP_STATION_STAT,INI);
else
    generate_latex_files(MAP_STATION_ORDER,INI.MAP_STATION_STAT,INI);
end
fprintf('\n');

end
