function create_DFS0_GENERIC_HR(INI,DFS0,FILE_NAME)
S = DFS0.STATION;

DATA.TIME = datenum(DFS0.DRED.HR_ARRAY);

if ~isempty(regexpi(DFS0.TYPE,'Discharge')) || ~isempty( regexpi(DFS0.TYPE,'Water Level'))
   DATA.V = DFS0.DRED.HR_WAVE';
elseif ~isempty(regexpi(DFS0.TYPE,'Rain')) || ~isempty(regexpi(DFS0.TYPE,'PET')) || ...
      ~isempty(regexpi(DFS0.TYPE,'ET'))
   DATA.V = DFS0.DRED.HR_SUM';
elseif ~isempty(regexpi(DFS0.TYPE,'Stage')) || ~isempty(regexpi(DFS0.TYPE,'Salinity'))
   DATA.V = DFS0.DRED.HR_WAVE';
else
   DATA.V = DFS0.DRED.HR_WAVE;
end

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
   F = FILE_NAME;
   if (exist(F,'file') && INI.DELETE_EXISTING_DFS0), delete(F), end
   DT = DFS0.TYPE;
   TS = DATA.TIME;
   D = DATA.V;
   create1DFS0_G(INI,S,F,DT,TS,D,dfsDT);
end

end
