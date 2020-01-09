function [] = plot_timeseries_accumulated(STATION,INI)
% function plot_timeseries_accumulated(STATION,INI) prepares timeseries data for cumulative plotting


if ~any(~isnan(STATION.TIMESERIES(:)))
    fprintf('\t--> All timeseries values are NaN');
    return
end

% use specified graphic values in setup_ini)
CO = INI.GRAPHICS_CO;
LS = INI.GRAPHICS_LS;
M = INI.GRAPHICS_M;
MSZ = INI.GRAPHICS_MSZ;
LW = INI.GRAPHICS_LW;

%conversion from cfs to kaf/day
CFS_KAFDY = 0.001982;

% Timeseries and titles
TS = STATION.TIMESERIES;
TV = STATION.TIMEVECTOR;
[y, m] = datevec(TV);
YR = unique(y);

n = length(TS(1,:));
SIM(1) = {'Observed'};
SIM(2:n) = INI.MODEL_RUN_DESC(1:n-1);

TV_STR = datestr(TV,2);
TMP = [];
TMP(:,1) = TS(:,length(TS(1,:)));
TMP(:,2:length(TS(1,:))) = TS(:,1:length(TS(1,:))-1);
TS = TMP;
TSk = TS;

% select combination of timeseries - observed and computed for plotting
if INI.INCLUDE_OBSERVED & INI.INCLUDE_COMPUTED
    m = [1:n]; % observed is in column sz+1
end
if INI.INCLUDE_OBSERVED & ~INI.INCLUDE_COMPUTED
    m = [1];
end
if ~INI.INCLUDE_OBSERVED & INI.INCLUDE_COMPUTED
    m = [2:n];
end

LEGEND =[];
fig = clf;
%figure settings;
clf;

totQacc(1:n) = NaN;

for i = m %
    rTS = TSk(:,i);
    rTV = TV_STR;
    dNUM = datenum(rTV); % convert sdates to dates
    ind_dates = find(dNUM < datenum(INI.ANALYZE_DATE_I));
    rTS(ind_dates)=NaN;
    ind_dates = find(dNUM > datenum(INI.ANALYZE_DATE_F));
    rTS(ind_dates)=NaN;  
    
    index_nan = isnan(rTS); % find inexes with Nan
    rTS(index_nan)=[]; %remove Nan values
    rTV(index_nan,:)=[]; %remove dates with Nan values
    % compute accumulated as sumation of deltaT*Q(t)
    
    if isempty(rTS)
        continue
    end % code to skip timeseries with zero length

    dNUM = datenum(rTV);
    deltaT = [0; dNUM(2:end) - dNUM(1:end-1)]; % compute difference in time for non-nan values 
    Qt = deltaT.*rTS*CFS_KAFDY; % compute scalar product of flow as per deltaT (based on daily values
    Qacc = cumsum(Qt);
    
    TSp = timeseries(Qacc,rTV);
    TSp.name = char(SIM(i));
    TSp.TimeInfo.Format = 'dd/mm/yy';
    
    LEGEND = [LEGEND strrep(SIM(i),'_','\_')];
    F = plot(TSp,'LineWidth',LW(i), 'Linestyle', char(LS(i)), 'Color',cell2mat(CO(i)), 'Marker',char(M(i)), 'MarkerSize',MSZ(i),'LineWidth',LW(i));
    totQacc(i) = Qacc(end);
    hold on;
end

if ~exist('F') 
    return
end

FS = INI.GRAPHICS_FS;
FN = INI.GRAPHICS_FN;
set(gca,'FontSize',FS,'FontName',INI.GRAPHICS_FN);

formatStr = '\tCumulative values on %s:';
str_1 = sprintf(formatStr,datestr(INI.ANALYZE_DATE_F));
str_T = strvcat(str_1);

ii = 0;
for i = m
    ii = ii + 1;
    if ~isnan(totQacc(ii))
        formatStr = '\tTotal %s = %+5.2f kaf';
        str_2 = sprintf(formatStr,char(SIM(ii)),totQacc(ii));
        str_T = strvcat(str_T, str_2);
    end
end

set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', [0,0,INI.GRAPHICS_FIGUREWIDTH,INI.GRAPHICS_FIGUREHEIGHT]);
set(gcf, 'Renderer', 'OpenGL');
set(gcf, 'Color', 'w');


% set(gca, 'xtick', datenum(YR(1)-1:YR(end)+1, 1, 1));
datetick('x', 'yyyy', 'keeplimits', 'keepticks');

AX = gca;
YLIM = AX.YLim;
XLIM = AX.XLim;
xT = XLIM(1) + 0.02*(XLIM(2) - XLIM(1));
yT = YLIM(1) + 0.85*(YLIM(2) - YLIM(1));
text(xT,yT, str_T);

title(STATION.NAME,'FontSize',10,'FontName','Times New Roman','Interpreter','none');

ylabel('Cumulative discharge, Kaf');

grid on;
legend(LEGEND,'Location','SouthEast')
legend boxoff;

plotfile = strcat(INI.FIGURES_DIR_TS,'/',STATION.NAME,'-acc');
F=strcat(plotfile,'.png'); % or use .png
%exportfig(char(F),'width',12,'height',5, 'FontSize',18);
print('-dpng',char(plotfile),'-r300');
if INI.SAVEFIGS; savefig(char(plotfile)); end;

hold off

end

