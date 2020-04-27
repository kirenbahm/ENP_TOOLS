function DATA = readDomainGridCodes(FILE_NAME)
dmi = NET.addAssembly('DHI.Mike.Install');
if (~isempty(dmi))
    DHI.Mike.Install.MikeImport.SetupLatest({DHI.Mike.Install.MikeProducts.MikeCore});
end
NET.addAssembly('C:\Program Files (x86)\DHI\2019\bin\x64\DHI.Generic.MikeZero.DFS.dll');
NET.addAssembly('C:\Program Files (x86)\DHI\2019\bin\x64\DHI.Generic.MikeZero.EUM.dll');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfs123.*;
import DHI.Generic.MikeZero.*
dfs2File  = DfsFileFactory.Dfs2FileOpen(FILE_NAME);
DATA.V = (double(dfs2File.ReadItemTimeStep(1,0).To2DArray()))';
DATA.Rows = dfs2File.SpatialAxis.YCount;
DATA.Cols = dfs2File.SpatialAxis.XCount;
DATA.saxis= dfs2File.SpatialAxis;
dfs2File.Close();
end
