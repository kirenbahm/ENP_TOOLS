function [H,P] = plot_fig_CDF_1(DFS0,FIG_DIR)

clf;                                          % Clears curent figure and deletes all children of the current figure

NAME = strrep(DFS0.NAME,'_',' ');

N(1) = strcat(NAME,{' '}, 'Observed:',{' '}, DFS0.TYPE,',', {' '}, DFS0.UNIT);
% N(2) = strcat('Computed:',{' '}, 'TP',',', {' '}, ST.OBS_UNIT(1));

%fh = figure(fig);

FS = 14;
i=1;
set(gca,'FontSize',FS,'FontName','times');
%set(gca,'linewidth',LW(i));

hold on
set(gca,'xscale','linear');
D1 = DFS0.V;
if ~isempty(D1)
   [F,X,FLO,FUP] = ecdf(D1,'bounds','on');
   ecdf(D1,'bounds','on');
   hline = findobj(gcf, 'Type', 'Stair');
   set(hline(1),'Color','b');
   set(hline(2),'Color','b');
   set(hline(3),'Color','r');
   %set(hline(3),'Marker','o','Color','r','MarkerFaceColor','auto');
end

L = strcat(DFS0.TYPE,',', {' '}, DFS0.UNIT);

title=strcat(NAME,{' '}, 'Observed:',{' '}, DFS0.TYPE,',', {' '}, DFS0.UNIT);

ylabel('Cumulative Probability');
xlabel(L);
%legend(N);
%legend boxoff;

[~,NA,~] = fileparts(DFS0.NAME);
% NA = strrep(NA,'.','_');
F = strcat(FIG_DIR,NA,'-CDF','.png');
fig_plot_save(F);

end
