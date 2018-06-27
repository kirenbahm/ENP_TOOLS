function STATION = setStationData(INI, i, K, mapS, STATION)

% For a given station the functions iterates over vectors, merges vectors
% of time and data
STATION.DATA(i).TIMEVECTOR = []; % = mergeArraysByDate(i,STATION,T,D);
STATION.DATA(i).TIMESERIES = [];

iniT = datenum(INI.ANALYZE_DATE_I);
endT = datenum(INI.ANALYZE_DATE_F);

if isKey(mapS,char(K))
    S = mapS(char(K));
    
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

