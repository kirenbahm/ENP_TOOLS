function DFS0 = BC2D_read_DFS0(FILE_NAME)

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
%DFS0.TSTR = datestr(DFS0.T); not needed, slow
DFS0.V = dd(:,2:end);
DFS0.TYPE = char(dfs0File.ItemInfo.Item(0).Name);
DFS0.UNIT = char(dfs0File.ItemInfo.Item(0).Quantity.UnitAbbreviation);

% remove all delete values - first remove the timevector elements
DFS0.T(DFS0.V == dfs0File.FileInfo.DeleteValueFloat)= [];
% second remove the data vector elements
DFS0.V(DFS0.V == dfs0File.FileInfo.DeleteValueFloat)= [];

% Read some item information
% items = {};
% for i = 0:dfs0File.ItemInfo.Count-1
%    item = dfs0File.ItemInfo.Item(i);
%    items{i+1,1} = char(item.Name);
%    items{i+1,2} = char(item.Quantity.Unit);
%    items{i+1,3} = char(item.Quantity.UnitAbbreviation); 
% end

%plot(DFS0.T,DFS0.V)
% A = datestr(DFS0.T);
% plot(A,DFS0.V);

dfs0File.Close();

end