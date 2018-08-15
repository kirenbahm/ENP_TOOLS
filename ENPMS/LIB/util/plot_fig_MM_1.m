function plot_fig_MM_1(DFS0,INI)

clf;                                          % Clears curent figure and deletes all children of the current figure

NAME = strrep(DFS0.NAME,'_',' ');

%N(1) = strcat('Computed:',{' '}, 'TP',',', {' '}, ST.OBS_UNIT(1));
N(1) = strcat(NAME,{' '}, 'Observed:',{' '}, DFS0.TYPE,',', {' '}, DFS0.UNIT);

% TSTR = datestr(DFS0.DS.MONTHS);
% TSC = tscollection(TSTR);
% TTS = timeseries(DFS0.DS.VEC_M_AVE,TSTR);
% TTS.TimeInfo.Format = 'mmm';
% TTS.name = char(NAME);
% X=TTS.Time;
% Y=getcolumn(TTS.Data,1);

[~,m,~] = datevec(DFS0.T);

%fh = figure(fig);
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

boxplot(DFS0.V,m,'notch','on','whisker',2,'labels',{'Jan','Feb',...
   'Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec',});

hold on;

L = strcat(DFS0.TYPE,',', {' '}, DFS0.UNIT);

TITLE=char(strcat(NAME,{' '}, 'Observed:',{' '}, DFS0.TYPE,',', {' '}, DFS0.UNIT));
title(TITLE);
%xlabel('Month');
ylabel(L);
legend(N(1));
legend boxoff;

[PA,NA,EXT] = fileparts(DFS0.NAME);
NA = strrep(NA,'.','_');
F = strcat(INI.DIR_DFS0_FILES,NA,'-MM','.png');
fig_plot_save(F);

end