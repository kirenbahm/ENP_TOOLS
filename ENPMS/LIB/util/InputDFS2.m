function [S] = InputDFS2v2(infile)

%{
Open and read info from a DFS2 file

v2 changes 12/1/2015 keb
 changed variable name
 added line 'import DHI.Generic.MikeZero.DFS.dfs123.*;'
%}
NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfs123.*;
S.myDfs = DfsFileFactory.Dfs2FileOpen(infile);

% % Read coordinates from file. Note that values are element center values
% % and therefor 0.5*Dx/y is added to all coordinates
% %S.x = saxis.X0 + saxis.Dx*(0.5+(0:(saxis.XCount-1)))';
% %S.y = saxis.Y0 + saxis.Dy*(0.5+(0:(saxis.YCount-1)))';
% %X0 = 494889.2;
% %Y0 = 2790267;
saxis = S.myDfs.SpatialAxis;
%TODO: check x,y are these centers?
S.x = saxis.X0 + saxis.Dx*((0:(saxis.XCount-1)))';
S.y = saxis.Y0 + saxis.Dy*((0:(saxis.YCount-1)))';
S.dx = saxis.Dx;
S.dy = saxis.Dy;

for i = 0:S.myDfs.ItemInfo.Count-1
    S.item(i+1).itemname = char(S.myDfs.ItemInfo.Item(i).Name);
    S.item(i+1).itemtype = char(S.myDfs.ItemInfo.Item(i).DataType);
    %S.item(i+1).itemvalue = char(S.myDfs.ItemInfo.Item(i).ValueType); % Instantaneous
    S.item(i+1).itemunit = char(S.myDfs.ItemInfo.Item(i).Quantity.UnitAbbreviation);
    S.item(i+1).itemdescription=char(S.myDfs.ItemInfo.Item(i).Quantity.ItemDescription);
    %S.item(i+1).unitdescription=char(S.myDfs.ItemInfo.Item(i).Quantity.UnitDescription);
end
S.count = S.myDfs.ItemInfo.Count;
S.deltat   = S.myDfs.FileInfo.TimeAxis.TimeStep;
S.unitt   = char(S.myDfs.FileInfo.TimeAxis.TimeUnit);
S.nsteps   = S.myDfs.FileInfo.TimeAxis.NumberOfTimeSteps;

end
