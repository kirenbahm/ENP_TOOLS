function INI = boxplotYEAR(STATION,INI)
% Fucntion which formats data to be provided for boxplot by year

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

DFS0.TYPE = STATION.DFSTYPE;
DFS0.UNIT = STATION.UNIT;

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
VV = TS;

% if nn(2) ~= length(INI.MODEL_RUN_DESC)
%     VV = [STATION.TIMESERIES(:,end) STATION.TIMESERIES(:,1:end-1)];
%     SIM = ['Observed',INI.MODEL_RUN_DESC];
%     COLORS_V = cell2mat(INI.GRAPHICS_CO(1:nn(2))')';
% %     COLORS_V = [COLORS_V(:,end) COLORS_V(:,1:end-1)];
% else 
%     SIM = INI.MODEL_RUN_DESC;
%     COLORS_V = cell2mat(INI.GRAPHICS_CO(2:nn(2))')';
% end

if INI.INCLUDE_OBSERVED & INI.INCLUDE_COMPUTED
    Z = [1:n]; % observed is in column sz+1
end
if INI.INCLUDE_OBSERVED & ~INI.INCLUDE_COMPUTED
    Z = [1];
end
if ~INI.INCLUDE_OBSERVED & INI.INCLUDE_COMPUTED
    Z = [2:n];
end

DATA = [];
for i = 1:Z
    T = STATION.TIMEVECTOR;
    V = VV(:,i);    
    index_nan = isnan(V);
    V(index_nan)=[];
    T(index_nan,:)=[]; %remove dates with Nan values
    [y, m] = datevec(T);
    YR = unique(y);
    
    kk = 0;
    for k = min(YR):max(YR) % group data according to months or years
        kk = kk + 1;
        ind = find(y==k);
        DATA{i,kk} = V(ind);
    end
end

COLORS_V = cell2mat(INI.GRAPHICS_CO(Z)')';
SIM = SIM(Z);

if isempty(DATA)
    return
end % code to skip timeseries with zero length

% Input arguments to boxplots_N with a Year label 
XLABEL = num2str(YR);

ALPHA = INI.COLORS_ALPHA;
DATA = DATA';

boxplots_N(DATA,XLABEL,SIM, COLORS_V, ALPHA);

FS = INI.GRAPHICS_FS;
FN = INI.GRAPHICS_FN;
set(gca,'FontSize',FS,'FontName',FN);

set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', [0,0,8,3]);
set(gcf, 'Renderer', 'OpenGL');
set(gcf, 'Color', 'w');

% set limits of y axes
max_p = ceil(max(max(STATION.TIMESERIES)));
min_p = floor(min(min(STATION.TIMESERIES)));

if max_p == min_p 
    return
end

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

F = strcat(INI.FIGURES_DIR_BP,'/',STATION.STATION_NAME,'-YR','.png');
print('-dpng',char(F),'-r300');
hold off

end