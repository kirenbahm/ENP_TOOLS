function [ mapAllStations ] = OM00_read_xlsx_all_stations( INI, LISTINGS)

%READ_XLSX_ALL_STATION() This function reads ALL_STATION_DATA Sheet
%   The function reads ALL_STATION_DATA sheet and creates a map, it also
%   reads the subdirectories with hourly data and compares if the dfs0
%   files are within the domain and ignores if not, it also erases stations
%   without data

mapAllStations = containers.Map;

[status,sheets,xlFormat] = xlsfinfo(INI.XLSX_STATIONS);
[NUM,TXT,RAW] = xlsread(INI.XLSX_STATIONS,INI.SHEET_OBS);
DATATYPE = 'M11';
DELIM = '.';
n = size(LISTINGS, 1);
% find columns with 'MODEL_*;
%index_MODEL = ~cellfun(@isempty,strfind(RAW(1,:),'MODEL_'));

for i = 1:n
    s = LISTINGS(i);
    FILENAME = s.name;
    FOLDER = s.folder;
    FILEPATH = [FOLDER '\' FILENAME];
    STR_TEMP = strsplit(FILENAME,DELIM);
    % Determine if stage or Flow
    % Search if there is a matching dfs0 of observed data
    found = false;
    k = 2;
    nR = size(RAW,1);
    while k <= nR && ~found
        if strcmpi(STR_TEMP{1}, RAW(k,2)) && strcmpi(STR_TEMP{2}, RAW(k,3))
            found = true;
        end
        k = k + 1;
    end
    % If in domain, read and add to structure
    if found
        
        fprintf('... reading: %d/%d: %s \n', i, n, char(FILEPATH));
        % XLS Data
        STATION.STATION_NAME = RAW(k,1);
        STATION.TIMEVECTOR = [];
        STATION.DOBSERVED = [];
        STATION.DFSTYPE = '';
        STATION.UNIT = '';
        STATION.DATUM = '';
        STATION.X_UTM = cell2mat(RAW(k,6));
        STATION.Y_UTM = cell2mat(RAW(k,7));
        STATION.NOTE = RAW(k,14);
        STATION.NAVD_CONV = cell2mat(RAW(k,15));
        if strcmp(RAW(k,8),' ')
            STATION.Z = NaN;
        else
            STATION.Z = cell2mat(RAW(k,8));
        end
        STATION.Z_GRID = NaN;
        STATION.Z_SURF = NaN;
        STATION.Z_SURVEY = NaN;
        STATION.STARTDATE = [];
        STATION.ENDDATE = [];
        STATION.DATATYPE = '';
        STATION.N_AREA = RAW(k,18);
        STATION.I_AREA = cell2mat(RAW(k,19));
        STATION.SZLAYER = cell2mat(RAW(k,20));
        STATION.OLLAYER = cell2mat(RAW(k,21));
        STATION.MODEL = (RAW(k,22));   % assign models which use this
        % DFS0 data
        DFS0 = read_file_DFS0(FILEPATH);
        
        % convert NAVD88 to NGVD29
        if strcmp(DFS0.UNIT,'ft')
            if isfield(STATION,'DATUM')
                if strcmp(STATION.DATUM,'NAVD88')
                    if isnumeric(STATION.NAVD_CONV)
                        DFS0.V = DFS0.V - STATION.NAVD_CONV;
                    else
                        fprintf('... WARNING: NO CONVERSION to NAVD88 %d/%d: %s \n', i, n, char(NAME));
                    end
                end
            end
        end
        
        STATION.TIMEVECTOR = DFS0.T;
        STATION.DOBSERVED = DFS0.V;
        STATION.DFSTYPE = DFS0.TYPE;
        STATION.UNIT = DFS0.UNIT;
        STATION.STARTDATE = DFS0.T(1);
        STATION.ENDDATE = DFS0.T(end);
        STATION.DATATYPE = DATATYPE;
        mapAllStations(char(RAW(k,1))) = STATION;
    else
        fprintf('\n... %s.%s not in domain: %d/%d\n', STR_TEMP{1}, STR_TEMP{2}, i, n);
    end
end


end