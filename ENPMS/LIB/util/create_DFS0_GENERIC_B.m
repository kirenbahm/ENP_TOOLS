function create_DFS0_GENERIC_B(INI,DATA,DFS0N,DType_Flag,itemDHI,unitDHI)

S = DATA.STATION(1);

NET.addAssembly('DHI.Generic.MikeZero.EUM');
NET.addAssembly('DHI.Generic.MikeZero.DFS');
HNET = NETaddDfsUtil();
eval('import DHI.Generic.MikeZero.DFS.*');
eval('import DHI.Generic.MikeZero.DFS.dfs123.*');
eval('import DHI.Generic.MikeZero.*');

useDouble = false;                                                          % Is this necessary? Hardcoded true/false with no switch.

% Flag specifying wether to use the MatlabDfsUtil for writing, or whehter
% to use the raw DFS API routines. The latter is VERY slow, but required in
% case the MatlabDfsUtil.XXXX.dll is not available.
useUtil = ~isempty(HNET);

if (useDouble)                                                              % If/then to hardcoded variable. Why?
    dfsDT = DfsSimpleType.Double;
else
    dfsDT = DfsSimpleType.Float;
end


if ~isempty(DATA.V)
    S = strcat(S,'_Q');
    F = [char(DFS0N),'.dfs0'];
    if (exist(F,'file') && INI.DELETE_EXISTING_DFS0), delete(F), end
%    T = DType_Flag;     % This variable may not be used in this or any other function/script beyond the fprintf two lines below. Consider removing (confirm with Georgio).
%    U = 'feet^3/sec';    % This variable may not be used in this or any other function/script beyond the fprintf two lines below. Consider removing (confirm with Georgio).
%    fprintf('Variable(s) T and U may be unused and are hardcoded to = %s and %s respectively.\n', T, U)
    TS = DATA.TIME;
    D = DATA.V;
    create1DFS0(INI,S,TS,D,F,dfsDT,DType_Flag,itemDHI,unitDHI);
end

end
