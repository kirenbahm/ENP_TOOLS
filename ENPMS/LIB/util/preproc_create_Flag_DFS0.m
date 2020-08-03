function preproc_create_Flag_DFS0(INI,MAP_STATIONS,DATA,DFS0name,DType_Flag)
% This script takes data that was read and flagged from DFE .dat files 
% and prepares to write to a dfs0 file. 
%
% Inputs:
% INI stores global parameters like directories and flag checks.
%
% MAP_STATIONS holds data on all stations in database.
%
% DATA structure that contains Time Series information to write to dfs0 file.
%
% DFS0name full file path of dfs0 to write.
%
% DType_Flag is used to determine which DHI specific variables and settings
% are to be used in the creation of the DFS0 files. If additional datatypes
% are added (i.e. salinity, PET, ET, and/or etc...) accompanying elseif
% statements for U, itemDHI, and unitDHI must be included here.
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
    elev_ngvd29_ft = MAP_STATIONS(station_name).elev_ngvd29_ft;
%     X = MAP_STATIONS(S{1}).X;
%     Y = MAP_STATIONS(S{1}).Y;
%     Z = MAP_STATIONS(S{1}).ELEVATION;    
    
%     if isnan(X), X=0;end
%     if isnan(Y), Y=0;end
%     if isnan(Z), Z=0;end
    
    preproc_publish_Flag_DFS0(utmXmeters,utmYmeters,elev_ngvd29_ft,station_name,DATA.TIME,DATA.MEASUREMENTS,DATA.RAW,DATA.FLAG,dfs0FileName,dfsDoubleOrFloat,DType_Flag);
    
end

end
