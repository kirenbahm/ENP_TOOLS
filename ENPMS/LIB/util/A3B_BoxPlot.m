function A3B_BoxPlot(INI)
% A3M_BoxPlotM(INI) Iterates over all stations and plots boxplots
%   Detailed explanation goes here

fprintf('\n Beginning A3B_BoxPlot: %s \n',datestr(now));

FILEDATA = INI.FILESAVE_STAT;
fprintf('... Loading Computed and observed data:\n\t %s\n', char(FILEDATA));
load(FILEDATA, '-mat');

STATIONS_LIST = INI.SELECTED_STATIONS;

i = 0;
for M = STATIONS_LIST
    if isKey(MAP_ALL_DATA,char(M))
        fprintf('...%d processing boxplots: %s\n', i, char(M));
        try
            STATION = MAP_ALL_DATA(char(M));  %get a tmp structure, modify values
            i = i + 1;
            INI = boxplotMONTH(STATION,INI); % 
            INI = boxplotYEAR(STATION,INI); % 
        catch
            fprintf(' --> ...EXCEPTION: plot_timeseries(%s)\n', char(M));
            msgException = getReport(INI,'extended','hyperlinks','on');
        end
    end
end

end


