function file_dfs2 = BC2D_write_DFS2(INI)

[yy,mo,dd,hh,mi,ss] = datevec(INI.DATE_I);

NET.addAssembly('DHI.Generic.MikeZero.DFS');
NET.addAssembly('DHI.Generic.MikeZero.EUM');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfs123.*;
import DHI.Generic.MikeZero.*;

% Domain covers 458400-558000=99600 horizontal and 2867500-2777500=90000 m
% Total sq.km = 8,960 total sq.m = 3,462, out of each 2,500 active  
fileDFS2 = INI.DFS2;

% % create grid file
factory = DfsFactory();
builder = Dfs2Builder.Create('Matlab dfs2 file','Matlab DFS',0);
% Set up the header
builder.SetDataType(1);
% builder.SetGeographicalProjection(factory.CreateProjectionGeoOrigin('NAD_1983_UTM_Zone_17N', INI.LON, INI.LAT, INI.NY));
builder.SetGeographicalProjection(factory.CreateProjectionGeoOrigin('UTM-17', INI.LON, INI.LAT, INI.NY));
%builder.SetTemporalAxis(factory.CreateTemporalEqCalendarAxis(eumUnit.eumUsec,System.DateTime(1965,1,1,0,0,0),0,INI.DELT));
builder.SetTemporalAxis(factory.CreateTemporalEqCalendarAxis(eumUnit.eumUsec,System.DateTime(yy,mo,dd,hh,mi,ss),0,INI.DELT));
builder.SetSpatialAxis(factory.CreateAxisEqD2(eumUnit.eumUmeter,INI.nx,0,INI.cell,INI.ny,0,INI.cell));
builder.DeleteValueFloat = single(-1e-30);
builder.DeleteValueDouble = single(-1e-30);
builder.AddDynamicItem('Water Level', eumQuantity.Create(eumItem.eumIWaterLevel, eumUnit.eumUfeet),DfsSimpleType.Float, DataValueType.Instantaneous);
builder.CreateFile(fileDFS2);
file_dfs2 = builder.GetFile();

end