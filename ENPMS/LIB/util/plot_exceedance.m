function [] = plot_exceedance(STATION,INI)

% v3c: 2015-12-20 keb
%     - added logic to print model data even when no observed data was present
%     - changed font
%      2016-01-08 keb
%     - fixed bug where incorrect TS was being plotted for TS with no obs
% v3b: 2015-12-30 keb - added datum to ylabel if dfstype is elevation
% v3a  2015-12-29 keb  changed title string

F.XLABEL = 'Exceedance Probability'; % this provides a horizontal label
F.CO = INI.GRAPHICS_CO;
F.LS = INI.GRAPHICS_LS;
F.M = INI.GRAPHICS_M;
F.MSZ = INI.GRAPHICS_MSZ;
F.LW = INI.GRAPHICS_LW;
F.TS_DESCRIPTION = {'Observed'};  %description of observed data
F.TITLE = STATION.NAME;

% Check if datatype is elevation, if so, add the datum to the y-axis label
if (strcmp(STATION.DFSTYPE,'Elevation') == 1)
    F.YLABEL = strcat(STATION.DFSTYPE, {', '}, STATION.UNIT, {' '}, INI.DATUM);
else
    F.YLABEL = strcat(STATION.DFSTYPE, {', '}, STATION.UNIT);
end

try
    MAP_NAN = STATION.TS_NAN;
catch
    fprintf('...TS_NAN not defined in plot_exceedance, skipping\n');
    return;
end

MAP_KEYS = keys(MAP_NAN);
N = length(MAP_KEYS);

NAME = STATION.NAME;
X = STATION.X_UTM;
Y = STATION.Y_UTM;
YLABEL = F.YLABEL;
XLABEL = F.XLABEL;

set(gcf, 'PaperUnits', 'inches');
%set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0,0,8,3]);
set(gcf, 'Renderer', 'OpenGL');
set(gcf, 'Color', 'w');
fig = clf;
%fh = figure(fig);
% % strDI = datestr(INI.ANALYZE_DATE_I,2);
% % strDF = datestr(INI.ANALYZE_DATE_F,2);
%F.YLABEL = strcat(STATIO
% plot observed as the first item
%DMATRIX = MAP_NAN(char(MAP_KEYS(1))).TS;
%DM_HEADER = MAP_NAN(char(MAP_KEYS(1))).TS_HEADER;

legnd1 = '';

if (INI.INCLUDE_OBSERVED == 'YES')
    % plot observed as the first item
    DMATRIX = MAP_NAN(char(MAP_KEYS(1))).TS;
    if ~isempty(DMATRIX)
        XM = DMATRIX(:,8); %descending values
        YM = DMATRIX(:,6); %probability values
        H = plot(XM, YM,'LineWidth',F.LW(1), 'Linestyle', char(F.LS(1)), ...
            'Color',char(F.CO(1)), 'Marker',char(F.M(1)), 'MarkerSize',...
            F.MSZ(1),'LineWidth',F.LW(1));
        %TODO, the actual file used for observed    legnd1 = ['Observed  ' char(STATION.NAME)];
        legnd1 = 'Observed';
    end
end

hold on
i = 2;
NSS(2:N+1) = INI.MODEL_RUN_DESC(1:N);
for ii = 2:N+1      % add model runs
    MK = NSS(ii);
    DMATRIX = MAP_NAN(char(MK)).TS;
    if ~isempty(DMATRIX) % if DMATRIX (TS_NAN) has values, plot it
        XM = DMATRIX(:,8); %descending values
        YM = DMATRIX(:,5); %probability values
        H = plot(XM, YM,'LineWidth',F.LW(i), 'Linestyle', char(F.LS(i)), ...
            'Color',char(F.CO(i)), 'Marker',char(F.M(i)), 'MarkerSize',...
            F.MSZ(i),'LineWidth',F.LW(i));
    else
        % else if there was no observed data, DMATRIX (TS_NAN) is empty.
        % instead of not plotting any model data, plot the complete set of
        % model data. Because only TS_NAN was sorted and assigned
        % probability values, we will need to do the same for the
        % TIMESERIES.
        % first, sort the data values (using i-1 because station.timeseries
        % has not been re-ordered to have the obs data in the first column)
        YM = sort(STATION.TIMESERIES(:,i-1),'descend');
        % determine percentage of the whole for each value
        arrayIncrement = 1 / (length(STATION.TIMESERIES));
        % create an even array of probability values that will correspond to
        % (sorted) data values. ie if there are 200 data values, then to
        % create an even array from 0 to 1 you will have an arrayIncrement
        % of 0.5. Need to make array 1 increment shorter to properly match up
        % with data array.
        XM = 0:arrayIncrement:1-arrayIncrement;
        H = plot(XM, YM,'LineWidth',F.LW(i), 'Linestyle', char(F.LS(i)), ...
            'Color',char(F.CO(i)), 'Marker',char(F.M(i)), 'MarkerSize',...
            F.MSZ(i),'LineWidth',F.LW(i));
    end
    i = i + 1;
end


nn = length(MAP_KEYS)+1;
if (isvarname(legnd1))
    NN(1) = {legnd1};
    NN(2:nn) = INI.MODEL_RUN_DESC(1:nn-1);
else
    NN(1:nn-1) = INI.MODEL_RUN_DESC(1:nn-1);
end

legt = NN;
set(get(gca,'YLabel'),'String',YLABEL,'FontName','times','FontSize',12);
legend(legt,'Location','NorthEast');
legend boxoff;
grid on;
s_title = char(STATION.NAME);
title(s_title,'FontSize',12,'FontName','times','Interpreter','none');

try
    STATION.Z_GRID = cell2mat(INI.MAPXLS.MSHE(char(STATION.NAME)).gridgse);
catch
    STATION.Z_GRID = -1.0e-35;
end

if (STATION.Z_GRID > -1.0e-035)
    %string_ground_level = strcat({'GSE: grid = '}, char(sprintf('%.1f',STATION.Z_GRID)), {' ft'});
    string_ground_level = '';
    add_ground_level(0,0.15,STATION.Z_GRID,[188/256 143/256 143/256],2,'--',12,string_ground_level);
end

plotfile = strcat(INI.FIGURES_DIR_EXC,'/',STATION.NAME);
print('-dpng',char(plotfile),'-r300')
if INI.SAVEFIGS; savefig(char(plotfile)); end;

hold off

end

