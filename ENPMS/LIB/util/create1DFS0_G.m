function create1DFS0_G(~,S,F,DT,TS,D,dfsDT)
% S - Station
% F - File name
% DT - Data Type
% TS - Timeseries vector
% D - Data vector
% dfsDT - Define Number Type Float or Double

NET.addAssembly('DHI.Generic.MikeZero.EUM');
NET.addAssembly('DHI.Generic.MikeZero.DFS');
HNET = NETaddDfsUtil();
eval('import DHI.Generic.MikeZero.DFS.*');
eval('import DHI.Generic.MikeZero.DFS.dfs123.*');
eval('import DHI.Generic.MikeZero.*');
%
%fprintf('\n       Creating file: ''%s''\n',F);
dfs0 = dfsTSO(char(F),1);
% Create an empty dfs1 file object
factory = DfsFactory();
builder = DfsBuilder.Create(char(S),'Matlab DFS',0);

T = datevec(TS(1));
builder.SetDataType(0);
builder.SetGeographicalProjection(factory.CreateProjectionGeoOrigin('UTM-17',12,54,2.6));
builder.SetTemporalAxis(factory.CreateTemporalNonEqCalendarAxis...
   (eumUnit.eumUsec,System.DateTime(T(1),T(2),T(3),T(4),T(5),T(6))));

% Add an item1.Set data to DFS0 file based on selected Datatype 'DT'
item1 = builder.CreateDynamicItemBuilder();
if strcmpi(DT,'Discharge')
    item1.Set(DT{1}, DHI.Generic.MikeZero.eumQuantity...
        (eumItem.eumIDischarge,eumUnit.eumUft3PerSec), dfsDT);
elseif strcmpi(DT,'Water Level')
    item1.Set(DT{1}, DHI.Generic.MikeZero.eumQuantity...
        (eumItem.eumIWaterLevel, eumUnit.eumUfeet), dfsDT);
end

%

item1.SetValueType(DataValueType.Instantaneous);
item1.SetAxis(factory.CreateAxisEqD0());
builder.AddDynamicItem(item1.GetDynamicItemInfo());

builder.CreateFile(F);

dfs = builder.GetFile();
% Add  data in the file

% Write to file using the MatlabDfsUtil
MatlabDfsUtil.DfsUtil.WriteDfs0DataDouble(dfs, NET.convertArray((TS-TS(1))*86400), ...
   NET.convertArray(D, 'System.Double', size(D,1), size(D,2)))


dfs.Close();

end