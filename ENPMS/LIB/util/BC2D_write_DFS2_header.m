function file_dfs2 = BC2D_write_DFS2_header(INI)

NET.addAssembly('DHI.Generic.MikeZero.DFS');
NET.addAssembly('DHI.Generic.MikeZero.EUM');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfs123.*;
import DHI.Generic.MikeZero.*;

%fileDFS2 = INI.DFS2;

% create grid file
factory = DfsFactory();
builder = Dfs2Builder.Create('Matlab dfs2 file','Matlab DFS',0);

% Set up the header
builder.SetDataType(1);

builder.SetGeographicalProjection(factory.CreateProjectionGeoOrigin('UTM-17', INI.LON, INI.LAT, INI.NY));  

[yy,mo,dd,hh,mi,ss] = datevec(INI.DATE_I);
builder.SetTemporalAxis(factory.CreateTemporalEqCalendarAxis(eumUnit.eumUsec,System.DateTime(yy,mo,dd,hh,mi,ss),0,INI.DELT));

builder.SetSpatialAxis(factory.CreateAxisEqD2(eumUnit.eumUmeter,INI.nx,0,INI.cell,INI.ny,0,INI.cell));

builder.DeleteValueFloat = single(-1e-30);
builder.DeleteValueDouble = single(-1e-30);

builder.AddDynamicItem('Water Level', eumQuantity.Create(eumItem.eumIElevation, eumUnit.eumUfeet),DfsSimpleType.Float, DataValueType.Instantaneous);


builder.CreateFile(INI.DFS2);
file_dfs2 = builder.GetFile();

end