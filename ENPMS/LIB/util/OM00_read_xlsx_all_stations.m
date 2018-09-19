function [ mapAllStations ] = OM00_read_xlsx_all_stations( INI)

%READ_XLSX_ALL_STATION() This function reads ALL_STATION_DATA Sheet
%   The function reads ALL_STATION_DATA sheet and creates a map, it also
%   reads the subdirectories with hourly data and compares if the dfs0
%   files are within the domain and ignores if not, it also erases stations
%   without data

mapAllStations = containers.Map;

[status,sheets,xlFormat] = xlsfinfo(INI.XLSX_STATIONS);
[NUM,TXT,RAW] = xlsread(INI.XLSX_STATIONS,INI.SHEET_ALL);

% find columns with 'MODEL_*;
index_MODEL = ~cellfun(@isempty,strfind(RAW(1,:),'MODEL_'));

for i = 2:length(RAW)
    STATION.STATION_NAME = RAW(i,3);    
    STATION.TIMEVECTOR = [];
    STATION.DOBSERVED = [];
    STATION.DFSTYPE = '';
    STATION.UNIT = '';
    STATION.DATUM = RAW(i,10);
    STATION.X_UTM = cell2mat(RAW(i,11));    
    STATION.Y_UTM = cell2mat(RAW(i,12));   
    STATION.NOTE = RAW(i,14);
    STATION.NAVD_CONV = cell2mat(RAW(i,15));
    if strcmp(RAW(i,7),' ')
        STATION.Z = NaN;
    else
        STATION.Z = cell2mat(RAW(i,7));
    end
    STATION.Z_GRID = NaN;
    STATION.Z_SURF = NaN;
    STATION.Z_SURVEY = NaN;
    STATION.STARTDATE = [];
    STATION.ENDDATE = [];
    STATION.DATATYPE = '';
    STATION.N_AREA = RAW(i,17); 
    STATION.I_AREA = cell2mat(RAW(i,18));  
    STATION.SZLAYER = cell2mat(RAW(i,19));   
    STATION.OLLAYER = cell2mat(RAW(i,20)); 
    STATION.MODEL = (RAW(i,index_MODEL));   % assign models which use this
    mapAllStations(char(RAW(i,3))) = STATION;
end


end