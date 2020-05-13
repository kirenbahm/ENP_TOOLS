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

DFS0.TYPE = STATION.DFSTYPE;
DFS0.UNIT = STATION.UNIT;

TS = STATION.TIMESERIES;
TV = STATION.TIMEVECTOR;
[YYYY,M] = datevec(TV);
MMMM = unique(M); % list of years

n = length(TS(1,:));
SIM(1) = {'Observed'};
SIM(2:n) = INI.MODEL_RUN_DESC(1:n-1);

TV_STR = datestr(TV,2);
TMP = [];
TMP(:,1) = TS(:,length(TS(1,:)));
TMP(:,2:length(TS(1,:))) = TS(:,1:length(TS(1,:))-1);
TS = TMP;
VV = TS;

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
SIM = SIM(Z);

ii = 0;
for i = Z
    ii = ii + 1;
    T = STATION.TIMEVECTOR;
    V = VV(:,i);    
    index_nan = isnan(V);
    V(index_nan)=[];
    T(index_nan,:)=[]; %remove dates with Nan values
    [y, m] = datevec(T);
    MO = unique(m);

    kk = 0;
    for k = min(MMMM):max(MMMM) % group data according to months or years
        kk = kk + 1;
        ind = find(m==k);
        DATA{ii,kk} = V(ind);
    end
end
%DATA = fliplr(DATA);

C = []; % colors
COLORS_V = cell2mat(INI.GRAPHICS_CO(Z)')';

nsim = size(DATA);

for ii = 1:nsim(2)%:-1:1 %:nsim(2)
    for i = 1:nsim(1)%:-1:1
        if ~isempty(cell2mat(DATA(i,ii)))
            C = [C COLORS_V(:,i)];
        end
    end
end
C = fliplr(C);

if isempty(DATA)
    return
else
    ds = size(DATA);
    DataOK = false;
    for di = 1:ds(1)
        for dj = 1:ds(2)
            DataOK = DataOK || ~isempty(DATA{di,dj});
        end
    end
    if(~DataOK)
        fprintf('...All timeseries values are NaN, continue');
        return
    end
end % code to skip timeseries with zero length

% Input arguments to boxplots_N with a monthly label
XLABEL = {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
ALPHA = INI.COLORS_ALPHA;
DATA = DATA';

% set limits of y axes
max_p = ceil(max(max(STATION.TIMESERIES)));
min_p = floor(min(min(STATION.TIMESERIES)));

if max_p == min_p 
    return
end

yLim = get(gca,'YLim');

%set(gca,'YLim', [min_p max_p]);

boxplots_N(DATA,XLABEL,SIM, C, ALPHA, COLORS_V);

FS = INI.GRAPHICS_FS;
FN = INI.GRAPHICS_FN;
set(gca,'FontSize',FS,'FontName',FN);

set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', [0,0,INI.GRAPHICS_FIGUREWIDTH,INI.GRAPHICS_FIGUREHEIGHT]);
set(gcf, 'Renderer', 'OpenGL');
set(gcf, 'Color', 'w');

if strcmp(DFS0.UNIT,'ft') 
    LL = strcat(DFS0.TYPE,',', {' '}, DFS0.UNIT, {' '}, 'NGVD29');
else
    LL = strcat(DFS0.TYPE,',', {' '}, DFS0.UNIT, {' '});
end

TITLE=strcat(STATION.STATION_NAME,{' '}, LL);
%TITLE = strrep(TITLE,'_','\_');
title(TITLE);
ylabel(LL);

hold on
if strcmp(STATION.DATATYPE,'Elevation')
    if ~isnan(STATION.Z)
        %string_ground_level = strcat({'GSE: grid = '}, char(sprintf('%.1f',STATION.Z_GRID)), {' ft'});
        string_ground_level = '';
        add_ground_level(0,0.15,STATION.Z,[188/256 143/256 143/256],2,'--',12,string_ground_level);
    end
end

if INI.SAVEFIGS
    F = strcat(INI.FIGURES_DIR_BP,'/',STATION.STATION_NAME,'-YR','.fig');
end

%savefig(char(F));
F = strcat(INI.FIGURES_DIR_BP,'/',STATION.STATION_NAME,'-MO','.png');
print('-dpng',char(F),'-r300');
hold off

end
