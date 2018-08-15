function plot_fig_CUMULATIVE_1(DFS0,INI)

clf;                                          % Clears curent figure and deletes all children of the current figure

C = strsplit(DFS0.NAME,'.');
NAME = [C{1} ' ' C{2}];

%N(1) = strcat('Computed:',{' '}, 'TP',',', {' '}, ST.OBS_UNIT(1));
TYPE = 'Cumulative Discharge';
UNIT = '1,000 ac-ft';

%N(1) = strcat(NAME,{' '}, 'Cumulative:',{' '}, TYPE,',', {' '}, UNIT);

% TSTR = datestr(DFS0.T,2);
% TSC = tscollection(TSTR);

%DATAV = DFS0.V;

%TSTR = datestr(DFS0.DS.T_NAN);
%TSC = tscollection(TSTR);
TTS = timeseries(DFS0.DS.Q_SUM,datestr(DFS0.DS.T_NAN));
TTS.TimeInfo.Format = 'dd-mmm-yyyy HH:MM:SS';
TTS.name = char(NAME);
%X=TTS.Time;
%Y=getcolumn(TTS.Data,1);

%fh = figure(fig);
%set(gca,'yscale','log');

% CO = {'r', 'k', 'g', 'b'};
% LS = {'none','-','-','-','-','-.','-.'};
% M = {'s','none','none','none','none','none'};
% MSZ = [ 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3];
LW = [ 1 1 1 1 1 1 1 1 1 1 3 3 3 3 3];

FS = 14;
i=1;
set(gca,'FontSize',FS,'FontName','times');
set(gca,'linewidth',LW(i));

plot(TTS);
hold on;

%L = strcat(TYPE,',', {' '}, UNIT);

% Plot format
title(strcat(NAME,{' '}, 'Observed:',{' '}, DFS0.TYPE,',', {' '}, DFS0.UNIT));

% Axis format
xlabel('Month-Year');
xtickformat('MMM-yyyy');
ylabel(strcat(TYPE,',', {' '}, UNIT));

% Legend format
legend(strcat(NAME,{' '}, 'Cumulative:',{' '}, TYPE,',', {' '}, UNIT));
legend boxoff;

[~,NA,~] = fileparts(DFS0.NAME);
NA = strrep(NA,'.','_');
F = strcat(INI.DIR_DFS0_FILES,NA,'-CU','.png');
fig_plot_save(F);

end