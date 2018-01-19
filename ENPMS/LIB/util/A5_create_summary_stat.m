function [ output_args ] = A5_create_summary_stat( INI )
%---------------------------------------------
%{
 FUNCTION DESCRIPTION:

BUGS:
COMMENTS:
----------------------------------------
REVISION HISTORY:

changes introduced to v2:  (rjf 12/2011)
-removed some commented code
-moved the load command for statistics .matlab file to inside
 if statement (strcmp(INI.MAKE_STATISTICS_TABLE,'YES')

changes introduced to v1:  (keb 8/2011)
 calls get_map_station_stat_v2 instead of v1
%}
%----------------------------------------
fprintf('\n\n Beginning A5_create_summary_stat: %s \n\n',datestr(now));
format compact;

%%% moved to below, in case stat .matlab file not generated
% % % FILEDATA = INI.FILESAVE_STAT;
% % % fprintf('... Loading Computed and observed and stat data:\n\t %s\n', char(FILEDATA));
% % % load(FILEDATA, '-mat');


%TODO;  replace F with INI
F.LATEX_DIR = INI.LATEX_DIR;
F.FIGURES_DIR = [INI.ANALYSIS_DIR_TAG '/figures'];
F.FIGURES_DIR = INI.FIGURES_DIR;
F.FIGURES_RELATIVE_DIR = INI.FIGURES_RELATIVE_DIR;

% only do the selected stations
% STATIONS_LIST = INI.SELECTED_STATIONS.list.stat;
STATIONS_LIST = INI.SELECTED_STATIONS;
%do it with the map
%keys(INI.SELECTED_STATIONS.MAP)

n = length(INI.MODEL_ALL_RUNS);
F.TS_DESCRIPTION(1:n)= INI.MODEL_RUN_DESC(1:n);
F.TS_DESCRIPTION = strrep(F.TS_DESCRIPTION,'_','\_'); % if replace _ with \_ to for latex

%if INI.MAKE_STATISTICS_TABLE
    fprintf('... Loading Computed and observed and stat data:\n\t %s\n', char(INI.FILESAVE_STAT));
    load(INI.FILESAVE_STAT, '-mat');
    MAP_STATION_STAT = get_map_station_stat(MAP_ALL_DATA,STATIONS_LIST); % stat for selected stations
%else
%    MAP_STATION_STAT = 0;
%end

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

% duplicate arg of INI will be used in future development. rjf
%generate_latex_filesV3(MAP_STATION_ORDER,MAP_STATION_STAT,INI,INI,F)
% change the page style
generate_latex_files(MAP_STATION_ORDER,MAP_STATION_STAT,INI);

end
