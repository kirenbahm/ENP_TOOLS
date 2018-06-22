function INI = readFileCompCoord(INI)

% read the excel file to determine the computed coordinates and save in
% mapComputedDataCoord

INI.mapCompSelected = containers.Map;
[NUM,TXT,RAW] = xlsread(char(INI.fileCompCoord),char(INI.XLSCOMP));
fprintf('--- Reading file::%s with a list of stations to be extracted from raw data\n', char(INI.fileCompCoord));

for i = 2:length(RAW)
    try
        STATION_NAME = char(RAW(i,1));
        %fprintf('--- reading line %d::%s\n', i, char(STATION_NAME))
        stationComputed.STATION_NAME = STATION_NAME;
        stationComputed.DATATYPE = cell2mat(RAW(i,4));
        stationComputed.UNIT = char(RAW(i,5));
        stationComputed.X_UTM = cell2mat(RAW(i,6));
        stationComputed.Y_UTM = cell2mat(RAW(i,7));
        stationComputed.Z = cell2mat(RAW(i,8));
        stationComputed.I = cell2mat(RAW(i,15));
        stationComputed.J = cell2mat(RAW(i,16));
        stationComputed.M11CHAIN = '';
        stationComputed.N_AREA = char(TXT(i,18));
        stationComputed.I_AREA = cell2mat(RAW(i,19));
        stationComputed.SZLAYER = cell2mat(RAW(i,20));
        stationComputed.OLLAYER = cell2mat(RAW(i,21));
        stationComputed.MODEL = char(TXT(i,22));
        stationComputed.NOTE = '';
        if ~isempty(char(TXT(i,23)))
            stationComputed.NOTE = char(TXT(i,23));
        end

        if ~isempty(char(TXT(i,17)))
            stationComputed.MSHEM11 = 'M11';
            stationComputed.MODEL = INI.MODEL;
            stationComputed.ALTERNATIVE = INI.ALTERNATIVE;
            M11 = char(RAW(i,17));
            STR_TEMP = strsplit(M11,';');
            % convert the string to the format in dfs0 file.
            N = str2num(STR_TEMP{2});
            NSTR = sprintf('%.0f',N);
            M11CHAIN = [STR_TEMP{1} ';' NSTR ';' stationComputed.DATATYPE];
            M11CHAIN = strrep(M11CHAIN, ' ', '');
            stationComputed.M11CHAIN = M11CHAIN;
        else
            stationComputed.MSHEM11 = 'MSHE';
        end
        INI.mapCompSelected(char(STATION_NAME)) = stationComputed;
    catch
        fprintf('--- exception line in %d::%s\n', i, char(STATION_NAME));
    end
end

fprintf('--- Stations file::%s: has %i stations\n\n', char(INI.fileCompCoord), length(INI.mapCompSelected));

end
