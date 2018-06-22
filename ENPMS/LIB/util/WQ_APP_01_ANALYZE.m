function  [INI] =  WQ_APP_01_ANALYZE()
% do not modify;
[INI.ROOT,NAME,EXT] = fileparts(pwd()); % path string of ROOT Directory/
INI.ROOT = [INI.ROOT '/'];
CURRENT_PATH =[char(pwd()) '/']; % path string of folder MAIN

addpath('C:\Program Files\MATLAB\R2013a\mbin')
INI.DELETE_EXISTING_DFS0 = 1;
INI.GENERATE_DFS0 = 0;
INI.GENERATE_STAT = 1;
INI.GENERATE_FIG = 1;
addpath(genpath('C:\Program Files\MATLAB\R2013a\figuremaker'));

% end do not modify

%set by user determine where to store the results from analysis
INI.ANALYSIS_PATH = 'C:\Users\NYN\Documents\GitHub\ENPMS\DATA_TESTING\TESTING_ANALYSIS\';
INI.ResultDirHome = 'C:\Users\NYN\Documents\GitHub\ENPMS\DATA_TESTING\TESTING_SOURCE_SIMULATIONS\';
INI.ANALYSIS_PATH = 'DATA_ANALYSIS/';
INI.ResultDirHome = 'DATA_SOURCE/';
INI.FIGURES = 'DATA_FIGURES_M3ENP_EXT/';
INI.DATA_STAT = 'DATA_STAT/';
INI.FILE_STAT = [INI.DATA_STAT 'STAT-M3ENP_EXT.xlsx'];

% CHOOSE TAG FOR THIS POSTPROC RUN
INI.ANALYSIS_TAG = 'OBSERVED';
% CHOOSE BEGIN(I) AND END(F) DATES FOR POSTPROC   % note this makes black pngs for timespan<9 days

INI.ANALYZE_DATE_I = [1973 1 1 0 0 0];
INI.ANALYZE_DATE_F = [2015 12 31 0 0 0];
% CHOOSE WHICH MODULES TO RUN  1=yes, 0=no
A1 = 1 ; % Read the excel files and create the initial database

A2 = 1; A2a = 1; A3 = 1; A3a = 1; A3exp = 1; A4 = 1; A5 = 1; A6=0; A7=0;
SELECTED_STATION_LIST = 'selected_station_list-MDR.txt';
INI.DATA_OBSERVED = 'DATA_OBSERVED_20151129_M3ENP_EXT.MATLAB';

% CHOOSE SIMULATIONS TO BE ANALYZED 
% 1st cell: Results Directory, 2nd cell: simulation run, 3rd cell: legend entry
i = 0; % initialize simulation countINI
i = i + 1;  INI.MODEL_SIMULATION_SET{i} = {INI.ResultDirHome, 'ALT000_BL', 'BL'};
% i = i + 1;  INI.MODEL_SIMULATION_SET{i} = {ResultDirHome, 'ALT01P_BL_BNP25', 'BL BNP'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

INI.SELECTED_STATION_LIST = [INI.ROOT 'DATA_SOURCE/' SELECTED_STATION_LIST]; 
% The observed station data (gets loaded automatically?)

% STATION_DATA = '_MATLAB_WQ_DATA_ALL_11292015_V4-001.xlsx';
% INI.STATION_DATA   = [INI.ROOT 'APP_CREATE_DFS0/DATA_SOURCE/' STATION_DATA]; 
% 
% TP_DATA = '_MATLAB_WQ_DATA_ALL_11292015_V4-001.xlsx';
% INI.FILE_OBSERVED = [INI.ROOT 'APP_CREATE_DFS0/DATA_SOURCE/' TP_DATA]; %  all selected stations

% hidden from the user%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% adds all paths within the root repository
% recursively add local libraries and directories
try
   addpath(genpath(INI.ROOT)); 
catch
   addpath(genpath(INI.ROOT,0));
end

%if A1; READ_XCL_WQ(INI); end;

%load observed data:
load(INI.DATA_OBSERVED, '-mat');

if INI.GENERATE_DFS0
    create_DFS0(INI,mapDATA,mapSTATIONS);
end

if INI.GENERATE_STAT
    STR = generate_STAT(INI,mapDATA,mapSTATIONS);
    save_STAT(STR, INI.FILE_STAT);
end

% fclose('all');
end


function save_STAT(STR, FILE_STAT)

fprintf('%... saving statistics in %s \n', FILE_STAT);
A=struct2cell(STR);
AA(:,:) = A(:,1,:);
AAT = AA';
xlswrite(FILE_STAT,AAT,'NEW','A2');

end



function [STR] = generate_STAT(INI, mapDATA, mapSTATIONS)

i = 0;
ii = 0;

for K = keys(mapSTATIONS)
    i = i + 1;
    n = mapDATA(char(K)).WQ_N;
    fprintf('%d... Processing key %s with %d records\n', i, char(K),n(1));
    S = K;
        
    TS = mapDATA(char(K)).DATE_STR;
    D = mapDATA(char(K)).VALUE;
    U = mapDATA(char(K)).UNIT;
    ME = mapDATA(char(K)).MEDIA;
    X_UTM = mapSTATIONS(char(K)).X_UTM;
    Y_UTM = mapSTATIONS(char(K)).Y_UTM;
    SOURCE = mapSTATIONS(char(K)).SOURCE;
    M3ENP = mapSTATIONS(char(K)).M3ENP;
    M3ENP_EXT = mapSTATIONS(char(K)).M3ENP_EXT;
    I_AREA = mapSTATIONS(char(K)).I_AREA;
    N_AREA = mapSTATIONS(char(K)).N_AREA;   
        
    mapDataSplit = containers.Map();
    [mapDataSplit] = splitData(mapDataSplit,TS, D, U, ME);
    
    MT = keys(mapDataSplit);
    
    %STR = struct;
    
    for T = MT
        D = mapDataSplit(char(T)).D;
        TS = mapDataSplit(char(T)).TS;
        S = strcat(K,'-',T);
        F = [char(INI.ANALYSIS_PATH),char(K),'-WQ-',char(T),'.dfs0'];
        %STR = stat_TS(ii,STR,TS, D);
        ii = ii + 1;
        STR(ii).NAME = char(K);
        STR(ii).X_UTM = X_UTM;
        STR(ii).Y_UTM = Y_UTM;
        STR(ii).SOURCE = char(SOURCE);
        STR(ii).M3ENP = char(M3ENP);
        STR(ii).M3ENP_EXT = char(M3ENP_EXT);
        STR(ii).I_AREA = I_AREA;
        STR(ii).N_AREA = char(N_AREA);
        STR(ii).ID = char(S);
        STR(ii).FILE = char(F);
        STR(ii).MEDIA = char(T);
        STR(ii).N = length(D);
        STR(ii).MIN = min(D);
        STR(ii).MAX = max(D);
        STR(ii).MEDIAN = median(D);
        STR(ii).MEAN = mean(D);
        STR(ii).MODE = mode(D);
        STR(ii).STD = std(D);
        STR(ii).VAR = var(D);
        STR(ii).UNIT = U;
        if length(D) < 9, continue, end;
        if INI.GENERATE_FIG
            generate_FIG(INI,STR(ii),TS,D,S,T);
            generate_CDF(INI,STR(ii),TS,D,S,T);
        end
    end
    
end

end

function generate_CDF(INI,STR,T,D,S,TYPE)

keySet =   {'GW', 'PW', 'RF', 'SA','SD', 'SO', 'SW', 'SS'};
valueSet = {'ground water', 'pore water', 'rain', 'saline', 'sediment',...
    'soil', 'surface water', 'suspended solids'};
mapDataCat = containers.Map(keySet,valueSet);
TYPE_DESCR = mapDataCat(char(TYPE));

N(1) = strcat('Observed:',{' '}, TYPE, {' '},'-', {' '},TYPE_DESCR, {' '}, STR.UNIT(1));
% TSTR = datestr(T,2);
% TSC = tscollection(TSTR);
% TTS = timeseries(D,TSTR);
% TTS.TimeInfo.Format = 'mm/yy';
% TTS.name = char(S);
%TSC = addts(TSC,TTS);

% set(gcf, 'PaperUnits', 'inches');
% set(gcf, 'PaperPosition', [0,0,8,3]);
% set(gcf, 'Renderer', 'OpenGL');
%set(gcf, 'Color', 'w');
fig = clf;
fh = figure(fig);
CO = {'r', 'k', 'g', 'b'};
LS = {'none','-','-','-','-','-.','-.'};
M = {'s','none','none','none','none','none'};
MSZ = [ 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3];
LW = [ 1 1 1 1 1 1 1 1 1 1 3 3 3 3 3];

FS = 14;
i=1
set(gca,'FontSize',FS,'FontName','times');
set(gca,'linewidth',LW(i));
% F = plot(TTS,'LineWidth',LW(i), 'Linestyle', char(LS(i)), ...
%     'Color',char(CO(i)), 'Marker',char(M(i)), 'MarkerSize',MSZ(i),'LineWidth',LW(i));
% F = plot(TTS,'LineWidth',LW(i), 'Linestyle', char(LS(i)), ...
%     'Color',char(CO(i)), 'Marker',char(M(i)), 'MarkerSize',MSZ(i),'LineWidth',LW(i));
F = cdfplot(D);
% X=TTS.Time;
% Y=getcolumn(TTS.Data,1);
% stem(X,Y,'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[1 0 0],'Color',[1 0 0]);
L = strcat(STR.ID,{' '},'(',STR.UNIT(1),')');

title(strcat(STR.NAME,{' '},'Observed:',{' '}, TYPE, {' '},'-', {' '},TYPE_DESCR, {' '}, STR.UNIT(1)));

ylabel('Empirical CDF');
xlabel(L);
legend(N(1)); 
legend boxoff;

SR=strrep(S,'.','-');
F = strcat(INI.FIGURES,SR,'-CDF','.png');
exportfig(char(F),'width',12,'height',6,'FontSize',18);

end

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
%TSC = addts(TSC,TTS);

% set(gcf, 'PaperUnits', 'inches');
% set(gcf, 'PaperPosition', [0,0,8,3]);
% set(gcf, 'Renderer', 'OpenGL');
%set(gcf, 'Color', 'w');
fig = clf;
fh = figure(fig);
CO = {'r', 'k', 'g', 'b'};
LS = {'none','-','-','-','-','-.','-.'};
M = {'s','none','none','none','none','none'};
MSZ = [ 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3];
LW = [ 1 1 1 1 1 1 1 1 1 1 3 3 3 3 3];

FS = 14;
i=1
set(gca,'FontSize',FS,'FontName','times');
set(gca,'linewidth',LW(i));
% F = plot(TTS,'LineWidth',LW(i), 'Linestyle', char(LS(i)), ...
%     'Color',char(CO(i)), 'Marker',char(M(i)), 'MarkerSize',MSZ(i),'LineWidth',LW(i));
% F = plot(TTS,'LineWidth',LW(i), 'Linestyle', char(LS(i)), ...
%     'Color',char(CO(i)), 'Marker',char(M(i)), 'MarkerSize',MSZ(i),'LineWidth',LW(i));
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

function [output_args] = print_figure(S)

% NumTicks = 14; 
% L = get(gca,'XLim'); 
% set(gca,'XTick',linspace(L(1),L(2),NumTicks)); 



ax = gca; 
ax.XTickMode = 'manual';
ax.YTickMode = 'manual';
ax.ZTickMode = 'manual';

fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 12 5];
fig.PaperPositionMode = 'manual';

set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperSize', [12,5]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0,0,12,5]);
set(gca, 'Position', get(gca, 'OuterPosition') - ...
   get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
	
%set(gca,'LooseInset',get(gca,'TightInset')); % THIS IS THE NEW LINE

set(gcf, 'Renderer', 'OpenGL');


%print(char(S),'-dpng','-r600');
F=strrep(S,'.','-');
F = strcat(S,'.png');
exportfig(char(F),'Format','png','width',12,'height',6,'FontSize',12);

%exportfig(char(F),'resolution',600,'FontSize',10,'width',12,'height',6);
%saveas(gcf,char(F));

end

function STR = stat_TS(ii,STR, TS, D)
    
    STR(ii).MIN = min(D);
    STR(ii).MAX = max(D);
    STR(ii).MEDIAN = median(D);
    STR(ii).MEAN = mean(D);
    STR(ii).MODE = mode(D);
    STR(ii).STD = std(D);
    STR(ii).VAR = var(D);
    

end


function create_DFS0(INI, mapDATA, mapSTATIONS)

NET.addAssembly('DHI.Generic.MikeZero.EUM');
NET.addAssembly('DHI.Generic.MikeZero.DFS');
H = NETaddDfsUtil();
eval('import DHI.Generic.MikeZero.DFS.*');
eval('import DHI.Generic.MikeZero.DFS.dfs123.*');
eval('import DHI.Generic.MikeZero.*');

useDouble = false;

% Flag specifying wether to use the MatlabDfsUtil for writing, or whehter
% to use the raw DFS API routines. The latter is VERY slow, but required in
% case the MatlabDfsUtil.XXXX.dll is not available.
useUtil = ~isempty(H);

if (useDouble)
  dfsDT = DfsSimpleType.Double;
else
  dfsDT = DfsSimpleType.Float;
end

i = 0;

for K = keys(mapSTATIONS)
    i = i + 1;
    n = mapDATA(char(K)).WQ_N;
    fprintf('%d... Processing key %s with %d records\n', i, char(K),n(1));
    S = K;
        
    TS = mapDATA(char(K)).DATE_STR;
    D = mapDATA(char(K)).VALUE;
    U = mapDATA(char(K)).UNIT;
    ME = mapDATA(char(K)).MEDIA;
    
    mapDataSplit = containers.Map();
    [mapDataSplit] = splitData(mapDataSplit,TS, D, U, ME);
    
    MT = keys(mapDataSplit);
    
    for T = MT
        TS = mapDataSplit(char(T)).TS;
        D = mapDataSplit(char(T)).D;
        S = strcat(S,'-',T);
        F = [char(INI.ANALYSIS_PATH),char(K),'-WQ-',char(T),'.dfs0'];
                
        if INI.GENERATE_DFS0
            if (exist(F,'file') & INI.DELETE_EXISTING_DFS0), delete(F), end;
            
            if strcmp(char(T),'SO') || strcmp(char(T),'SS')
                create1DFS0_SS(S, TS, D, F, dfsDT);
            else
                create1DFS0_AQ(S, TS, D, F, dfsDT);
            end
        end
        
    end
    
end

end

function [mapDataSplit] = splitData(mapDataSplit,TS, D, U, ME)

valueSet =   {'GW', 'PW', 'RF', 'SA','SD', 'SO', 'SW', 'SS'};
keySet = {'ground water', 'pore water', 'rain', 'saline', 'sediment',...
    'soil', 'surface water', 'suspended solids'};
mapDataCat = containers.Map(keySet,valueSet);

L = unique(ME);

for i = 1:length(L)  
        iL = L{i};
        A=strcmp(ME,iL);
        IND=find(A==1);
        S.TS = TS(A);
        S.D = D(A);
        R = mapDataCat(char(iL));
        mapDataSplit(char(R)) = S;
end 

end

function create1DFS0_AQ(S, TS, D, F, dfsDT)

NET.addAssembly('DHI.Generic.MikeZero.EUM');
NET.addAssembly('DHI.Generic.MikeZero.DFS');
H = NETaddDfsUtil();
eval('import DHI.Generic.MikeZero.DFS.*');
eval('import DHI.Generic.MikeZero.DFS.dfs123.*');
eval('import DHI.Generic.MikeZero.*');
% 
    fprintf('\n       Creating file: ''%s''\n',F);  
    dfs0 = dfsTSO(char(F),1);    
    % Create an empty dfs1 file object
    factory = DfsFactory();
    builder = DfsBuilder.Create(char(S),'Matlab DFS',0);
    
    T = datevec(TS(1));
    builder.SetDataType(0);
    builder.SetGeographicalProjection(factory.CreateProjectionGeoOrigin('UTM-17',12,54,2.6));
    builder.SetTemporalAxis(factory.CreateTemporalNonEqCalendarAxis...
        (eumUnit.eumUsec,System.DateTime(T(1),T(2),T(3),T(4),T(5),T(6))));
    
    % Add an Item
    item1 = builder.CreateDynamicItemBuilder();
    item1.Set('TP Concentration', DHI.Generic.MikeZero.eumQuantity...
        (eumItem.eumIConcentration, eumUnit.eumUmilliGramPerL), dfsDT);
    item1.SetValueType(DataValueType.Instantaneous);
    item1.SetAxis(factory.CreateAxisEqD0());
    builder.AddDynamicItem(item1.GetDynamicItemInfo());

    builder.CreateFile(F);
    
    dfs = builder.GetFile();
    % Add  ata in the file
    tic
    % Write to file using the MatlabDfsUtil
    MatlabDfsUtil.DfsUtil.WriteDfs0DataDouble(dfs, NET.convertArray((TS-TS(1))*86400), ...
        NET.convertArray(D, 'System.Double', size(D,1), size(D,2)))
    toc
    
    dfs.Close();            

end

function create1DFS0_SS(S, TS, D, F, dfsDT)

NET.addAssembly('DHI.Generic.MikeZero.EUM');
NET.addAssembly('DHI.Generic.MikeZero.DFS');
H = NETaddDfsUtil();
eval('import DHI.Generic.MikeZero.DFS.*');
eval('import DHI.Generic.MikeZero.DFS.dfs123.*');
eval('import DHI.Generic.MikeZero.*');
% 
    fprintf('\nCreating file: ''%s''\n',F);  
    dfs0 = dfsTSO(F,1);    
    % Create an empty dfs1 file object
    factory = DfsFactory();
    builder = DfsBuilder.Create(char(S),'Matlab DFS',0);
    
    T = datevec(TS(1));
    builder.SetDataType(0);
    builder.SetGeographicalProjection(factory.CreateProjectionGeoOrigin('UTM-17',12,54,2.6));
    builder.SetTemporalAxis(factory.CreateTemporalNonEqCalendarAxis...
        (eumUnit.eumUsec,System.DateTime(T(1),T(2),T(3),T(4),T(5),T(6))));
    
    % Add an Item
    item1 = builder.CreateDynamicItemBuilder();
    item1.Set('TP Concentration', DHI.Generic.MikeZero.eumQuantity...
        (eumItem.eumIConcentration_4, eumUnit.eumUMilligramPerKilogram), dfsDT);
    item1.SetValueType(DataValueType.Instantaneous);
    item1.SetAxis(factory.CreateAxisEqD0());
    builder.AddDynamicItem(item1.GetDynamicItemInfo());

    builder.CreateFile(F);
    
    dfs = builder.GetFile();
    % Add  ata in the file
    tic
    % Write to file using the MatlabDfsUtil
    MatlabDfsUtil.DfsUtil.WriteDfs0DataDouble(dfs, NET.convertArray((TS-TS(1))*86400), ...
        NET.convertArray(D, 'System.Double', size(D,1), size(D,2)))
    toc
    
    dfs.Close();            

end
