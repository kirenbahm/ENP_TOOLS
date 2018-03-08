function [] = A3_create_figures_acc_timeseries( INI )

fprintf('\n-------------------------------------------');
fprintf('\nBeginning A3_create_figures_acc_timeseries    (%s)',datestr(now));
fprintf('\n-------------------------------------------');

format compact;

FILEDATA = INI.FILESAVE_STAT;
fprintf('\n\n--Loading computed and observed data from file:\n\t %s', char(FILEDATA));
load(FILEDATA, '-mat');

% only do the selected stations
% STATIONS_LIST = INI.SELECTED_STATIONS.list.stat;
STATIONS_LIST = INI.SELECTED_STATIONS;

fprintf('\n\n--Plotting accumulated station timeseries:');
i = 0;
for M = STATIONS_LIST
    %    pause(0.01)
    fprintf('\n\tplotting: %-25s', char(M));
    if isKey(MAP_ALL_DATA,char(M))
        try
            STATION = MAP_ALL_DATA(char(M));  %get a tmp structure, modify values
            i = i + 1;
            if strcmp(STATION.DFSTYPE,'Discharge') | ...
                    strcmp(STATION.DFSTYPE,'SZ flow') | ...
                    strcmp(STATION.DFSTYPE,'SZ exchange flow with river') | ...
                    strcmp(STATION.DFSTYPE,'groundwater flow in x-direction') | ...
                    strcmp(STATION.DFSTYPE,'groundwater flow in y-direction') | ...
                    strcmp(STATION.DFSTYPE,'groundwater flow in z-direction')
                %fprintf('... processing accumulated timeseries : %s\n',   char(M))
                plot_timeseries_accumulated(STATION,INI);
            else
              fprintf('\t---> datatype is not flow - skipping');
            end
        catch
            fprintf('\t---> Could not plot accumulated timeseries for station \"%s\"', char(M));
        end
    else
        fprintf('\t---> Could not find key for station \"%s\"', char(M));
    end
end
fprintf('\n');

end


