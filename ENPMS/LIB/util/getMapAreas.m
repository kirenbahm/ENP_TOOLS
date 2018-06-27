function mapAreas = getMapAreas(MAP_ALL_DATA,MS)
% this function creates a map of subdomain areas : N_AREAS and lists 
% all stations within each subdomain area
mapAreas = containers.Map;

for K = MS.keys
    I_AREA = MAP_ALL_DATA(char(K)).I_AREA;
    N_AREA = MAP_ALL_DATA(char(K)).N_AREA;
    if isKey(mapAreas,N_AREA)
        V_STATIONS = mapAreas(char(N_AREA));
        V_STATIONS = [V_STATIONS K];
    else 
        V_STATIONS = K;
    end
        mapAreas(char(N_AREA)) = V_STATIONS;
end

end 