function STATION = initialize_STATION(K,KM)
 % this functon provides initialiazation of a station instance
 % it is a combination of MIKE SHE, MIKE 11 and Transect objects
    STATION.STATION_NAME = char(K);
    STATION.DATATYPE = '';
    STATION.UNIT = '';
    STATION.X_UTM = NaN;
    STATION.Y_UTM = NaN;
    STATION.Z = NaN;
    STATION.I = NaN;
    STATION.J = NaN;
    STATION.M11CHAIN = '';
    
    STATION.N_AREA = '';
    STATION.I_AREA = NaN;
    
    n = length(KM);
    STATION.SZLAYER(1:n) = NaN;
    STATION.OLLAYER(1:n) = NaN;
    
    STATION.MODEL = repmat({''},n,1);
    STATION.NOTE = repmat({''},n,1);
    STATION.ALTERNATIVE = repmat({''},n,1);
    
    STATION.TIMEVECTOR = [];
    STATION.TIMESERIES = double.empty(n,0);
    
%     STATION.MSHEM11 = '';
%     STATION.ALTERNATIVE = '';
%     M11NAME = '';
%     M11UNIT = '';
%     M11TYPE = '';
%     
%     STATION.MSHE_SZ_ELEV: [1x368 double]
%     STATION.MSHE_DATE: [1x368 double]
%     STATION.TIMEVECTOR: [368x1 double]
%     STATION.MSHE_UNIT_SZ_ELEV: 'm'
%     STATION.MSHE_TYPE_SZ_ELEV: 'Elevation'
%     STATION.DCOMPUTED: [368x1 double]
    
    STATION.Z_GRID = NaN;
    STATION.Z_SURVEY = NaN;
end
