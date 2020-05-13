function plot_fig_TS_1(DFS0,FIG_DIR)

C = strsplit(DFS0.NAME,'.');
NAME = [C{1} ' ' C{2}];
%NAME = strrep(DFS0.NAME,'.',' ');

%N(1) = strcat('Computed:',{' '}, 'TP',',', {' '}, ST.OBS_UNIT(1));
% N(1) = strcat(NAME,{' '}, 'Observed:',{' '}, DFS0.TYPE,',', {' '}, DFS0.UNIT);

%TSTR = datetime(DFS0.T,'ConvertFrom','datenum');
%TSTR = datestr(DFS0.T);
%TSC = tscollection(DFS0.T);
TTS = timeseries(DFS0.V,datestr(DFS0.T));
%TTS = timeseries(DFS0.V,TSTR);
TTS.TimeInfo.Format = 'dd-mmm-yyyy HH:MM:SS';
TTS.name = char(NAME);
%X=TTS.Time;
%Y=getcolumn(TTS.Data,1);

clf;
%fig = clf;
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

F = plot(TTS);
F.LineStyle='none';
F.Marker='.';
F.Color = 'red';

hold on;
%Plot title
title(strcat(strrep(NAME,'_','\_'),{' '}, 'Observed:',{' '}, DFS0.TYPE,',', {' '}, DFS0.UNIT));

%Plot axis details
%L = strcat(DFS0.TYPE,',', {' '}, DFS0.UNIT);
xlabel('Month-Year');
xtickformat('MMM-yyyy');
ylabel(strcat(DFS0.TYPE,',', {' '}, DFS0.UNIT));

%Legend format
%legend(strcat(NAME,{' '}, 'Observed:',{' '}, DFS0.TYPE,',', {' '}, DFS0.UNIT));
%legend boxoff;

%Save plot as *.png
[~,NA,~] = fileparts(DFS0.NAME);
%NA = strrep(NA,'.','_');
F = strcat(FIG_DIR,NA,'-TS','.png');
fig_plot_save(F);

end
