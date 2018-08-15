function MAP_H_DATA = BC2D_extractData2D(DATA_2D, MAP_H_DATA)

KEYS = MAP_H_DATA.keys;

for K = KEYS
    STATION =  MAP_H_DATA(char(K));
    I = STATION.I + 1;
    J = STATION.J + 1;
    STATION.DINTERP = squeeze(DATA_2D(I,J,:));
    MAP_H_DATA(char(K)) = STATION; 
end

end
