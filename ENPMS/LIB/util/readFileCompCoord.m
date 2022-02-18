function INI = readFileCompCoord(INI)

% read the excel file to determine the computed coordinates and save in mapComputedDataCoord

% Create empty container
INI.mapCompSelected = containers.Map;

% Read Excel spreadsheet into generic data arrays
[~,~,RAW] = xlsread(char(INI.fileCompCoord),char(INI.XLSCOMP));
fprintf('\n\n--- Reading file::%s with a list of stations to be extracted from raw data\n', char(INI.fileCompCoord));

% Get map of active grid cells (to screen out stations outside domain)
activeCellCodes = readDomainGridCodes(INI.filePP);

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
        
        % read cell coordinates, and if inactive cell, change row&col to 0
        stationComputed.I = cell2mat(RAW(i,15));
        stationComputed.J = cell2mat(RAW(i,16));
        if( strcmp(cell2mat(RAW(i,14)),'MSHE'))
            if(activeCellCodes.saxis.X0 ~= 0 && activeCellCodes.saxis.Y0 ~= 0 )
                % check of station indexes
                i1= (stationComputed.X_UTM-activeCellCodes.saxis.X0)/activeCellCodes.saxis.Dx - 0.5; % Converting to index
                j1= (stationComputed.Y_UTM-activeCellCodes.saxis.Y0)/activeCellCodes.saxis.Dy - 0.5; % Converting to index
                if(abs(i1 - stationComputed.I) > 0.5 || abs(j1 - stationComputed.J) > 0.5)
                    fprintf('--- Warning: Station %s at excel row %i with a coordinate indexes of (%i , %i) is estimated as (%i , %i) based on model domain dfs2\n',...
                        char(stationComputed.STATION_NAME), i, stationComputed.I, stationComputed.J, round(i1), round(j1));
                    %stationComputed.I = i1;
                    %stationComputed.J = j1;
                end
            end
            % Here we are only accepting cells of GridCode value 1, change last condition to == 0 to accept border as well
            if((stationComputed.I + 1 > activeCellCodes.Cols || stationComputed.I + 1 <= 0) ||...
                    (stationComputed.J + 1 > activeCellCodes.Rows || stationComputed.J + 1 <= 0) ||...
                    activeCellCodes.V(stationComputed.J + 1, stationComputed.I + 1)...
                    ~= 1)
                stationComputed.I = 0;
                stationComputed.J = 0;
            end
        end
        
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
        if strcmp(cell2mat(RAW(i,14)),'M11')
            stationComputed.MSHEM11 = 'M11';
            stationComputed.MODEL = INI.MODEL;
            stationComputed.ALTERNATIVE = INI.ALTERNATIVE;
            % still check if chainages has numbers
            if ~isnan(RAW{i,INI.M11_CHAINAGES_COLUMN})
                % try block to catch any parsing errors
                % failed parses keep stationComputed.M11CHAIN = ''
                try
                    M11 = char(RAW{i,INI.M11_CHAINAGES_COLUMN});
                    STR_TEMP = strsplit(M11,';');
                    % convert the string to the format in dfs0 file.
                    N = str2num(STR_TEMP{2});
                    NSTR = sprintf('%.0f',N);
                    M11CHAIN = [STR_TEMP{1} ';' NSTR ';' stationComputed.DATATYPE];
                    M11CHAIN = strrep(M11CHAIN, ' ', '');
                    stationComputed.M11CHAIN = M11CHAIN;
                catch % warn user if chainage didn't parse correctly
                    fprintf('--- Warning! Station: %s could not parse chainage\n', char(STATION_NAME));
                end
            end
        elseif strcmp(cell2mat(RAW(i,14)),'MSHE')
            stationComputed.MSHEM11 = 'MSHE';
        else % Warn user if type model isn't M11 or MSHE
            fprintf('--- Warning! Station: %s not MSHE or M11\n', char(STATION_NAME));
        end
        INI.mapCompSelected(char(STATION_NAME)) = stationComputed;
    catch
        fprintf('--- exception line in %d::%s\n', i, char(STATION_NAME));
    end
end

%fprintf('--- Stations file: %s: has %i stations\n\n', char(INI.fileCompCoord), length(INI.mapCompSelected));
fprintf('      done' );

end
