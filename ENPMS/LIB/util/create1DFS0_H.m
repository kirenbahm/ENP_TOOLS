function create1DFS0_H(~,S,TS,D,F,dfsDT)
% S - Station
% TS - Timeseries vector
% D - Data vector
% F - File name
% dfsDT
NET.addAssembly('DHI.Generic.MikeZero.EUM');
NET.addAssembly('DHI.Generic.MikeZero.DFS');
H = NETaddDfsUtil();
eval('import DHI.Generic.MikeZero.DFS.*');
eval('import DHI.Generic.MikeZero.DFS.dfs123.*');
eval('import DHI.Generic.MikeZero.*');
%
fprintf('\n       Creating file: ''%s''\n',F);
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
item1.Set('Water Level', DHI.Generic.MikeZero.eumQuantity...
    (eumItem.eumIWaterLevel, eumUnit.eumUfeet), dfsDT);
item1.SetValueType(DataValueType.Instantaneous);
item1.SetAxis(factory.CreateAxisEqD0());
builder.AddDynamicItem(item1.GetDynamicItemInfo());

builder.CreateFile(F);

dfs = builder.GetFile();
% Add  data in the file
tic
% Write to file using the MatlabDfsUtil
MatlabDfsUtil.DfsUtil.WriteDfs0DataDouble(dfs, NET.convertArray((TS-TS(1))*86400), ...
    NET.convertArray(D, 'System.Double', size(D,1), size(D,2)))
toc

dfs.Close();

end