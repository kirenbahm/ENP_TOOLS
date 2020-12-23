function plot_fig_YY_1(DFS0,FIG_DIR)

clf;                                          % Clears curent figure and deletes all children of the current figure

NAME = strrep(DFS0.NAME,'_','\_');

%N(1) = strcat('Computed:',{' '}, 'TP',',', {' '}, ST.OBS_UNIT(1));
N(1) = strcat(NAME,{' '}, 'Observed:',{' '}, DFS0.TYPE,',', {' '}, DFS0.UNIT);

% TSTR = datestr(DFS0.DS.MONTHS);
% TSC = tscollection(TSTR);
% TTS = timeseries(DFS0.DS.VEC_M_AVE,TSTR);
% TTS.TimeInfo.Format = 'mmm';
% TTS.name = char(NAME);
% X=TTS.Time;
% Y=getcolumn(TTS.Data,1);

[y,~,~] = datevec(DFS0.T);
YY = unique(y);
% Fills years where there is no data with NaN values
for i = 2:size(y,1) 
    if y(i) - y(i - 1) > 1 % detects if a year has no data entries
        y = cat(1, y(1:i - 1), [y(i - 1) + 1], y(i:end)); % Inserts year
        DFS0.V = cat(1, DFS0.V(1:i - 1), [NaN], DFS0.V(i:end)); % inserts NaN
    end 
end

%set(gca,'yscale','log');

CO = {'r', 'k', 'g', 'b'};
LS = {'none','-','-','-','-','-.','-.'};
M = {'s','none','none','none','none','none'};
MSZ = [ 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3];
LW = [ 1 1 1 1 1 1 1 1 1 1 3 3 3 3 3];

FS = 14;
i=1;
set(gca,'FontSize',FS,'FontName','times');
set(gca,'linewidth',LW(i));

boxplot(DFS0.V,y, 'Notch','on','Whisker',2);
set(gca,'XTickMode','auto');
set(gca,'XTickLabelMode','auto');
set(gca,'XMinorTick','on');
get(gca,'XTick'); %0     7    12    17    22    27    32    37    40

get(gca,'XTickLabel');
XLIM = get(gca,'XLim');

AXTICK = linspace(XLIM(1),XLIM(2),10);
AXTICKLAB = num2cell(uint32(linspace(YY(1),YY(end),10)));
set(gca,'XTick',AXTICK);
set(gca,'XTickLabel',AXTICKLAB);

hold on;

L = strcat(DFS0.TYPE,',', {' '}, DFS0.UNIT);

TITLE=char(strcat(NAME,{' '}, 'Observed:',{' '}, DFS0.TYPE,',', {' '}, DFS0.UNIT));
title(TITLE);
%xlabel('Month');
ylabel(L);
%legend(N);
%legend boxoff;

[~,NA,~] = fileparts(DFS0.NAME);
% NA = strrep(NA,'.','_');
F = strcat(FIG_DIR,NA,'-YY','.png');
fig_plot_save(F);
end
