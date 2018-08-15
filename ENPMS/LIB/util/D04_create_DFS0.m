function D04_create_DFS0(INI,DATA,DFS0N,DType_Flag)

S = DATA.STATION(1);

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
    dfsDT = DfsSimpleType.Double;
else
    dfsDT = DfsSimpleType.Float;
end


if ~isempty(DATA.V)
    F = [char(DFS0N),'.dfs0'];
    if (exist(F,'file') && INI.DELETE_EXISTING_DFS0)
        delete(F)
    end
    TS = DATA.TIME;
    D = DATA.V;
    D05_publish_DFS0(INI,S,TS,D,F,dfsDT,DType_Flag);
end

end
