function OM05_saveDataDFS0(MAP_OBS,DIR_OBSERVED)
NET.addAssembly('DHI.Generic.MikeZero.EUM');
NET.addAssembly('DHI.Generic.MikeZero.DFS');
HNET = NETaddDfsUtil();
eval('import DHI.Generic.MikeZero.DFS.*');
eval('import DHI.Generic.MikeZero.DFS.dfs123.*');
eval('import DHI.Generic.MikeZero.*');
eval('import DHI.Generic.MikeZero.DFS.dfs0.*')
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
   
   fprintf('     Creating file: ''%s''\n',F);
   dfs0 = dfsTSO(char(F),1);
   % Create an empty dfs1 file object
   factory = DfsFactory();
   builder = DfsBuilder.Create(char(S),'Matlab DFS',0);
   
   T = datevec(TS(1));
   builder.SetDataType(0);
   builder.SetGeographicalProjection(factory.CreateProjectionGeoOrigin('UTM-17',12,54,2.6));
   builder.SetTemporalAxis(factory.CreateTemporalNonEqCalendarAxis...
      (eumUnit.eumUsec,System.DateTime(T(1),T(2),T(3),T(4),T(5),T(6))));
   
   % Add an Item
   item1 = builder.CreateDynamicItemBuilder();
   
   if strcmp(DATA.DFSTYPE,'Water Level')
      item1.Set(char(S), DHI.Generic.MikeZero.eumQuantity...
         (eumItem.eumIWaterLevel, eumUnit.eumUfeet), dfsDT);
   elseif strcmp(DATA.DFSTYPE, 'Discharge')
      item1.Set(char(S), DHI.Generic.MikeZero.eumQuantity...
         (eumItem.eumIDischarge, eumUnit.eumUft3PerSec), dfsDT);
   else
      fprintf('\nError in saveDataDFS0 - DATA.DFSTYPE not recognized\n');
   end
   
   item1.SetValueType(DataValueType.Instantaneous);
   item1.SetAxis(factory.CreateAxisEqD0());
   item1.SetReferenceCoordinates(X,Y,Z);
   builder.AddDynamicItem(item1.GetDynamicItemInfo());
   
   builder.CreateFile(F);
   
   dfs = builder.GetFile();
   % Add  data in the file
   % tic;
   % Write to file using the MatlabDfsUtil
   MatlabDfsUtil.DfsUtil.WriteDfs0DataDouble(dfs, NET.convertArray((TS-TS(1))*86400), ...
      NET.convertArray(D, 'System.Double', size(D,1), size(D,2)))
   % toc;
   
   dfs.Close();
   
   
   
end

end
