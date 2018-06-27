function [DATA] = readSEEPAGEMAP(infile)

%{
Open and read info from a DFS2 file
%}
NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;
%import DHI.Generic.MikeZero.DFS.dfs123.*;

%testing purposes: 
%infile = 'N:\PROJ_W_INP\2013_07052013_AG_MDRESERVOIR\PHASE_IIIA\MODEL\ALTERNATIVES\DATA_ANALYSIS\MDR_SEEPAGE.dfs2';

TS.S.dfs2 = DfsFileFactory.Dfs2FileOpen(infile);

% % Read coordinates from file. Note that values are element center values
% % and therefor 0.5*Dx/y is added to all coordinates
% %S.x = saxis.X0 + saxis.Dx*(0.5+(0:(saxis.XCount-1)))';
% %S.y = saxis.Y0 + saxis.Dy*(0.5+(0:(saxis.YCount-1)))';
% %X0 = 494889.2;
% %Y0 = 2790267;

% fprintf(['------'  infile  '------\n' ]);
saxis = TS.S.dfs2.SpatialAxis;
%TODO: check x,y are these centers?
TS.S.x = saxis.X0 + saxis.Dx*((0:(saxis.XCount-1)))';
TS.S.y = saxis.Y0 + saxis.Dy*((0:(saxis.YCount-1)))';
% TS.S.z = saxis.ZCount;
TS.S.dx = saxis.Dx;
TS.S.dy = saxis.Dy;


for i = 0:TS.S.dfs2.ItemInfo.Count-1
    TS.S.item(i+1).itemname = char(TS.S.dfs2.ItemInfo.Item(i).Name);
    TS.S.item(i+1).itemtype = char(TS.S.dfs2.ItemInfo.Item(i).DataType);
    %TS.S.item(i+1).itemvalue = char(TS.S.dfs2.ItemInfo.Item(i).ValueType); % Instantaneous
    TS.S.item(i+1).itemunit = char(TS.S.dfs2.ItemInfo.Item(i).Quantity.UnitAbbreviation);
    TS.S.item(i+1).itemdescription=char(TS.S.dfs2.ItemInfo.Item(i).Quantity.ItemDescription);
    %TS.S.item(i+1).unitdescription=char(TS.S.dfs2.ItemInfo.Item(i).Quantity.UnitDescription);
end

TS.S.count = TS.S.dfs2.ItemInfo.Count;
TS.S.deltat   = TS.S.dfs2.FileInfo.TimeAxis.TimeStep;
TS.S.unitt   = char(TS.S.dfs2.FileInfo.TimeAxis.TimeUnit);
TS.S.nsteps   = TS.S.dfs2.FileInfo.TimeAxis.NumberOfTimeSteps;
D = TS.S.dfs2.FileInfo.TimeAxis.StartDateTime.Day;
M = TS.S.dfs2.FileInfo.TimeAxis.StartDateTime.Month;
Y = TS.S.dfs2.FileInfo.TimeAxis.StartDateTime.Year;
H = TS.S.dfs2.FileInfo.TimeAxis.StartDateTime.Hour;
m = TS.S.dfs2.FileInfo.TimeAxis.StartDateTime.Minute;
S = TS.S.dfs2.FileInfo.TimeAxis.StartDateTime.Second;

TS.S.TSTART = datenum(double([Y M D H m S]));
TV = TS.S.nsteps;
% TS.MAPDATA = containers.Map(TV);

DATA(1:saxis.XCount,1:saxis.YCount) = NaN;
TS.MAPDATA = containers.Map(double(1),DATA);
remove(TS.MAPDATA,1);

%TS.DATA(1:TS.S.nsteps) = DATA;

DATA = int32(TS.S.dfs2.ReadItemTimeStep(1,i).To2DArray());

% T = TS.S.TSTART - 1;
% for i=0:TS.S.nsteps-1
%         %HARDWIRED to item 3
%         T = T + 1;
%         DATA = int32(TS.S.dfs2.ReadItemTimeStep(1,i).To2DArray());
%         TS.MAPDATA(T) = DATA;
% end

end