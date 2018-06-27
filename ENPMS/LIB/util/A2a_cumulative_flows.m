function [ INI ] = A2a_cumulative_flows(INI)

fprintf('\n--------------------------------');
fprintf('\nBeginning A2a_cumulative_flows    (%s)',datestr(now));
fprintf('\n--------------------------------');
format compact

% load the file with elevation data
%fprintf('... Loading elevations:\n %s\n', char(INI.FILE_ELEVATION));
%rjf; not needed?
%%%load(INI.FILE_ELEVATION,'-mat');

%load the file with observed and computed data
%%%FILEDATA = [INI.ANALYSIS_DIR_TAG '/' INI.ANALYSIS_TAG '_TIMESERIES_DATA.MATLAB'];
FILEDATA = INI.FILESAVE_STAT;
fprintf('\n\n--Loading computed and observed data from file:\n\t %s', char(FILEDATA));
load(FILEDATA, '-mat');

%setup the file where data will be saved as a structure which can be loaded
%in MATLAB subsequently.
%%%FILESAVE = [INI.ANALYSIS_DIR_TAG '/' INI.ANALYSIS_TAG '_TIMESERIES_STAT.MATLAB'];
FILESAVE = INI.FILESAVE_STAT;
%fprintf('\n... Computed and observed stat data will be saved in file: %s\n', char(FILESAVE))


% to select a list of station either use the line below. For selected
% stations rerun the entire script sequence A0, A1,...

%if INI.USE_NEW_CODE
KEYS = keys(MAP_ALL_DATA);
ind = ismember(INI.SELECTED_STATIONS,KEYS);
INI.SELECTED_STATIONS = INI.SELECTED_STATIONS(ind);
STATIONS_LIST = INI.SELECTED_STATIONS;

i = 1;
% sumarize data and save in STATION structure
fprintf('\n\n--Summarizing data:');
for M = STATIONS_LIST
    try
        STATION = MAP_ALL_DATA(char(M));  %get a tmp structure, modify values
        STATION = summarize_YM(STATION,INI);
        MAP_ALL_DATA(char(M)) = STATION; % modify the map by adding STATION
    catch
        fprintf('\n\t Warning: Cannot find %s in MAP_ALL_DATA container', char(M));
    end
    i = i + 1;
end

write_QYM(MAP_ALL_DATA,INI,STATIONS_LIST);
write_QYMYEARLY(MAP_ALL_DATA,INI,STATIONS_LIST);

print_M_AVE(MAP_ALL_DATA,INI,STATIONS_LIST);
print_Y_AVE(MAP_ALL_DATA,INI,STATIONS_LIST);

fprintf('\n\n--Saving data in file:\n\t%s', char(FILESAVE))
save(FILESAVE,'MAP_ALL_DATA','-v7.3');
fprintf('\n\n');

end

