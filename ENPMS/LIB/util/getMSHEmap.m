function mapMSHESEL = getMSHEmap(INI)

% This function copies the STATION metadata for JUST the MSHE stations into a
% separate variable

mapMSHESEL = containers.Map;

mapCompSelected = INI.mapCompSelected;
KEYS = mapCompSelected.keys;

for K = KEYS
    STATION = INI.mapCompSelected(char(K));
    MSHETYPE = STATION.MSHEM11;
    if strcmp(MSHETYPE,'M11'), continue, end
    ST_SHE.NAME = STATION.STATION_NAME;
    ST_SHE.X_UTM = STATION.X_UTM;
    ST_SHE.Y_UTM = STATION.Y_UTM;
    ST_SHE.i = STATION.I;
    ST_SHE.j = STATION.J;
    ST_SHE.Z = STATION.SZLAYER;
    mapMSHESEL(char(K)) = ST_SHE;
end

end

