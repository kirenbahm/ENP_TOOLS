function create_DFS0_GENERIC_H(INI,DATA,DFS0N)
S = DATA.STATION(1);

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


if ~isempty(DATA.V)
   S = strcat(S,'_Q');
   F = [char(DFS0N),'.dfs0'];
   if (exist(F,'file') && INI.DELETE_EXISTING_DFS0), delete(F), end
   T = 'Discharge';
   U = 'feet^3/sec';
   TS = DATA.T;
   D = DATA.V;
   create1DFS0_G(INI,S, TS, D, F, dfsDT);
end
% if ~isempty(H.H_V)
%     S = strcat(S,'_H');
%     F = ['./',char(S),'.dfs0'];
%     if (exist(F,'file') & INI.DELETE_EXISTING_DFS0), delete(F), end;
%     T = 'Water Level';
%     U = 'ft';
%     TS = H.H_TIME;
%     D = H.H_V;
%     create1DFS0_H(INI,S, TS, D, F, dfsDT);
% end

end
