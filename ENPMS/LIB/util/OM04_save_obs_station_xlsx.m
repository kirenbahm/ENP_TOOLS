function OM04_save_obs_station_xlsx(MAP_OBS,INI)

T = {'Station', 'nTime', 'nData', 'Type', 'Unit','X_UTM', 'Y_UTM', 'Z',...
    'Z_GRID', 'Z_SURF', 'Z_SURVEY', 'T_START', 'T_END','MODEL', ...
    'I', 'J', 'M11_CHAIN','N_AREA','I_AREA','SZLAYER','OLLAYER','MODEL_DOM'};

KEYS = MAP_OBS.keys;
i = 0;
for K = KEYS
    i = i + 1;
    STATION = MAP_OBS(char(K));
    S{i} = STATION.STATION_NAME;    
    nt(i) = length(STATION.TIMEVECTOR);
    nv(i) = length(STATION.DOBSERVED);
    t{i} = STATION.DFSTYPE;
    u{i} = STATION.UNIT;
    x(i) = STATION.X_UTM;    
    y(i) = STATION.Y_UTM;    
    z(i) = STATION.Z;
    zg(i) = STATION.Z_GRID;
    zs(i) = STATION.Z_SURF;
    zsv(i) = STATION.Z_SURVEY;
    ts{i} = datestr(STATION.STARTDATE);
    te{i} = datestr(STATION.ENDDATE);
    tm{i} = STATION.DATATYPE;
    na{i} = STATION.N_AREA{:};
    ia(i) = STATION.I_AREA;
    szl(i) = STATION.SZLAYER;
    oll(i) = STATION.OLLAYER;
    mm{i} = INI.MODEL;
    m11{i} = '';
    ic(i) = 0;
    jc(i) = 0;   
end

TABLE_H = [T];
TABLE_D = [S', num2cell(nt'), num2cell(nv'), t', u', num2cell(x'),...
    num2cell(y'), num2cell(z'), num2cell(zg'), num2cell(zs'),...
    num2cell(zsv'), ts', te', tm', num2cell(ic'), num2cell(jc'), m11',...
    na',num2cell(ia'),num2cell(szl'),num2cell(oll'),mm'];
xlRange = 'A1';
xlswrite(char(INI.XLSX_STATIONS),TABLE_H,char(INI.SHEET_OBS),xlRange);
xlRange = 'A2';
xlswrite(char(INI.XLSX_STATIONS),TABLE_D,char(INI.SHEET_OBS),xlRange);

end