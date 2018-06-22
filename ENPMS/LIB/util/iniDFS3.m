function [S] = iniDFS3(infile)

%{
Open and read info from a DFS3 file
%}

NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfs123.*;
S.DFS = DfsFileFactory.Dfs3FileOpen(infile);

% % Read coordinates from file. Note that values are element center values
% % and therefor 0.5*Dx/y is added to all coordinates
% %S.x = saxis.X0 + saxis.Dx*(0.5+(0:(saxis.XCount-1)))';
% %S.y = saxis.Y0 + saxis.Dy*(0.5+(0:(saxis.YCount-1)))';
% %X0 = 494889.2;
% %Y0 = 2790267;
saxis = S.DFS.SpatialAxis;
%TODO: check x,y are these centers?
S.x = saxis.X0 + saxis.Dx*((0:(saxis.XCount-1)))';
S.y = saxis.Y0 + saxis.Dy*((0:(saxis.YCount-1)))';
S.z = saxis.ZCount;
S.dx = saxis.Dx;
S.dy = saxis.Dy;
S.XCount = saxis.XCount;
S.YCount = saxis.YCount;

for i = 0:S.DFS.ItemInfo.Count-1
    S.item(i+1).itemname = char(S.DFS.ItemInfo.Item(i).Name);
    S.item(i+1).itemtype = char(S.DFS.ItemInfo.Item(i).DataType);
    %S.item(i+1).itemvalue = char(S.myDfs.ItemInfo.Item(i).ValueType); % Instantaneous
    S.item(i+1).itemunit = char(S.DFS.ItemInfo.Item(i).Quantity.UnitAbbreviation);
    S.item(i+1).itemdescription=char(S.DFS.ItemInfo.Item(i).Quantity.ItemDescription);
    %S.item(i+1).unitdescription=char(S.myDfs.ItemInfo.Item(i).Quantity.UnitDescription);
end
S.count = S.DFS.ItemInfo.Count;
S.deltat   = S.DFS.FileInfo.TimeAxis.TimeStep;
S.unitt   = char(S.DFS.FileInfo.TimeAxis.TimeUnit);
S.nsteps   = S.DFS.FileInfo.TimeAxis.NumberOfTimeSteps;
S.DELETE = S.DFS.FileInfo.DeleteValueFloat;
aD = S.DFS.FileInfo.TimeAxis.StartDateTime.Day;
aM = S.DFS.FileInfo.TimeAxis.StartDateTime.Month;
aY = S.DFS.FileInfo.TimeAxis.StartDateTime.Year;
aH = S.DFS.FileInfo.TimeAxis.StartDateTime.Hour;
am = S.DFS.FileInfo.TimeAxis.StartDateTime.Minute;
aS = S.DFS.FileInfo.TimeAxis.StartDateTime.Second;
S.TIMESTEPD = S.DFS.FileInfo.TimeAxis.TimeStep/86400;
S.TSTART = datenum(double([aY aM aD aH am aS]));
S.TV = (S.TSTART:S.TSTART+S.nsteps);

end

