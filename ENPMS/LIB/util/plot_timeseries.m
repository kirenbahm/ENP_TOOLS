function [] = plot_timeseries(STATION,INI)
%{
---------------------------------------------
% FUNCTION DESCRIPTION:
%
% BUGS:
% COMMENTS:
%----------------------------------------
% REVISION HISTORY:
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

set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', [0,0,8,3]);
set(gcf, 'Renderer', 'OpenGL');
set(gcf, 'Color', 'w');
fig = clf;
%fh = figure(fig);

% Screen size and position
% f=[400,150];
% set(fh,'units','points','position',[750,100,f(1),f(2)]);

CO = INI.GRAPHICS_CO;
LS = INI.GRAPHICS_LS;
M = INI.GRAPHICS_M;
MSZ = INI.GRAPHICS_MSZ;
LW = INI.GRAPHICS_LW;

if INI.INCLUDE_OBSERVED
    ibegin = 1;
else
    ibegin = 2;
end

for i = ibegin:n
%    rTS = TSk(:,i);
%    rTV = TV_STR;
%    index_nan = isnan(rTS); % find inexes with Nan
%    rTS(index_nan)=[]; %remove Nan values
%    rTV(index_nan,:)=[]; %remove dates with Nan values
%    TS = timeseries(rTS,rTV);
%    TS.name = char(N(i));
TS = TSC.(NAMES(i));
    TS.TimeInfo.Format = 'mm/yy';
    FS = 10;
    set(gca,'FontSize',FS,'FontName','times');
    set(gca,'linewidth',LW(i));
    F = plot(TS,'LineWidth',LW(i), 'Linestyle', char(LS(i)), 'Color',char(CO(i)), 'Marker',char(M(i)), 'MarkerSize',MSZ(i),'LineWidth',LW(i));
    hold on
end

%NOTE:  TTS  TS are now identical

TSss.startdate = INI.ANALYZE_DATE_I;
TSss.enddate = INI.ANALYZE_DATE_F;
STS = nummthyr(TSss);
%HARDCODE: % this is the number of years between tickmarks:
tickspacing = 1;


xint = ceil(tickspacing*(STS.cumtotyrdays(end) / length(STS.yrs)));
% xtl=STS.yrs(1:tickspacing:length(STS.yrs));
xtl = num2cell (STS.yrs(1:tickspacing:length(STS.yrs)));

xticks = get(gca,'XTickLabel');
xlimt  = get(gca, 'Xlim');
%display(STS.cumtotyrdays(end));

% daystart = datenum(STS.startdate); % GIT issue
% dayend   = datenum(STS.enddate);   % GIT issue
% %xlim([daystart dayend]);           % GIT issue
% % set (gca, 'Xlim', ([0,STS.cumtotyrdays(end)]));
% set(gca,'XTick',(daystart:xint:dayend)); % GIT issue
% set(gca,'XTickLabel',xtl);               % GIT issue

xlabel('');
% xlim([0,STS.cumtotyrdays(end)]);
% set(gca,'XTick',(1:xint:STS.cumtotyrdays(end)))
% set(gca,'XTickLabel',xtl)
% xlim([0,length(TS.Time)-1]);

% title(STATION.NAME,'FontSize',12,'FontName','Times New Roman','Interpreter','none');

% Check if datatype is elevation, if so, add the datum to the y-axis label
if (strcmp(STATION.DFSTYPE,'Elevation') == 1)
    ylabel(strcat(STATION.DFSTYPE, {', '}, STATION.UNIT, {' '}, INI.DATUM));
else
    ylabel(strcat(STATION.DFSTYPE, {', '}, STATION.UNIT));
end
%   ylabel(strcat(STATION.DFSTYPE, ', ', STATION.UNIT));

minvl = min(minval);
maxvl = max(maxval);
aymin = minvl - 0.1*(maxvl-minvl);
aymax = maxvl + 0.15*(maxvl-minvl);
ylim([aymin aymax]);

% % legh = [];
% % legt = N;
% % LEG = legend(legh, legt,7,'Location','SouthEast');
% % legend boxoff;

%if (INI.INCLUDE_OBSERVED)
nn = length(INI.MODEL_RUN_DESC)+1;
NN(1) = {'Observed'};
NN(2:nn) = INI.MODEL_RUN_DESC(1:nn-1);
NN = strrep(NN,'_','\_');
%else
%    nn = length(INI.MODEL_RUN_DESC);
%    NN(1:nn) = INI.MODEL_RUN_DESC(1:nn);
%end
legt = NN;

%legend(legt,7,'Location','SouthEast');
%legend(legt,7,'Location','best');
legend(legt,'Location','best');
legend boxoff;
grid on;
s_title = strcat(char(STATION.NAME));
title(s_title,'FontSize',10,'FontName','times','Interpreter','none');

grid on;
try
    if (STATION.Z_GRID > -1.0e-035)
        string_ground_level = strcat({'GSE: grid = '}, char(sprintf('%.1f',STATION.Z_GRID)), {' ft'});
        add_ground_level(0,0.9,STATION.Z_GRID,[188/256 143/256 143/256],2,'--',12,string_ground_level);
    end
catch
    fprintf(' --> ...WARNING: Missing Z_GRID in station %s\n', char(STATION.NAME))
end

plotfile = strcat(INI.FIGURES_DIR_TS,'/',STATION.NAME);
F=strcat(plotfile,'.png'); % or use .png
%exportfig(char(F),'width',12,'height',5, 'FontSize',18);
print('-dpng',char(plotfile),'-r300')
if INI.SAVEFIGS; savefig(char(plotfile)); end;
hold off

end


