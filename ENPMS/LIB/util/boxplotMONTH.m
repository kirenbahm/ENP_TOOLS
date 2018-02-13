function INI = boxplotMONTH(STATION,INI)
% Function which formats the data for boxplot by month

if ~any(~isnan(STATION.TIMESERIES(:)))
    fprintf('...%d All timeseries values are NaN, continue\n');
    return
end

NAME = strrep(STATION.STATION_NAME,'_','\_');

nn= size(STATION.DATA);
fig = clf;
fh = figure(fig);
%figure settings;
clf;
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', [0,0,8,3]);
set(gcf, 'Renderer', 'OpenGL');
set(gcf, 'Color', 'w');

DFS0.TYPE = STATION.DFSTYPE;
DFS0.UNIT = STATION.UNIT;

if nn(2) ~= length(INI.MODEL_RUN_DESC)
    VV = [STATION.TIMESERIES(:,end) STATION.TIMESERIES(:,1:end-1)];
    SIM = ['Observed',INI.MODEL_RUN_DESC];
    COLORS_V = cell2mat(INI.GRAPHICS_CO(1:nn(2))')';
%     COLORS_V = [COLORS_V(:,end) COLORS_V(:,1:end-1)];
else 
    SIM = INI.MODEL_RUN_DESC;
    COLORS_V = cell2mat(INI.GRAPHICS_CO(2:nn(2))')';
end

for i = 1:nn(2)
    T = STATION.TIMEVECTOR;
    V = VV(:,i);    
    [y, m] = datevec(T);
    MO = unique(m);
    kk = 0;
    for k = min(MO):max(MO) % group data according to months or years
        kk = kk + 1;
        ind = find(m==k);
        DATA{i,kk} = V(ind);
    end
end


% Input arguments to boxplots_N with a monthly label 
XLABEL = {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
ALPHA = INI.COLORS_ALPHA;
DATA = DATA';

boxplots_N(DATA,XLABEL,SIM, COLORS_V, ALPHA);

FS = INI.GRAPHICS_FS;
FN = INI.GRAPHICS_FN;
set(gca,'FontSize',FS,'FontName',FN);

% set limits of y axes
max_p = ceil(max(max(STATION.TIMESERIES)));
min_p = floor(min(min(STATION.TIMESERIES)));
yLim = get(gca,'YLim');

set(gca,'YLim', [min_p max_p]);

if strcmp(DFS0.UNIT,'ft') 
    LL = strcat(DFS0.TYPE,',', {' '}, DFS0.UNIT, {' '}, 'NGVD29');
else
    LL = strcat(DFS0.TYPE,',', {' '}, DFS0.UNIT, {' '});
end

TITLE=strcat(STATION.STATION_NAME,{' '}, LL);
title(TITLE);
ylabel(LL);

F = strcat(INI.FIGURES_DIR_BP,'/',STATION.STATION_NAME,'-MO','.png');
print('-dpng',char(F),'-r300');
hold off

end
