function [] = plot_timeseries_v8(STATION,INI)
%{
---------------------------------------------
% FUNCTION DESCRIPTION:
%
% BUGS:
% COMMENTS:
%----------------------------------------
% REVISION HISTORY:

v8: 2015-02-29 keb
     - changed plotting commands to be consistent with other scripts
v7b: 2015-12-30 keb
     - added datum to ylabel if dfstype is elevation
     - fixed ylabel spacing
     - fixed legend bug
v7a: 2015-12-29 keb  - added title with station name and legend
20130617 -v5- added switch to exclude observed
%
021812 -v4- changed SIM to INI
        many style changes
% changes introduced to v2:  (keb 8/2011)
%  -script would exit prematurely if a STATION.X_UTM or Y was
%   not found in the MAP_ALL_DATA container. now using try-catch.
%----------------------------------------
%}

TS = STATION.TIMESERIES;
TV = STATION.TIMEVECTOR;
n = length(TS(1,:));
% Legend putting OBSERVED as the first column, so that the legends matches;
N(1) = {'Observed'};
N(2:n) = INI.MODEL_RUN_DESC(1:n-1);

TV_STR = datestr(TV,2);
TSC = tscollection(TV_STR);
TMP = [];
TMP(:,1) = TS(:,length(TS(1,:)));
TMP(:,2:length(TS(1,:))) = TS(:,1:length(TS(1,:))-1);
TS = TMP;

for i = 1:n % add only the first n-1 series, the nth series is observed
    % find min and max for plotting
    minval(i) = min(min(TS(:,i)));
    maxval(i) = max(max(TS(:,i)));
    
    TTS = timeseries(TS(:,i),TV_STR);
    TTS.name = char(N(i));
    TTS.TimeInfo.Format = 'mm/yy';
    TSC = addts(TSC,TTS);
end

NAMES =  gettimeseriesnames(TSC);
%-----------------------------------------------------------
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', [0,0,8,3]);
set(gcf, 'Renderer', 'OpenGL');
set(gcf, 'Color', 'w');
fig = clf;
fh = figure(fig);
f=[800,300];
set(fh,'units','points','position',[750,100,f(1),f(2)]);
%-----------------------------------------------------------

F.CO = {'r', 'k', 'g', 'b', 'm', 'b', 'k', 'g', 'c', 'm', 'k', 'g', 'b', 'm', 'b'};
F.LS = {'none','-','-','-','-','-.','-.','-.','-.','-.',':','--','-','-','-','-.','-.'};
F.M = {'s','none','none','none','none','none','none','none','none','none','none','none','none','none','none'};
F.MSZ = [ 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3];
F.LW = [ 1 1 1 1 1 1 1 1 1 1 3 3 3 3 3];

if (INI.INCLUDE_OBSERVED)
    ibegin = 1;
else
    ibegin = 2;
end


for i = ibegin:n
    TS = TSC.(NAMES(i));
    TS.TimeInfo.Format = 'mm/yy';
    FS = 14;
    set(gca,'FontSize',FS,'FontName','Times New Roman');
    set(gca,'linewidth',F.LW(i));
    %   F = plot(TS,'LineWidth',F.LW(i), 'Linestyle', char(F.LS(i)), 'Color',char(F.CO(i)), 'Marker',char(F.M(i)), 'MarkerSize',F.MSZ(i),'LineWidth',F.LW(i));
    plot(TS,'LineWidth',F.LW(i), 'Linestyle', char(F.LS(i)), 'Color',char(F.CO(i)), 'Marker',char(F.M(i)), 'MarkerSize',F.MSZ(i),'LineWidth',F.LW(i));
    hold on
end

if (STATION.Z_GRID > -1.0e-035)
    string_ground_level = strcat({'GSE: grid = '}, char(sprintf('%.1f',STATION.Z_GRID)), {' ft'});
    add_ground_levelV0(0,0.9,STATION.Z_GRID,[188/256 143/256 143/256],2,'--',12,string_ground_level);
end

%NOTE:  TTS  TS are now identical

TSss.startdate = INI.ANALYZE_DATE_I;
TSss.enddate = INI.ANALYZE_DATE_F;
STS = nummthyr(TSss);
%HARDCODE:
tickspacing = 2;
xint = ceil(tickspacing*(STS.cumtotyrdays(end) / length(STS.yrs)));
% xtl=STS.yrs(1:tickspacing:length(STS.yrs));
xtl = num2cell (STS.yrs(1:tickspacing:length(STS.yrs)));

xticks = get(gca,'XTickLabel');
xlimt  = get(gca, 'Xlim');
%display(STS.cumtotyrdays(end));

daystart = datenum(STS.startdate);
dayend   = datenum(STS.enddate);
xlim([daystart dayend]);
% set (gca, 'Xlim', ([0,STS.cumtotyrdays(end)]));
set(gca,'XTick',(daystart:xint:dayend));
set(gca,'XTickLabel',xtl);

title(STATION.NAME,'FontSize',14,'FontName','Times New Roman','Interpreter','none');

legt = N(ibegin:n);
legend(legt,7,'Location','best');
legend boxoff;

% Check if datatype is elevation, if so, add the datum to the y-axis label
if (strcmp(STATION.DFSTYPE,'Elevation') == 1)
    ylabel(strcat(STATION.DFSTYPE, {', '}, STATION.UNIT, {' '}, INI.DATUM));
else
    ylabel(strcat(STATION.DFSTYPE, {', '}, STATION.UNIT));
end

minvl = min(minval);
maxvl = max(maxval);
aymin = minvl - 0.1*(maxvl-minvl);
aymax = maxvl + 0.15*(maxvl-minvl);
ylim([aymin aymax]);

grid on;
plotfile = strcat(INI.FIGURES_DIR_TS,'/',STATION.NAME);
print('-dpng',char(plotfile),'-r300')
hold off

end
