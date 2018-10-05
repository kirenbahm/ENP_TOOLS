function plot_fig_PE_1(DFS0,FIG_DIR)

clf;                                          % Clears curent figure and deletes all children of the current figure

C = strsplit(DFS0.NAME,'.');
NAME = [C{1} ' ' C{2}];

%N(1) = strcat(NAME,{' '}, 'Observed:',{' '}, DFS0.TYPE,',', {' '}, DFS0.UNIT);
% N(2) = strcat('Computed:',{' '}, 'TP',',', {' '}, ST.OBS_UNIT(1));

%fh = figure(fig);

FS = 14;
%i=1;
set(gca,'FontSize',FS,'FontName','times');
%set(gca,'linewidth',LW(i));

%set(gca,'xscale','log');
set(gca,'yscale','log');
D = DFS0.V;
%PE = [];
PE = get_PE_plot_fig_PE_1(D);

if ~isempty(PE)
   F1 = plot(PE(:,1),PE(:,2));
   %hline = findobj(gcf, 'type', 'line');
   F1.LineStyle = 'none';
   F1.Marker = '.';
   F1.Color  = 'r';
   %set(hline(1),'Marker','o','Color','r');
end

%PE = [];
% D = ST.CDF_TPaq;
% PE = get_PE(D);
% if ~isempty(PE)
%     F2 = plot(PE(:,1),PE(:,2));
% end

grid on

% Title format
title(strcat(NAME));

% Axis format
ylabel(strcat(DFS0.UNIT));
xlabel(strcat('Probability Exceedance'));

% Legend format
legend(strcat(NAME,{' '}, 'Observed:',{' '}, DFS0.TYPE,',', {' '}, DFS0.UNIT));
legend boxoff;

% Save plot as *.png
[~,NA,~] = fileparts(DFS0.NAME);
% NA = strrep(NA,'.','_');
F = strcat(FIG_DIR,NA,'-CPE','.png');
fig_plot_save(F);


end
