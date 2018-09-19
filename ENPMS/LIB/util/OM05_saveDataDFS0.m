function OM05_saveDataDFS0(MAP_OBS,INI)
NET.addAssembly('DHI.Generic.MikeZero.EUM');
NET.addAssembly('DHI.Generic.MikeZero.DFS');
HNET = NETaddDfsUtil();
eval('import DHI.Generic.MikeZero.DFS.*');
eval('import DHI.Generic.MikeZero.DFS.dfs123.*');
eval('import DHI.Generic.MikeZero.*');
eval('import DHI.Generic.MikeZero.DFS.dfs0.*')
useDouble = false;

DIR_OBSERVED = './OBSERVED/';

% Flag specifying wether to use the MatlabDfsUtil for writing, or whehter
% to use the raw DFS API routines. The latter is VERY slow, but required in
% case the MatlabDfsUtil.XXXX.dll is not available.
useUtil = ~isempty(HNET);

if (useDouble)
    dfsDT = DfsSimpleType.Double;
else
    dfsDT = DfsSimpleType.Float;
end

for K  = MAP_OBS.keys

    FILE_SAVE = strcat(DIR_OBSERVED, K, '.dfs0');
    % This erases if there is existing dfs0 file in ./OBSERVED
    if exist(char(FILE_SAVE), 'file')==2
        delete(char(FILE_SAVE));
    end
    
    DATA = MAP_OBS(char(K));
    S = DATA.STATION_NAME;
    TS = DATA.TIMEVECTOR;
    D = DATA.DOBSERVED;
    F = char(FILE_SAVE);
    
    X = DATA.X_UTM;
    Y = DATA.Y_UTM;
    Z = DATA.Z;
    
    if isnan(X), X=0;end
    if isnan(Y), Y=0;end
    if isnan(Z), Z=0;end
    
    if strcmp(DATA.DFSTYPE,'Water Level')
        OM06_create1DFS0_H(INI,S, TS, D, F, dfsDT, X, Y, Z);
    end
    
    if strcmp(DATA.DFSTYPE, 'Discharge')
        OM07_create1DFS0_G_Q(INI,S, TS, D, F, dfsDT, X, Y, Z);
    end
    
end

end
