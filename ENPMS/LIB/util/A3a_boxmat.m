function [] = A3a_boxmat(INI)
%{

Compute annual, monthly from .MATLAB file
and boxplot, files to DATAPOST/output/figures/boxplot
Creates a .TeX file in the latex folder: boxplot.tex,
a subsection of boxplots.
Makes an ascii file of the station, coords, statistics for GIS

v8: 2015-02-29 keb
     - changed plotting commands to be consistent with other scripts
v7a  2015-12-29 keb
    - added title string
    - added datum to ylabel if dfstype is elevation
    - fixed ylabel spacing
v7 changes:  keb 2015-11-29
   -changed function name to match filename (and incremented)
   -code was failing at 'numTS = length(DATA.MAP_ALL_DATA(char(STATIONS_LIST(1))).RUN) + 1;'
    when the first station's data was null (it copied metadata from first station).
    Added code to first find non-null station and then copy metadata.
%}

fprintf('\n Beginning A3a_boxmat: %s \n',datestr(now));

run = INI.ANALYSIS_TAG;
TS.startdate = INI.ANALYZE_DATE_I;  %start  on this date
TS.enddate = INI.ANALYZE_DATE_F;

rundir = [INI.ANALYSIS_DIR '/' run '/'];
figdir = [rundir 'figures/boxplot/'];
if ~exist(figdir,'file'),      mkdir(figdir), end  %Create a figures dir in output
% GIS file
printgis = [rundir 'statgis.asc'];
fidgis = fopen(char(printgis),'w');
% The matlab file and selected station list
DATAMATLABFILE = [rundir run '_TIMESERIES_DATA.MATLAB'];
DATA = load('-mat', DATAMATLABFILE);
% INI.SELECTED_STATIONS = get_station_list(INI.SELECTED_STATION_LIST);
% STATIONS_LIST = INI.SELECTED_STATIONS.list.stat;
STATIONS_LIST = INI.SELECTED_STATIONS;

% Copy metadata from the first non-null station
for j = 1:length(STATIONS_LIST)
    try
        numTS = length(DATA.MAP_ALL_DATA(char(STATIONS_LIST(j))).RUN) + 1;
        stn = j;
    catch
        fprintf('Did not find metadata for station %s\n', char(STATIONS_LIST(j)));
    end
end

% The no. of runs from matlab file plus observed
numTS = length(DATA.MAP_ALL_DATA(char(STATIONS_LIST(stn))).RUN) + 1;
shownumTS = numTS;

% do not include observed
if ~INI.INCLUDE_OBSERVED, shownumTS = shownumTS-1; end;

%Header line for GIS
fprintf (fidgis,'Station,X,Y');
for indx = 1:numTS - 1
    % %     %TODO: RMSE1,RMSE2, etc
    hline=[',RMSE' num2str(indx) ',NS' num2str(indx) ',BIAS' num2str(indx)];
    %fprintf (fidgis,',RMSE,NS,BIAS');
    fprintf (fidgis,hline);
end
fprintf (fidgis,'\n');

% Compute total number of days for vector,  year and month
TS = nummthyr(TS);
%start and length of timeseries in matlab file
mapstarttime = DATA.MAP_ALL_DATA(char(STATIONS_LIST(stn))).TIMEVECTOR(1);
mapendtime   = DATA.MAP_ALL_DATA(char(STATIONS_LIST(stn))).TIMEVECTOR(end);
TS.dfsstartdatetime=mapstarttime;
TS.DfsTime = mapendtime-mapstarttime;

%  Create plots for each station
for M = STATIONS_LIST
    this_station = char(M);
    
    fprintf('Station: %s',this_station);
    try
        DATASTATION = DATA.MAP_ALL_DATA(char(M));
        %NESS20OL has -1e-35 for x and y as cells?
        gse = NaN;
        try
            gse = DATASTATION.Z_GRID;
            if ~iscell(DATASTATION.X_UTM) % this throws exeption when not defined so it is not correct
                fprintf (fidgis,'%s,%7.1f,%8.1f', char(M), DATASTATION.X_UTM, DATASTATION.Y_UTM);
            else
                fprintf (fidgis,'%s,%7.1f,%8.1f', char(M), DATASTATION.X_UTM{1}, DATASTATION.Y_UTM{1});
            end
            gse = DATASTATION.Z_GRID;
        catch
            % this situation of not setup Z_GRID occurs for stations that
            % are computed but they are not in the list of monitoring
            % stations, therefore, the values are nade NaN's
            DATASTATION.X_UTM  = NaN;
            DATASTATION.Y_UTM  = NaN;
        end
        
        DATASTATION.RUN(numTS) = {'Observed'};
        %create the desired observed timeseries
        TSS(numTS).ValueVector =  TSmerge(DATASTATION.TIMESERIES(:,numTS), ...
            TS.dlength, datenum(TS.startdate), datenum(TS.enddate), ...
            TS.dfsstartdatetime, TS.DfsTime+TS.dfsstartdatetime);
        % compute the year and month averages
        OUT(numTS) = mthyr(TS, TSS(numTS).ValueVector);
        % min max for plotting
        minval(numTS) = min(min(OUT(numTS).permthave));
        maxval(numTS) = max(max(OUT(numTS).permthave));
        % the legend (plotted as text, boxplot legend is no good)
        legnd{numTS} = char(M);
        legnd{numTS+1} = [datestr(TS.startdate),' to ',datestr(TS.enddate)];
        
        for cntTS = 1:numTS
            TSS(cntTS).ValueVector =  TSmerge(DATASTATION.TIMESERIES(:,cntTS), ...
                TS.dlength, datenum(TS.startdate), datenum(TS.enddate), ...
                TS.dfsstartdatetime, TS.DfsTime+TS.dfsstartdatetime);
            legnd(cntTS) =strcat(DATASTATION.RUN(cntTS));
            % compute the year and month averages
            OUT(cntTS) = mthyr(TS, TSS(cntTS).ValueVector);
            % Statistics
            STT(cntTS) = computestats(TSS(numTS).ValueVector, TSS(cntTS).ValueVector);
            % min max for plotting
            minval(cntTS) = min(min(OUT(cntTS).permthave));
            maxval(cntTS) = max(max(OUT(cntTS).permthave));
            %
            fprintf (fidgis,',%f,%f,%f', STT(cntTS).RMSE, (STT(cntTS).NS)*100, STT(cntTS).BIAS);
        end
        fprintf (fidgis,'\n');
        minvl = min(minval);
        maxvl = max(maxval);
        %do the boxplot and print
%        plotfile = strcat(figdir, M, '.png');
        plotfile = strcat(figdir, M);
        plotboxcomb(OUT, shownumTS,INI, minvl, maxvl, legnd, plotfile,STT,gse,DATASTATION);
        
    catch
        %gse = -1.0e-035;  % line added 2015-10-13 keb because script was breaking here
        %OUT = 0;          % line added 2015-10-13 keb because script was breaking here
        %plotempty(OUT, shownumTS,INI, minvl, maxvl, legnd, plotfile,STT,gse,DATASTATION);
%        plotfile = strcat(figdir, M, '.png');
        plotfile = strcat(figdir, M);
        %plotempty(0,0,0,0,0,0,plotfile,0,0,0);
        fprintf(' not processed: no computed, no obsered data\n');
    end
end

fclose(fidgis);
fprintf('--- All Done\n');

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [output] = plotboxcomb(OUT, numTS,INI ,minvl, maxvl, legnd, plotfile,STT,gse,STATION)

fprintf(' - Plotting\n');

set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', [0,0,8,3]);
set(gcf, 'Renderer', 'OpenGL');
set(gcf, 'Color', 'w');
fig = clf;
%fh = figure(fig);
%SEE sfigure.m    set(0, 'CurrentFigure', fh);
%     f=[800,300];
%     set(fh,'units','points','position',[750,100,f(1),f(2)]);
%movegui(fh,'northeast');
fontSize=14;
set(gca, 'FontSize', fontSize)
title(char(STATION.NAME),'FontSize',14,'FontName','Times New Roman','Interpreter','none');

colorts(1:14) = INI.GRAPHICS_CO(2:15);
wdth = 0.12;
%     wid = width * ones(1,length(pos));
pos = [0.15 0.3 0.45 0.6 0.75 0.9];
shownumTS=numTS;
% do not include observed
if INI.INCLUDE_OBSERVED, shownumTS = shownumTS-1; end;

if INI.INCLUDE_OBSERVED
    positionMTH = 1+pos(numTS):1:12+pos(numTS);    % Define position for 12 Month boxplots
    boxMTH = boxplot(OUT(numTS).permthave,'colors',char(INI.GRAPHICS_CO(1)),...
        'notch','off','positions',positionMTH,'width',wdth,'labels',...
        {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'});
    plot(NaN,1,'color',char(INI.GRAPHICS_CO(1))); %// dummy plot for legend
end;
for cntTS = 1:shownumTS
    positionMTH = 1+pos(cntTS):1:12+pos(cntTS);    % Define position for 12 Month boxplots
    set(gca,'XTickLabel',{' '})  % Erase xlabels
    boxMTH = boxplot(OUT(cntTS).permthave,'colors',char(colorts(cntTS)),...
        'notch','off','positions',positionMTH,'width',wdth,'labels',...
        {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'});
    hold on  % Keep the fig for overlap
    plot(NaN,1,'color',char(colorts(cntTS))); %// dummy plot for legend
end
aymin = minvl - 0.1*(maxvl-minvl);
aymax = maxvl + 0.1*(maxvl-minvl);
%check for min=0 and max=0
if ((aymax-aymin)>0), ylim([aymin aymax]); end

legd = legnd(1:numTS);
legend(legd,7,'Location','northwest');
legend boxoff;

set(findobj(gca,'Type','text'),'FontSize',fontSize)

% Check if datatype is elevation, if so, add the datum to the y-axis label
if (strcmp(STATION.DFSTYPE,'Elevation') == 1)
    ylabel(strcat(STATION.DFSTYPE, {', '}, STATION.UNIT, {' '}, INI.DATUM));
else
    ylabel(strcat(STATION.DFSTYPE, {', '}, STATION.UNIT));
end

if (gse > -1.0e-035)
    %string_ground_level = strcat({'GSE: grid = '}, char(sprintf('%.1f',gse)), {' ft'});
    string_ground_level = '';
    add_ground_level(1.3,0.13,gse,[188/256 143/256 143/256],2,'--',12,string_ground_level);
end

axlim = axis(gca);
ylg=axlim(3);
ylgincr=0.055*(aymax-aymin);
xlg=0.75*(axlim(2)-axlim(1));
%for cnt = numTS-1:-1:1
%    ylg=ylg + ylgincr;
%legend
%        text(xlg,ylg,legnd(cnt),'Color',colorts(cnt));
%end
if INI.INCLUDE_OBSERVED
    text(xlg,ylg + ylgincr,legnd(numTS+1),'Color','k','FontSize',10);
end
%    text(xlg,ylg + 2*ylgincr,legnd(numTS),'Color','k','FontSize',14,'Interpreter','none');

% %     xaf=axlim(1)+0.75;
% %     xincr =1.00;
% %     yincr = 0.05*(aymax-aymin);
% %     %ypos = aymax -0.2;
% %     ypos = aymax - yincr*1.1;

xaf = xlg;
ypos = ylg + 1.1*(2 * ylgincr);
yincr = ylgincr;
xincr =0.80;
if INI.INCLUDE_OBSERVED
    % Statistics
    text(xaf,ypos,'RMSE  ','Color','k');
    text(xaf,ypos+yincr,'Bias ','Color','k');
    text(xaf,ypos+2*yincr,'NS ','Color','k');
    xaf = xaf + xincr;
    for cntTS = 1:numTS-1
        text(xaf,ypos,num2str(STT(cntTS).RMSE,'%6.2f'),'Color',char(colorts(cntTS)));
        text(xaf,ypos+yincr,num2str(STT(cntTS).BIAS,'%6.2f'),'Color',char(colorts(cntTS)));
        text(xaf,ypos+2*yincr,num2str(STT(cntTS).NS,'%6.2f'),'Color',char(colorts(cntTS)));
        xaf = xaf +xincr;
    end
    % Number of points
    % The last model run is used, no checks if run lengths are different
    xaf1=axlim(1)+0.15;
    ypos1 = aymin +  yincr * 1.1;
    text(xaf1,ypos1,['No. Points: ' num2str(STT(numTS-1).ALLpoints,'%6d')],'Color','k','FontSize',8);
    text(xaf1,ypos1+yincr,['No. NaN: ' num2str(STT(numTS-1).NANpoints,'%6d')],'Color','k','FontSize',8);
end
% remove outliers
hout = findobj(gca,'tag','Outliers');
for out_cnt = 1 : length(hout)
    set(hout(out_cnt), 'Visible', 'off')
end
title(STATION.NAME,'FontSize',12,'FontName','Times New Roman','Interpreter','none');
AAA = nanmean(OUT(cntTS+1).permthave);
%     Ax1 = gca
%     Ax2 = axes('Position',get(gca,'Position'),'XAxisLocation','top')
%     set(gca,'XTickLabel',num2str(AAA,'%.2f'))
%text(0.8,aymax-0.02*aymax,num2str(AAA,'%.2f'));
grid on
hold off
print('-dpng',char(plotfile),'-r300')
if INI.SAVEFIGS; savefig(char(plotfile)); end;
%imwrite(gca,char(plotfile),'png')
%export_fig  char(plotfile)   -native
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [output] = plotempty(OUT, numTS,INI,minvl, maxvl, legnd, plotfile,STT,gse,STATION)

fprintf(' - Plotting empty\n');

set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', [0,0,8,3]);
set(gcf, 'Renderer', 'OpenGL');
set(gcf, 'Color', 'w');
fig = clf;
fh = figure(fig);
f=[800,300];
set(fh,'units','points','position',[750,100,f(1),f(2)]);
fontSize=14;
set(gca, 'FontSize', fontSize)

colorts = ['k', 'g', 'b', 'm', 'b', 'k', 'g', 'c', 'm', 'k', 'g', 'b', 'm', 'b'];
wdth = 0.12;
pos = [0.15 0.3 0.45 0.6 0.75 0.9];

Y=[0];
plot(Y);

xlim([0 1]);
ylim([0 10]);
axlim = axis(gca);
xlg=axlim(1)+0.05*(axlim(2)-axlim(1));
ylg = axlim(4)-0.3*(axlim(4)-axlim(3));
ylgincr = 0.08*(axlim(4)-axlim(3));

xaf = xlg;
ypos = ylg;
yincr = ylgincr;
xincr =0.12;
% Statistics
text(xaf,ypos,'RMSE ','Color','k', 'FontSize', 16);
text(xaf,ypos+yincr,'Bias ','Color','k', 'FontSize', 16);
text(xaf,ypos+2*yincr,'NS ','Color','k', 'FontSize', 16);
xaf = xaf + xincr;
for cntTS = 1:numTS-1
    text(xaf,ypos,num2str(STT(cntTS).RMSE,'%6.2f'),'Color',colorts(cntTS), 'FontSize', 16);
    text(xaf,ypos+yincr,num2str(STT(cntTS).BIAS,'%6.2f'),'Color',colorts(cntTS), 'FontSize', 16);
    text(xaf,ypos+2*yincr,num2str(STT(cntTS).NS,'%6.2f'),'Color',colorts(cntTS), 'FontSize', 16);
    xaf = xaf +xincr;
end

hold off
print('-dpng',char(plotfile),'-r300')
% if INI.SAVEFIGS; savefig(char(plotfile)); end;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % function [fidTEX ] = openlatex(latexfile)
% %
% %     fprintf('... TeXing\n');
% %     fidTEX = fopen(latexfile,'w');
% %
% % 	row2 ='\subsection{ Box plots }';
% % 	fprintf(fidTEX,'%s\n\n',row2);
% % end
% % %%%%%%%%%%%%%%%%%%%
% % function [ ] = closelatex(fidTEX)
% %     fprintf('... closing TeXing\n');
% %     ROW5 =[' \end{center}'];
% %     ROW6 =[' \end{figure}'];
% %     fprintf(fidTEX,'%s\n',ROW5);
% %     fprintf(fidTEX,'%s\n',ROW6);
% %     fclose(fidTEX);
% % end
% % %%%%%%%%%%%%%%%%%%%
% % function [page3 ] = addtolatex(pltfile, page3,fidTEX)
% % plotfile = char(pltfile);
% %
% %     if page3 == 1
% %             ROW1 =[' \begin{figure}[!H] \begin{center}'];
% %         fprintf(fidTEX,'%s\n',ROW1);
% %     end
% %
% %     if page3 > 3
% %             ROW5 =[' \end{center}'];
% %             ROW6 =[' \end{figure}'];
% %          fprintf(fidTEX,'%s\n',ROW5);
% %         fprintf(fidTEX,'%s\n',ROW6);
% %            fprintf(fidTEX,'%s\n','\clearpage');
% %             ROW1 =[' \begin{figure}[!H] \begin{center}'];
% %         fprintf(fidTEX,'%s\n',ROW1);
% %         ROW3 =[' \includegraphics[width=6.5in]{' plotfile '}'];
% %         fprintf(fidTEX,'%s\n',ROW3);
% %             page3 = 2;
% %     else
% %             page3=page3+1;
% %         ROW3 =[' \includegraphics[width=6.5in]{' plotfile '}'];
% %
% %         fprintf(fidTEX,'%s\n',ROW3);
% %
% %       end
% %
% % end

