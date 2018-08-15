function generate_CDF(INI,DIR,NAME,DFS0,DEXT)

%function generate_CDF(INI,STR,T,D,S,TYPE)

D = DFS0.V;

keySet =   {'GW', 'PW', 'RF', 'SA','SD', 'SO', 'SW', 'SS','Q'};
valueSet = {'ground water', 'pore water', 'rain', 'saline', 'sediment',...
   'soil', 'surface water', 'suspended solids','Discharge'};

mapDataCat = containers.Map(keySet,valueSet);
TYPE_DESCR = mapDataCat(char(DEXT));
UNIT = DFS0.UNIT;

N(1) = strcat('Observed:',{' '}, DEXT, {' '},'-', {' '},TYPE_DESCR, {' '}, UNIT);
N(1) = strcat('Observed:',{' '}, TYPE_DESCR, {' '}, UNIT);

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

F = cdfplot(D);

SR=strrep(NAME,'.','-');
SR=strrep(SR,'_','\_');

L = strcat(SR,{' '},'(',UNIT,')');

%title(strcat(NAME,{' '},'Observed:',{' '}, DEXT, {' '},'-', {' '},TYPE_DESCR, {' '}, UNIT));

ylabel('Empirical CDF');
xlabel(L);
legend(N(1));
legend boxoff;
NA = strrep(NA,'.','_');
F = strcat(DIR,'/',NAME,'-CDF','.png');
exportfig(char(F),'width',12,'height',6,'FontSize',18);

end
