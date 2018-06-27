function [INI] = A4_create_figures_exceedance( INI )

fprintf('\n--------------------------------------');
fprintf('\nBeginning A4_create_figures_exceedance    (%s)',datestr(now));
fprintf('\n--------------------------------------');

format compact;

FILEDATA = INI.FILESAVE_STAT;
fprintf('\n\n--Loading computed and observed data from file:\n\t %s', char(FILEDATA));
load(FILEDATA, '-mat');

KEYS = keys(MAP_ALL_DATA);
ind = ismember(INI.SELECTED_STATIONS,KEYS);
INI.SELECTED_STATIONS = INI.SELECTED_STATIONS(ind);
STATIONS_LIST = INI.SELECTED_STATIONS;

fprintf('\n\n--Plotting station exceedance:');


for M = STATIONS_LIST
    fprintf('\n\tplotting: %-25s', char(M));
    try
        STATION = MAP_ALL_DATA(char(M));  %get a tmp structure, modify values
        try
            plot_exceedance(STATION,INI);
        catch
            fprintf(' --> no mapped data or elevations');
        end
    catch
        fprintf(' --> cannot find in MAP_ALL_DATA container');
    end
    
end
fprintf('\n');

end

