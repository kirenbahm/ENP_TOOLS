function M_ALL = convert_map(INI, M_ALL, MM, i)

S = filesep; % file separator platform specific
C = strsplit(INI.MODEL_SIMULATION_SET{i},S); % get path names
INI.simMODEL =  char(C(end)); % use the last one for model name

for K = keys(MM)
    MT = MM(char(K));
    NAME = MT.NAME{1};
    T.STATION_NAME = [char(NAME)]; % = [char(NAME) char(id)];
    T.DATATYPE = MT.DFSTYPE;
    T.UNIT = MT.UNIT;
    T.X_UTM = NaN;
    T.Y_UTM = NaN;
    T.Z = NaN; % provide vector of T.Z including all cells used for transect
    T.I = NaN; % provide vector of T.I including all cells used for transect
    T.J = NaN; % provide vector of T.J including all cells used for transect
    T.M11CHAIN = '';
    T.N_AREA = 'TRANSECTS';
    T.I_AREA = 100;
    T.SZLAYER = NaN;
    T.OLLAYER = NaN;
    T.MODEL = INI.MODEL;
    T.NOTE = '';
    T.MSHEM11 ='TRANSECTS';
    T.ALTERNATIVE = INI.simMODEL;
    T.TIMEVECTOR = datenum(MT.TIMEVECTOR);
    T.DCOMPUTED = MT.TIMESERIES;
    M_ALL(char(K)) = T;
end
end

