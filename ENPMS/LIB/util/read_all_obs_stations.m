function [ mapAllStations ] = read_all_obs_stations( INI, LISTINGS)

%   The function reads ALL_STATION_DATA sheet and creates a map, it also
%   reads the subdirectories with hourly data and compares if the dfs0
%   files are within the domain and ignores if not, it also erases stations
%   without data

mapAllStations = containers.Map;

%[~,~,RAW] = xlsread(INI.XLSX_STATIONS,INI.SHEET_OBS);
DELIM = '.';
num_stations = size(LISTINGS, 1);

for i = 1:num_stations
    myStation = LISTINGS(i);
    FILENAME = myStation.name;
    FOLDER   = myStation.folder;
    FILEPATH = [FOLDER '\' FILENAME];
    STR_TEMP = strsplit(FILENAME,DELIM);

%     % Search if there is a matching dfs0 of observed data
%     found = false;
%     k = 2;
%     nR = size(RAW,1);
%     while k <= nR && ~found
%         if strcmpi(STR_TEMP{1}, RAW(k,2)) && strcmpi(STR_TEMP{2}, RAW(k,3))
%             found = true;
%         else
%             k = k + 1;
%         end
%     end
%     
%     % If in domain, read and add to structure
%     if found
        
        % initialize some parts of STATION variable
        STATION.TIMEVECTOR = [];
        STATION.DOBSERVED  = [];
        STATION.DFSTYPE    = '';
        STATION.DATATYPE   = '';
        STATION.UNIT       = '';
        STATION.DATUM      = '';
        STATION.Z_GRID     = NaN;
        STATION.Z_SURF     = NaN;
        STATION.Z_SURVEY   = NaN;
        STATION.STARTDATE  = [];
        STATION.ENDDATE    = [];

        % Save station data from Excel sheet into STATION variable
        fprintf('\n... reading: %d/%d: %s \n', i, num_stations, char(FILEPATH));
        
%         STATION.STATION_NAME = RAW(k,1);
%         STATION.X_UTM = cell2mat(RAW(k,6));
%         STATION.Y_UTM = cell2mat(RAW(k,7));
%         if strcmp(RAW(k,8),' ')
%             STATION.Z = NaN;
%         else
%             STATION.Z = cell2mat(RAW(k,8));
%         end
%         STATION.NOTE      = RAW(k,14);
%         STATION.NAVD_CONV = cell2mat(RAW(k,15));
%         STATION.N_AREA    = RAW(k,18);
%         STATION.I_AREA    = cell2mat(RAW(k,19));
%         STATION.SZLAYER   = cell2mat(RAW(k,20));
%         STATION.OLLAYER   = cell2mat(RAW(k,21));
%         STATION.MODEL     = (RAW(k,22));
        
        % Read DFS0 data timeseries
        DFS0 = read_file_DFS0(FILEPATH);
        
        % Save timeseries data from DFS0 file into STATION variable
        STATION.STATION_NAME = DFS0.NAME;

        STATION.X_UTM = DFS0.utmXmeters;
        STATION.Y_UTM = DFS0.utmYmeters;
        STATION.Z     = DFS0.elev_ngvd29_ft;

        STATION.NOTE      = '';
        STATION.NAVD_CONV = NaN;
        STATION.N_AREA    = '';
        STATION.I_AREA    = '';
        STATION.SZLAYER   = NaN;
        STATION.OLLAYER   = NaN;
        STATION.MODEL     = '';

        STATION.TIMEVECTOR = DFS0.T;
        STATION.DOBSERVED  = DFS0.V;
        STATION.DFSTYPE    = DFS0.TYPE;
        STATION.UNIT       = DFS0.UNIT;
        STATION.STARTDATE  = DFS0.T(1);
        STATION.ENDDATE    = DFS0.T(end);

        %fprintf('%s,%d,%d,%d', STATION.STATION_NAME, STATION.X_UTM, STATION.Y_UTM, STATION.Z);

        % save STATION variable into map of all STATIONS
        mapAllStations(char(STATION.STATION_NAME)) = STATION;
%     else
%         fprintf('\n... %s.%s not in domain: %d/%d\n', STR_TEMP{1}, STR_TEMP{2}, i, num_stations);
%     end
end


end
