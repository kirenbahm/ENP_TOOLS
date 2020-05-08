function INI = readFileCompCoord(INI)

% read the excel file to determine the computed coordinates and save in mapComputedDataCoord

% Create empty container
INI.mapCompSelected = containers.Map;

% Read Excel spreadsheet into generic data arrays
[~,~,RAW] = xlsread(char(INI.fileCompCoord),char(INI.XLSCOMP));
fprintf('--- Reading station metadata file: %s\n', char(INI.fileCompCoord));

% Iterate through data array rows and copy the station data into structures (skipping header row)
[numRows,~]=size(RAW); 
for i = 2:numRows % each row has data for a different station
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
        stationComputed.N_AREA = char(RAW(i,18));
        stationComputed.I_AREA = cell2mat(RAW(i,19));
        stationComputed.SZLAYER = cell2mat(RAW(i,20));
        stationComputed.OLLAYER = cell2mat(RAW(i,21));
        stationComputed.MODEL = char(RAW(i,22));
        stationComputed.NOTE = '';
         if ~isempty(char(RAW{i,23}))
             stationComputed.NOTE = char(RAW{i,23});
         end
        if ~isnan(RAW{i,INI.M11_CHAINAGES_COLUMN})
            stationComputed.MSHEM11 = 'M11';
            stationComputed.MODEL = INI.MODEL;
            stationComputed.ALTERNATIVE = INI.ALTERNATIVE;
            M11 = char(RAW{i,INI.M11_CHAINAGES_COLUMN});
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

%fprintf('--- Stations file: %s: has %i stations\n\n', char(INI.fileCompCoord), length(INI.mapCompSelected));
fprintf('      done' );

end
