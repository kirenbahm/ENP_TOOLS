function MAP_OBS = OM03_createMapObs(DATA)
% This function takes all structures and creates a map of observed data by
% station name, which is used as the key for data acess
MAP_OBS = containers.Map;

for i = 1:length(DATA)
    STATION_NAME = DATA(i).STATION_NAME;
    MAP_OBS(char(STATION_NAME)) = DATA(i);    
end

end