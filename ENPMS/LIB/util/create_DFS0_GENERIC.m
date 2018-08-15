function create_DFS0_GENERIC(INI,DFS0,FILE_NAME)
S = DFS0.STATION;

DATA.TIME = datenum(DFS0.DRED.HR_ARRAY);
if ~isempty(regexpi(DFS0.TYPE,'Rain')) || ~isempty(regexpi(DFS0.TYPE,'PET')) || ...
      ~isempty(regexpi(DFS0.TYPE,'ET'))
   DATA.V = DFS0.DRED.HR_SUM';
elseif ~isempty(regexpi(DFS0.TYPE,'Discharge'))
   DATA.V = DFS0.DRED.HR_WSUM';
elseif ~isempty(regexpi(DFS0.TYPE,'Stage')) || ~isempty(regexpi(DFS0.TYPE,'Salinity')) || ...
      ~isempty( regexpi(DFS0.TYPE,'Water Elevation'))
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
   T = DFS0.TYPE;
   U = DFS0.UNIT;
   TS = DATA.TIME;
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