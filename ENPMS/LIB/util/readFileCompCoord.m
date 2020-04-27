function INI = readFileCompCoord(INI)

% read the excel file to determine the computed coordinates and save in
% mapComputedDataCoord

% Create empty container
INI.mapCompSelected = containers.Map;
dfs2Codes = readDomainGridCodes(INI.DomainDfs2);

% Read Excel spreadsheet into generic data arrays
[NUM,TXT,RAW] = xlsread(char(INI.fileCompCoord),char(INI.XLSCOMP));
fprintf('--- Reading file::%s with a list of stations to be extracted from raw data\n', char(INI.fileCompCoord));

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
        if(dfs2Codes.saxis.X0 ~= 0 && dfs2Codes.saxis.Y0 ~= 0)
          % check of station indexes
          i1= (stationComputed.X_UTM-dfs2Codes.saxis.X0)/dfs2Codes.saxis.Dx; % Converting to index
          j1= (stationComputed.Y_UTM-dfs2Codes.saxis.Y0)/dfs2Codes.saxis.Dy; % Converting to index
          if(abs(i1 - stationComputed.I) > 0.5 || abs(j1 - stationComputed.J) > 0.5)
            fprintf('--- Warning: Station %s at excel row %i with a coordinate indexes of (%i , %i) is estimated as (%i , %i) based on model domain dfs2\n',...
            char(stationComputed.STATION_NAME), i, stationComputed.I, stationComputed.J, i1, j1);
            %stationComputed.I = i1;  
            %stationComputed.J = j1;
          end
        end
        % Here we are only accepting cells of GridCode value 1, change last condition to == 0 to accept border as well
        if((stationComputed.I + 1 > dfs2Codes.Cols || stationComputed.I + 1 <= 0) || (stationComputed.J + 1 > dfs2Codes.Rows || stationComputed.J + 1 <= 0)...
         || dfs2Codes.V(stationComputed.J + 1, stationComputed.I + 1) ~= 1)
         stationComputed.I = 0;
         stationComputed.J = 0;
        end
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
