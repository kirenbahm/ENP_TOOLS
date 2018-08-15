function INI = BC2D_read_shape(INI)

% read the station data from SFWMD and create a map 
[S] = shaperead(char(INI.SHPFILE1));
n = length(S);

for i = 1:n
    STATION.SITE = S(i).SITE;
    STATION.STATION = S(i).ST;
    STATION.X_UTM = S(i).X_UTM;
    STATION.Y_UTM = S(i).Y_UTM;
    STATION.Z = S(i).NGVD29;
    STATION.N_AREA = S(i).N_AREA;
    NAME = S(i).SITE;
    % mapping is by site name
    INI.MAP_STATIONS(char(NAME)) = STATION;
end


% read the station data from NPS and add to the existing map, overriding
% SFWMD data

[S] = shaperead(char(INI.SHPFILE2));
n = length(S);
M = INI.MAP_STATIONS;

for i = 1:n
    NAME = S(i).STATION;
    % update if the station exist, if not create new one
    if isKey(M,char(NAME)), STATION = M(char(NAME)); end
    
    STATION.SITE = S(i).STATION;
    STATION.STATION = S(i).STATION;
    STATION.X_UTM = S(i).X_UTM;
    STATION.Y_UTM = S(i).Y_UTM;
    STATION.Z = NaN;
    STATION.N_AREA = '';
    STATION.N = S(i).N;
    % mapping is by site name
    INI.MAP_STATIONS(char(NAME)) = STATION;
end

[S] = shaperead(char(INI.SHPFILE3));
n = length(S);
M = INI.MAP_STATIONS;
for i = 1:n
    NAME = S(i).STATION;
    % update if the station exist, if not create new one
    if isKey(M,char(NAME)), STATION = M(char(NAME)); end
    
    STATION.X_UTM = S(i).X_UTM;
    STATION.Y_UTM = S(i).Y_UTM;
    STATION.Z = S(i).ELEVATION;
    STATION.N_AREA = S(i).AREA;
    STATION.DATUM = S(i).DATUM;
    STATION.ELEVATION = S(i).ELEVATION;
    STATION.NAVD_CONV = S(i).NAVD_CONV;
    % mapping is by site name
    INI.MAP_STATIONS(char(NAME)) = STATION;
end

end