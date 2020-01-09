function STATION = setStationData(INI, i, MY_STN, MapOfOneAltData, STATION)

% For a given station the functions iterates over vectors, merges vectors
% of time and data
STATION.DATA(i).TIMEVECTOR = []; % = mergeArraysByDate(i,STATION,T,D);
STATION.DATA(i).TIMESERIES = [];

iniT = datenum(INI.ANALYZE_DATE_I);
endT = datenum(INI.ANALYZE_DATE_F);

if isKey(MapOfOneAltData,char(MY_STN))
    S = MapOfOneAltData(char(MY_STN));
    
    if isfield(S,'DCOMPUTED')
        T = S.TIMEVECTOR;
        D = S.DCOMPUTED;
        ind = find(T>= iniT & T<=endT); % limit data to begin and end period
        T = T(ind);
        D = D(ind); % erase data outside requested period
        STATION.DATA(i).TIMEVECTOR = T; % = mergeArraysByDate(i,STATION,T,D);
        STATION.DATA(i).TIMESERIES = D;
    end
    
    if isfield(S,'DOBSERVED')
        T = S.TIMEVECTOR;
        D = S.DOBSERVED;
        ind = find(T>= iniT & T<=endT); % limit data to begin and end period
        T = T(ind);
        D = D(ind); % erase data outside requested period
        STATION.DATA(i).TIMEVECTOR = T; % = mergeArraysByDate(i,STATION,T,D);
        STATION.DATA(i).TIMESERIES = D;
    end
end
end

