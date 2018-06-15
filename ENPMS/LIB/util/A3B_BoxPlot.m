function INI = A3B_BoxPlot(INI)
% A3M_BoxPlotM(INI) Iterates over all stations and plots boxplots
%   Detailed explanation goes here

fprintf('\n----------------------');
fprintf('\nBeginning A3B_BoxPlot    (%s)',datestr(now));
fprintf('\n----------------------');

format compact;

FILEDATA = INI.FILESAVE_STAT;
fprintf('\n\n--Loading computed and observed data from file:\n\t %s', char(FILEDATA));
load(FILEDATA, '-mat');

KEYS = keys(MAP_ALL_DATA);
ind = ismember(INI.SELECTED_STATIONS,KEYS);
INI.SELECTED_STATIONS = INI.SELECTED_STATIONS(ind);
STATIONS_LIST = INI.SELECTED_STATIONS;

i = 0;
for M = STATIONS_LIST
    if isKey(MAP_ALL_DATA,char(M))
        fprintf('\n\tplotting station %s', char(M));
        try
            STATION = MAP_ALL_DATA(char(M));  %get a tmp structure, modify values
            i = i + 1;
            fprintf('...%d processing boxplots: %s\n', i, char(M));
            INI = boxplotMONTH(STATION,INI); %
            INI = boxplotYEAR(STATION,INI); %
        catch
            fprintf(' --> EXCEPTION: boxplot failed for station %s', char(M));
            msgException = getReport(INI,'extended','hyperlinks','on');
        end
    end
end

end


