function create_DFS0_Q(INI,S,T,Q,DType_Flag)

%S = CURRENT_STATION;

NET.addAssembly('DHI.Generic.MikeZero.EUM');
NET.addAssembly('DHI.Generic.MikeZero.DFS');
HNET = NETaddDfsUtil();
eval('import DHI.Generic.MikeZero.DFS.*');
eval('import DHI.Generic.MikeZero.DFS.dfs123.*');
eval('import DHI.Generic.MikeZero.*');

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


if ~isempty(Q)
    S = strcat(S,'_Q');
    F = [INI.FLOW_DIR 'DFS0/',char(S),'.dfs0'];            % update with save location of DFS0 files
    if (exist(F,'file') && INI.DELETE_EXISTING_DFS0), delete(F), end
    TYPE = DType_Flag;                                                     % if this used? If so where?
%    U = 'feet^3/sec';                                                       % if this used? If so where?
    TS = T;
    D = Q;
    create1DFS0_Q(INI,S, TS, D, F, dfsDT,DType_Flag);
end


end
