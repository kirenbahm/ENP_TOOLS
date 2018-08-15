function create_DFS0_Q_D02(INI, S, T, Q)

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
   F = ['./DFS0/',char(S),'.dfs0'];
   try
      if (exist(F,'file') && INI.DELETE_EXISTING_DFS0)
         delete(F);
      end
   catch
      fprintf('... Cant delete file: %s', char(F));
   end
   TYPE = 'Discharge';
   U = 'feet^3/sec';
   TS = T;
   D = Q;
   create1DFS0_Q(INI,S, TS, D, F, dfsDT);
end


end