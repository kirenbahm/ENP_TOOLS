function preproc_create_DFS0(INI,MAP_STATIONS,DATA,DFS0name,DType_Flag)

station_name = validatestring(char(DATA.STATION(1)),keys(MAP_STATIONS));  % validate DATA.STATION name with DFE stations within MAP_STATIONS container

% S = DATA.STATION(1);

NET.addAssembly('DHI.Generic.MikeZero.EUM');
NET.addAssembly('DHI.Generic.MikeZero.DFS');
HNET = NETaddDfsUtil();
eval('import DHI.Generic.MikeZero.DFS.*');
eval('import DHI.Generic.MikeZero.DFS.dfs123.*');
eval('import DHI.Generic.MikeZero.*');

% Flag specifying whether dfs0 file stores floats or doubles.
% MIKE Zero assumes floats, MIKE URBAN handles both.
useDouble = false;                                                         

% Flag specifying wether to use the MatlabDfsUtil for writing, or whehter
% to use the raw DFS API routines. The latter is VERY slow, but required in
% case the MatlabDfsUtil.XXXX.dll is not available.
useUtil = ~isempty(HNET);

if (useDouble)                                                             
    dfsDoubleOrFloat = DfsSimpleType.Double;
else
    dfsDoubleOrFloat = DfsSimpleType.Float;
end


if ~isempty(DATA.MEASUREMENTS)
    dfs0FileName = [char(DFS0name),'.dfs0'];
    if (exist(dfs0FileName,'file') && INI.DELETE_EXISTING_DFS0)
        delete(dfs0FileName)
    end
    
    utmXmeters = MAP_STATIONS(station_name).utmXmeters;
    utmYmeters = MAP_STATIONS(station_name).utmYmeters;
    elev_ngvd29_ft = MAP_STATIONS(station_name).ELEV_NGVD29_FT;
%     X = MAP_STATIONS(S{1}).X;
%     Y = MAP_STATIONS(S{1}).Y;
%     Z = MAP_STATIONS(S{1}).ELEVATION;    
    
%     if isnan(X), X=0;end
%     if isnan(Y), Y=0;end
%     if isnan(Z), Z=0;end
    
    TS = DATA.TIME;
    D = DATA.MEASUREMENTS;
    preproc_publish_DFS0(INI,utmXmeters,utmYmeters,elev_ngvd29_ft,station_name,TS,D,dfs0FileName,dfsDoubleOrFloat,DType_Flag);
    
end

end
