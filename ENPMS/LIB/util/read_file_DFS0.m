function DFS0 = read_file_DFS0(FILE_NAME)

fprintf('\n\n--- Reading data file: %s',char(FILE_NAME));

NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfs0.*;

dfs0File  = DfsFileFactory.DfsGenericOpen(FILE_NAME);

dd = double(Dfs0Util.ReadDfs0DataDouble(dfs0File));

yy = double(dfs0File.FileInfo.TimeAxis.StartDateTime.Year);
mo = double(dfs0File.FileInfo.TimeAxis.StartDateTime.Month);
da = double(dfs0File.FileInfo.TimeAxis.StartDateTime.Day);
hh = double(dfs0File.FileInfo.TimeAxis.StartDateTime.Hour);
mi = double(dfs0File.FileInfo.TimeAxis.StartDateTime.Minute);
se = double(dfs0File.FileInfo.TimeAxis.StartDateTime.Second);

START_TIME = datenum(yy,mo,da,hh,mi,se);

DFS0.T = datenum(dd(:,1))/86400 + START_TIME;
DFS0.V = dd(:,2:end);

for i = 0:dfs0File.ItemInfo.Count - 1
    DFS0.NAME(i+1)           = {char(dfs0File.ItemInfo.Item(i).Name)};
    DFS0.TYPE(i+1)           = {char(dfs0File.ItemInfo.Item(i).Quantity.ItemDescription)};
    DFS0.UNIT(i+1)           = {char(dfs0File.ItemInfo.Item(i).Quantity.UnitAbbreviation)};
    DFS0.utmXmeters(i+1)     = dfs0File.ItemInfo.Item(i).ReferenceCoordinateX;
    DFS0.utmYmeters(i+1)     = dfs0File.ItemInfo.Item(i).ReferenceCoordinateY;
    DFS0.elev_ngvd29_ft(i+1) = dfs0File.ItemInfo.Item(i).ReferenceCoordinateZ;
end

dfs0File.Close();

fprintf('      done\n' );
end
