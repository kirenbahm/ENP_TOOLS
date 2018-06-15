function [INI] = A3_create_figures_timeseries( INI )

fprintf('\n--------------------------------------');
fprintf('\nBeginning A3_create_figures_timeseries    (%s)',datestr(now));
fprintf('\n--------------------------------------');

format compact;

FILEDATA = INI.FILESAVE_STAT;
fprintf('\n\n--Loading computed and observed data from file:\n\t %s', char(FILEDATA));
load(FILEDATA, '-mat');

KEYS = keys(MAP_ALL_DATA);
ind = ismember(INI.SELECTED_STATIONS,KEYS);
INI.SELECTED_STATIONS = INI.SELECTED_STATIONS(ind);
STATIONS_LIST = INI.SELECTED_STATIONS;

fprintf('\n\n--Plotting timeseries:');
i = 0;
for M = STATIONS_LIST
    %    pause(0.01)
    fprintf('\n\tplotting: %-25s', char(M));
    if isKey(MAP_ALL_DATA,char(M))
        try
            STATION = MAP_ALL_DATA(char(M));  %get a tmp structure, modify values
            i = i + 1;
            plot_timeseries(STATION,INI); % comment to plot only accumulated
        catch
            fprintf('\t---> Could not plot timeseries for station \"%s\"', char(M));
        end
    else
       fprintf('\t---> Could not find key for station \"%s\"', char(M));
    end
end

fprintf('\n');
end


