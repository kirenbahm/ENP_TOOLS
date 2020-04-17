function preproc_publish_DFS0(utmXmeters,utmYmeters,elev_ngvd29_ft,station_name,time_vector,measurements,dfs0FileName,dfsDoubleOrFloat,DType_Flag)

%%% HARDCODED TO UNITS OF cfs, ft, and UTM-17 %%%
%%% HARDCODED TO UNITS OF cfs, ft, and UTM-17 %%%
%%% HARDCODED TO UNITS OF cfs, ft, and UTM-17 %%%

NET.addAssembly('DHI.Generic.MikeZero.EUM');
NET.addAssembly('DHI.Generic.MikeZero.DFS');
H = NETaddDfsUtil();
eval('import DHI.Generic.MikeZero.DFS.*');
eval('import DHI.Generic.MikeZero.DFS.dfs123.*');
eval('import DHI.Generic.MikeZero.*');
%
%fprintf('\n       Creating file: ''%s''\n',F);
%dfs0 = dfsTSO(char(F),1);                                                   
% Create an empty dfs1 file object
factory = DfsFactory();
builder = DfsBuilder.Create(char(station_name),'Matlab DFS',0);

T = datevec(time_vector(1));
builder.SetDataType(0);
builder.SetGeographicalProjection(factory.CreateProjectionGeoOrigin('UTM-17',12,54,2.6));
builder.SetTemporalAxis(factory.CreateTemporalNonEqCalendarAxis...
    (eumUnit.eumUsec,System.DateTime(T(1),T(2),T(3),T(4),T(5),T(6))));

% Add an Item
item1 = builder.CreateDynamicItemBuilder();

% if statement that translates the Data Type Flag 'DType_Flag' into the
% appropriate DHI required inputs for DFS0 creation. This will ned to be
% expanded upon as new datatypes and DType_Flags are added.
if strcmpi(DType_Flag,'Discharge')
   myStationName = char([station_name '_Q']);
    item1.Set(myStationName, DHI.Generic.MikeZero.eumQuantity...
        (eumItem.eumIDischarge,eumUnit.eumUft3PerSec), dfsDoubleOrFloat);
elseif strcmpi(DType_Flag,'Water Level')
   myStationName = char([station_name]);
    item1.Set(myStationName, DHI.Generic.MikeZero.eumQuantity...
        (eumItem.eumIWaterLevel, eumUnit.eumUfeet), dfsDoubleOrFloat);
end
item1.SetValueType(DataValueType.Instantaneous);
item1.SetAxis(factory.CreateAxisEqD0());
item1.SetReferenceCoordinates(utmXmeters,utmYmeters,elev_ngvd29_ft);
builder.AddDynamicItem(item1.GetDynamicItemInfo());

builder.CreateFile(dfs0FileName);

dfs = builder.GetFile();
% Add  data in the file
tic
% Write to file using the MatlabDfsUtil
MatlabDfsUtil.DfsUtil.WriteDfs0DataDouble(dfs, NET.convertArray((time_vector-time_vector(1))*86400), ...
    NET.convertArray(measurements, 'System.Double', size(measurements,1), size(measurements,2)))
%toc

dfs.Close();

end