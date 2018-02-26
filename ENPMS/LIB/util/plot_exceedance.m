function [] = plot_exceedance(STATION,INI)
% function plot_exceedances(STATION,INI) plots exceedance for the
% simulation interval

if ~any(~isnan(STATION.TIMESERIES(:)))
    fprintf('...%d All timeseries values are NaN, continue\n');
    return
end


fprintf('... Processing accumulated timeseries plot: %s\n',  char(STATION.NAME))

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
nDP(1:n) = 0;
maxrTS(1:n) = 0;

%figure settings;
clf;
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', [0,0,8,3]);
set(gcf, 'Renderer', 'OpenGL');
set(gcf, 'Color', 'w');

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
    
    if isempty(rTS)
        continue
    end % code to skip timeseries with zero length

    % sort descending
    SORT_TS = sort(rTS(:),1,'descend');
    D = length(rTS)+1;
    RANK = 1:D-1;
    RANK = RANK';
    P_COMP = RANK/D;
    
    LEGEND = [LEGEND strrep(SIM(i),'_','\_')];  
    F = plot(P_COMP,SORT_TS,'LineWidth',LW(i), 'Linestyle', char(LS(i)), 'Color',cell2mat(CO(i)), 'Marker',char(M(i)), 'MarkerSize',MSZ(i),'LineWidth',LW(i));
    hold on;
    nDP(i) = length(SORT_TS);
    maxrTS(i) = SORT_TS(1);
end

if ~exist('F') 
    return
end

FS = INI.GRAPHICS_FS;
FN = INI.GRAPHICS_FN;
set(gca,'FontSize',FS,'FontName',INI.GRAPHICS_FN);

formatStr = '\tNumber of data points:';
str_1 = sprintf(formatStr);
str_T = strvcat(str_1);

ii = 0;
for i = m
    ii = ii + 1;
    formatStr = '\t%s = %d points';
    str_2 = sprintf(formatStr,char(SIM(ii)),nDP(ii));
    str_T = strvcat(str_T, str_2);
end

AX = gca;
YLIM = AX.YLim;
XLIM = AX.XLim;
xT = XLIM(1) + 0.02*(XLIM(2) - XLIM(1));
yT = YLIM(1) + 0.25*(YLIM(2) - YLIM(1));
text(xT,yT, str_T);

title(STATION.NAME,'FontSize',10,'FontName','Times New Roman','Interpreter','none');

if (strcmp(STATION.DFSTYPE,'Elevation') == 1)
    ylabel(strcat(STATION.DFSTYPE, {', '}, STATION.UNIT, {' '}, INI.DATUM));
else
    ylabel(strcat(STATION.DFSTYPE, {', '}, STATION.UNIT));
end

xlabel('Probability exceedance');
grid on;
legend(LEGEND,'Location','NorthEast')
legend boxoff;

try
    STATION.Z_GRID = cell2mat(INI.MAPXLS.MSHE(char(STATION.NAME)).gridgse);
catch
    STATION.Z_GRID = -1.0e-35;
end

if (STATION.Z_GRID > -1.0e-035)
    %string_ground_level = strcat({'GSE: grid = '}, char(sprintf('%.1f',STATION.Z_GRID)), {' ft'});
    string_ground_level = '';
    add_ground_level(0,0.15,STATION.Z_GRID,[188/256 143/256 143/256],2,'--',12,string_ground_level);
end

plotfile = strcat(INI.FIGURES_DIR_EXC,'/',STATION.NAME);
print('-dpng',char(plotfile),'-r300')
if INI.SAVEFIGS; savefig(char(plotfile)); end;

hold off

end

