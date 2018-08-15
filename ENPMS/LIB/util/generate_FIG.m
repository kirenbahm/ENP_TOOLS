function generate_FIG(INI,STR,T,D,S,TYPE)

keySet =   {'GW', 'PW', 'RF', 'SA','SD', 'SO', 'SW', 'SS'};
valueSet = {'ground water', 'pore water', 'rain', 'saline', 'sediment',...
   'soil', 'surface water', 'suspended solids'};
mapDataCat = containers.Map(keySet,valueSet);
TYPE_DESCR = mapDataCat(char(TYPE));

N(1) = strcat('Observed:',{' '}, TYPE, {' '},'-', {' '},TYPE_DESCR, {' '}, STR.UNIT(1));
TSTR = datestr(T,2);
TSC = tscollection(TSTR);
TTS = timeseries(D,TSTR);
TTS.TimeInfo.Format = 'mm/yy';
TTS.name = char(S);

%set(gcf, 'Color', 'w');
fig = clf;
fh = figure(fig);
CO = {'r', 'k', 'g', 'b'};
LS = {'none','-','-','-','-','-.','-.'};
M = {'s','none','none','none','none','none'};
MSZ = [ 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3];
LW = [ 1 1 1 1 1 1 1 1 1 1 3 3 3 3 3];

FS = 14;
i=1;
set(gca,'FontSize',FS,'FontName','times');
set(gca,'linewidth',LW(i));

F = plot(TTS);
X=TTS.Time;
Y=getcolumn(TTS.Data,1);
stem(X,Y,'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[1 0 0],'Color',[1 0 0]);
L = strcat(STR.ID,{' '},'(',STR.UNIT(1),')');

title(strcat(STR.NAME,{' '},'Observed:',{' '}, TYPE, {' '},'-', {' '},TYPE_DESCR, {' '}, STR.UNIT(1)));

ylabel(L);
legend(N(1));
legend boxoff;

SR=strrep(S,'.','-');
F = strcat(INI.FIGURES,SR,'.png');
exportfig(char(F),'width',12,'height',6,'FontSize',18);

end