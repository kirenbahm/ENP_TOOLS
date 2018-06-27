function [] = plot_timeseries_accumulated_v9(STATION,INI)
%---------------------------------------------
% FUNCTION DESCRIPTION:
%
% BUGS:
% COMMENTS:
%----------------------------------------
%{
 REVISION HISTORY:

v9: 2015-02-29 keb
     - changed plotting commands to be consistent with other scripts
v8: added check to see if the whole timeseries was NaNs. If so, change from zeros
    back to NaNs to avoid nonexistent timeseries plotting on graph
    (added v8 by keb)
    if sum(INAN) == length(TS) ACCUMULATED_ACFT = TS(dfsstart:length(TS(:,1)),i) ; end

20130617 -v5- added switch to exclude observed
 v3 changes: adjusted the start date of the accumulation to the start of the observed data
 changes introduced to v1:  (keb 8/2011)
  -changed conversion factor from cfs->af/yr to cfs->kaf/day,
   also changed y-axis label and plot title
%}
%----------------------------------------
fprintf('\n\tAccumulated timeseries plot: %s',  char(STATION.NAME))

%conversion from cfs to kaf/day
CFS_KAFDY = 0.001982;

%create time series:
TS = STATION.TIMESERIES;
TV = STATION.TIMEVECTOR;
n = length(TS(1,:));
N(1) = {'Observed'};
N(2:n) = INI.MODEL_RUN_DESC(1:n-1);

% putting OBSERVED as the first column, so that the legends matches;
TMP = [];
TMP(:,1) = TS(:,length(TS(1,:)));
TMP(:,2:length(TS(1,:))) = TS(:,1:length(TS(1,:))-1);
TS = TMP;
%%%%%%%%%%
valsum = sum(~isnan(TS),2); % valid number of time series per row
dfsstart = find(valsum > 0,1,'first');


%TV_STR = datestr(TV,2);
TV_STR = datestr(TV(dfsstart:length(TS(:,1))),2);

TSC = tscollection(TV_STR);

for i = 1:n % add only the first n-1 series, the nth series is observed
    %    TS_NANS = TS(:,i);
    TS_NANS = TS(dfsstart:length(TS(:,1)),i);
    INAN = isnan(TS_NANS);
    TS_NANS(INAN) = 0;
    ACCUMULATED = cumsum(TS_NANS);
    ACCUMULATED_ACFT = ACCUMULATED * CFS_KAFDY;
    % check if the whole timeseries was NaNs. If so, change from zeros
    % back to NaNs to avoid nonexistent timeseries plotting on graph
    % (added v8 by keb)
    if sum(INAN) == length(TS) ACCUMULATED_ACFT = TS(dfsstart:length(TS(:,1)),i) ; end
    TTS = timeseries(ACCUMULATED_ACFT,TV_STR);
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
F.MSZ = [ 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3];
F.LW = [ 1 1 1 1 1 1 1 1 1 1 3 3 3 3 3];

if (INI.INCLUDE_OBSERVED)
    ibegin = 1;
else
    ibegin = 2;
end

for i = ibegin:n
    NTS = NAMES(i);
    TS = TSC.(NTS);
    TS.TimeInfo.Format = 'mm/yy';
    FS = 14;
    set(gca,'FontSize',FS,'FontName','Times New Roman');
    set(gca,'linewidth',F.LW(i));
    %   F = plot(TS,'LineWidth',F.LW(i), 'Linestyle', char(F.LS(i)), 'Color',char(F.CO(i)), 'Marker',char(F.M(i)), 'MarkerSize',F.MSZ(i),'LineWidth',F.LW(i));
    plot(TS,'LineWidth',F.LW(i), 'Linestyle', char(F.LS(i)), 'Color',char(F.CO(i)), 'Marker',char(F.M(i)), 'MarkerSize',F.MSZ(i),'LineWidth',F.LW(i));
    hold on
    myvalue = TS.Data(end)-mod(TS.Data(end),1);
    text('String',myvalue,'Position',[datenum(INI.ANALYZE_DATE_F)+25 TS.Data(end)],'Color',char(F.CO(i)));
end

title(STATION.NAME,'FontSize',14,'FontName','Times New Roman','Interpreter','none');

ylabel('Cumulative discharge, Kaf');
xlabel('');

% % % xlim([0,length(TS.Time)-1]);
TSss.startdate = INI.ANALYZE_DATE_I;
TSss.enddate = INI.ANALYZE_DATE_F;
STS = nummthyr(TSss);
%HARDCODE:
tickspacing = 2;
xint = ceil(tickspacing*(STS.cumtotyrdays(end) / length(STS.yrs)));
xtl = num2cell (STS.yrs(1:tickspacing:length(STS.yrs)));

xticks = get(gca,'XTickLabel');
xlimt  = get(gca, 'Xlim');
%display(STS.cumtotyrdays(end));

daystart = datenum(STS.startdate);
dayend   = datenum(STS.enddate);
xlim([daystart dayend]);
% set (gca, 'Xlim', ([0,STS.cumtotyrdays(end)]))
set(gca,'XTick',(daystart:xint:dayend));
set(gca,'XTickLabel',xtl);

% add legend entries
legt = N(ibegin:n);
legend(legt,7,'Location','NorthWest');
legend boxoff;

plotfile = strcat(INI.FIGURES_DIR_TS,'/',STATION.NAME,'-acc');
print('-dpng',char(plotfile),'-r300')
hold off

end

