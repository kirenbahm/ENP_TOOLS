function [] = plot_timeseries(STATION,INI)
% function plot_timeseries(STATION,INI) prepares timeseries data for plotting


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
%figure settings;
clf;

for i = m %
    rTS = TSk(:,i);
    rTV = TV_STR;
    index_nan = isnan(rTS); % find inexes with Nan
    rTS(index_nan)=[]; %remove Nan values
    rTV(index_nan,:)=[]; %remove dates with Nan values
    TSp.name = char(SIM(i));
    TSp = timeseries(rTS,rTV);
    TSp.TimeInfo.Format = 'dd/mm/yy';
    
    if isempty(rTS)
        continue
    end % code to skip timeseries with zero length
    
    LEGEND = [LEGEND strrep(SIM(i),'_','\_')];
    F = plot(TSp,'LineWidth',LW(i), 'Linestyle', char(LS(i)), 'Color',cell2mat(CO(i)), 'Marker',char(M(i)), 'MarkerSize',MSZ(i),'LineWidth',LW(i));
    hold on
end

if ~exist('F') 
    return
end

FS = INI.GRAPHICS_FS;
FN = INI.GRAPHICS_FN;
set(gca,'FontSize',FS,'FontName',INI.GRAPHICS_FN);

% Check if datatype is elevation, if so, add the datum to the y-axis label
if (strcmp(STATION.DFSTYPE,'Elevation') == 1)
    ylabel(strcat(STATION.DFSTYPE, {', '}, STATION.UNIT, {' '}, INI.DATUM));
else
    ylabel(strcat(STATION.DFSTYPE, {', '}, STATION.UNIT));
end
%   ylabel(strcat(STATION.DFSTYPE, ', ', STATION.UNIT));

set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', [0,0,8,3]);
set(gcf, 'Renderer', 'OpenGL');
set(gcf, 'Color', 'w');

maxvl = max(max(TSk(:,m)));
minvl = min(min(TSk(:,m)));
aymin = minvl - 0.1*(maxvl-minvl);
aymax = maxvl + 0.15*(maxvl-minvl);
ylim([aymin aymax]);


%set(gca, 'xtick', datenum(YR(1)-1:YR(end)+1, 1, 1));
datetick('x', 'yyyy', 'keeplimits', 'keepticks');

legend(LEGEND,'Location','NorthEast');
legend boxoff;

grid on;
s_title = char(STATION.NAME);
title(s_title,'FontSize',10,'FontName','times','Interpreter','none');

try
    if (STATION.Z_GRID > -1.0e-035)
        string_ground_level = strcat({'GSE: grid = '}, char(sprintf('%.1f',STATION.Z_GRID)), {' ft'});
        add_ground_level(0,0.9,STATION.Z_GRID,[188/256 143/256 143/256],2,'--',12,string_ground_level);
    end
catch
    fprintf(' --> WARNING: Missing Z_GRID in station %s', char(STATION.NAME))
end

plotfilename = strcat(INI.FIGURES_DIR_TS,'/',STATION.NAME);
F=strcat(plotfilename,'.png'); % or use .png
%exportfig(char(F),'width',12,'height',5, 'FontSize',18);
print('-dpng',char(plotfilename),'-r300')
if INI.SAVEFIGS; savefig(char(plotfilename)); end;
hold off

end


