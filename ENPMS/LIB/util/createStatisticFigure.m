function createStatisticFigure(FileName, LegendData, OutputDir, GISDir, StartDateTime, EndDateTime, LatexFileNames)
%------------------Import Statement------------------
dmi = NET.addAssembly('DHI.Mike.Install');
if (~isempty(dmi))
    DHI.Mike.Install.MikeImport.SetupLatest({DHI.Mike.Install.MikeProducts.MikeCore});
end
NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfs0.*;
NET.addAssembly('DHI.Generic.MikeZero.EUM');
NET.addAssembly('DHI.Generic.MikeZero.DFS');
%H = NETaddDfsUtil();
eval('import DHI.Generic.MikeZero.DFS.*');
eval('import DHI.Generic.MikeZero.DFS.dfs123.*');
eval('import DHI.Generic.MikeZero.*');
%----------------------------------------------------

% Shape file layers for maps
DomainShp = [GISDir 'M06_DOMAIN.shp'];
RoadShp = [GISDir 'roads.shp'];
CanalShp = [GISDir 'sfwmd_canals.shp'];

% Dfs2 file information
dfs2File = Dfs2File(DfsFileFactory.DfsGenericOpen(FileName)); % Open dfs2 file
[~, fn, ~] = fileparts(FileName); % parse parts of filename
namesplit = split(fn,'_'); % split filename by '-'
IsDifference = LatexFileNames.IsDifference; % Finds if file was difference map
PrefixTitle = '';
PrefixFileName = '';
IsWetDry = false; % Flagged for more specific title
IsMonthly = false; % Flagged for more specific title

% Used to create Figure Titles and Figure *.png filename
if contains(FileName, 'CalYear') % For Calendar Year
    PrefixTitle = 'Annual';
    PrefixFileName = PrefixTitle;
elseif contains(FileName, 'Monthly') % For Monthly
    PrefixTitle = 'Monthly';
    PrefixFileName = PrefixTitle;
    IsMonthly = true; % Uses generic prefix but more specific time, and is flagged for later
elseif contains(FileName, 'WaterYear') % For Water Year
    PrefixTitle = 'Water Year';
    PrefixFileName = 'Water-Year';
elseif contains(FileName, 'WetDry') % For WetDry Season
    IsWetDry = true; % Uses less generic prefix, thus is flagged for creating prefix later
elseif contains(FileName, 'TotalAnalysisPeriod') % For Total Analysis Period
    PrefixTitle = 'Analysis Period';
    PrefixFileName = 'Analysis-Period';
end

HydroPeriodLatexFile = '';
StageLatexFile = '';
DepthLatexFile = '';
PondingDepthLatexFile = '';

% If is difference, finds the alternative to determine 
% which latex outfiles to write to 
if IsDifference
    alternative = split(namesplit{1}, '-');
    ai = 1;
    % Loop through alternative names for find correct index
    for i = 1:size(LatexFileNames.ModelOrder, 1)
        if strcmp(LatexFileNames.ModelOrder{i}, alternative{1})
            break;
        end
        ai = ai + 2;
    end
    % Finds the Hydroperiod and Stage Latex files to write to
    HydroPeriodLatexFile = LatexFileNames.FileNames{ai};
    StageLatexFile = LatexFileNames.FileNames{ai + 1};
elseif IsMonthly
    % Finds the Stage and Depth Latex files to write to
    StageLatexFile = LatexFileNames.FileNames{5};
    DepthLatexFile = LatexFileNames.FileNames{6};
else
    % Finds the Hydroperiod, Stage, Depth, and Ponding Depth Latex files to write to
    HydroPeriodLatexFile = LatexFileNames.FileNames{1};
    StageLatexFile = LatexFileNames.FileNames{2};
    DepthLatexFile = LatexFileNames.FileNames{3};
    PondingDepthLatexFile = LatexFileNames.FileNames{4};
end
% First Time Step
TimeStart = dfs2File.FileInfo.TimeAxis.StartDateTime;
% Save File TimeAxis
TimeAxis = dfs2File.FileInfo.TimeAxis;
D0 = datetime(TimeStart.Year, TimeStart.Month, TimeStart.Day, TimeStart.Hour,...
    TimeStart.Minute, TimeStart.Second);% First File Time Step DateTime

% Projection Information and Spatial Axis
ProjLong = dfs2File.FileInfo.Projection.Longitude;
ProjLat = dfs2File.FileInfo.Projection.Latitude;
SpatialAxis = dfs2File.SpatialAxis;
XLimits = [double(SpatialAxis.X0) double(SpatialAxis.X0 + (SpatialAxis.Dx * SpatialAxis.XCount))];
YLimits = [double(SpatialAxis.Y0) double(SpatialAxis.Y0 + (SpatialAxis.Dy * SpatialAxis.YCount))];
noData = dfs2File.FileInfo.DeleteValueFloat;
RasterSize = [double(SpatialAxis.YCount) double(SpatialAxis.XCount)];
R = maprefcells(XLimits, YLimits, RasterSize);

% For each item in file
for nI = 1:dfs2File.ItemInfo.Count
    ItemName = char(dfs2File.ItemInfo.Item(nI - 1).Name); % save item name
    TitleFront = ''; % Initialize Title
    PlotName = ''; % Initalize File Name
    LegendTitle = '';
    if contains(ItemName, 'Fraction') % Don't make figure for Hydroperiod Fraction
        continue;
    elseif contains(ItemName, 'water level') && ~IsDifference % mean water level, but not a DifferenceMap
        LegendValues = LegendData.StageValues; % Save Symbol Colormap
        LegendColorMap = LegendData.StageColorMap;
        SymbolLabels = LegendData.StageLabels; % Save Legend Labels
        TitleFront = strcat(PrefixTitle, ' Average Stage (ft) -  '); % add prefix and item to title
        PlotName = strcat(PrefixFileName, '-Stage'); % add prefix and item to filename
        ActiveLatex = StageLatexFile;
        LegendTitle = 'Stage (ft)';
    elseif contains(ItemName, 'water level') && IsDifference % mean water level and a DifferenceMap
        LegendValues = LegendData.ElevDiffValues; % Save Symbol Colormap
        LegendColorMap = LegendData.ElevDiffColorMap;
        SymbolLabels = LegendData.ElevDiffLabels; % Save Legend Labels
        TitleFront = strcat(PrefixTitle, ' Average Stage Difference (ft) -  ');% add prefix and item to title
        PlotName = strcat(PrefixFileName, '-StageDiff'); % add prefix and item to filename
        ActiveLatex = StageLatexFile;
        LegendTitle = 'Stage (ft)';
    elseif contains(ItemName, 'water depth') && ~IsDifference % mean water depth, but not a DifferenceMap
        LegendValues = LegendData.DepthValues; % Save Symbol Colormap
        LegendColorMap = LegendData.DepthColorMap;
        SymbolLabels = LegendData.DepthLabels; % Save Legend Labels
        if contains(ItemName, 'discontinuous') % mean water depth during discontinuous hydroperiod
            TitleFront = strcat(PrefixTitle, ' Average Ponding Depth (ft) -  '); % add prefix and item to title
            PlotName = strcat(PrefixFileName, '-PondingDepth'); % add prefix and item to filename
            ActiveLatex = PondingDepthLatexFile;
            LegendTitle = 'Ponding Depth (ft)';
        elseif contains(ItemName, 'max continuous')% mean water depth during max continuous hydroperiod
            TitleFront = strcat(PrefixTitle, ' Average Ponding Depth (ft) during Max Continuous Hydroperiod -  ');% add prefix and item to title
            PlotName = strcat(PrefixFileName, '-PondingDepthMaxHydroperiod'); % add prefix and item to filename
            ActiveLatex = PondingDepthLatexFile;
            LegendTitle = 'Ponding Depth (ft)';
        else % mean water depth
            TitleFront = strcat(PrefixTitle, ' Average Water Depth (ft) -  ');% add prefix and item to title
            PlotName = strcat(PrefixFileName, '-Depth'); % add prefix and item to filename
            ActiveLatex = DepthLatexFile;
            LegendTitle = 'Water Depth (ft)';
        end
    elseif contains(ItemName, 'water depth') && IsDifference % mean water depth and a DifferenceMap
        LegendValues = LegendData.ElevDiffValues; % Save Symbol Colormap
        LegendColorMap = LegendData.ElevDiffColorMap;
        SymbolLabels = LegendData.ElevDiffLabels; % Save Legend Labels
        ActiveLatex = StageLatexFile;
        if contains(ItemName, 'discontinuous') % mean water depth during discontinuous hydroperiod
            TitleFront = strcat(PrefixTitle, ' Average Ponding Depth Difference (ft)-  '); % add prefix and item to title
            PlotName = strcat(PrefixFileName, '-PondingDepthDiff'); % add prefix and item to filename
            LegendTitle = 'Ponding Depth (ft)';
        elseif contains(ItemName, 'max continuous')% mean water depth during max continuous hydroperiod
            TitleFront = strcat(PrefixTitle, ' Average Ponding Depth During Max Continuous Hydroperiod Difference (ft)-  ');% add prefix and item to title
            PlotName = strcat(PrefixFileName, '-PondingDepthMaxHydroperiodDiff'); % add prefix and item to filename
            LegendTitle = 'Ponding Depth (ft)';
        else % mean water depth
            TitleFront = strcat(PrefixTitle, ' Average Water Depth Difference (ft)-  ');% add prefix and item to title
            PlotName = strcat(PrefixFileName, '-DepthDiff'); % add prefix and item to filename
            LegendTitle = 'Water Depth (ft)';
        end
    elseif contains(ItemName, 'hydroperiod') && ~IsDifference % Hydroperiod but not a DifferenceMap
        LegendValues = LegendData.HPValues; % Save Symbol Colormap
        LegendColorMap = LegendData.HPColorMap;
        SymbolLabels = LegendData.HPLabels; % Save Legend Labels
        ActiveLatex = HydroPeriodLatexFile;
        if contains(ItemName, 'hydroperiod1') % If discontinuous hydroperiod
            TitleFront = strcat(PrefixTitle, ' Hydroperiod Distribution (days)-  ');% add prefix and item to title
            PlotName = strcat(PrefixFileName, '-DisconHydroperiod');% add prefix and item to filename
            LegendTitle = 'Hydroperiod Class';
        else % else max continuous hydroperiod
            TitleFront = strcat(PrefixTitle, ' Max Continuous Hydroperiod Distribution (days)-  ');% add prefix and item to title
            PlotName = strcat(PrefixFileName, '-MaxConHydroperiod');% add prefix and item to filename
            LegendTitle = 'Hydroperiod Class';
        end
    elseif contains(ItemName, 'hydroperiod') && IsDifference % Hydroperiod and a DifferenceMap
        LegendValues = LegendData.HPDiffValues; % Save Symbol Colormap
        LegendColorMap = LegendData.HPDiffColorMap;
        SymbolLabels = LegendData.HPDiffLabels; % Save Legend Labels
        ActiveLatex = HydroPeriodLatexFile;
        if contains(ItemName, 'hydroperiod1') % If discontinuous hydroperiod
            TitleFront = strcat(PrefixTitle, ' Hydroperiod Difference Distribution (days)-  ');% add prefix and item to title
            PlotName = strcat(PrefixFileName, '-DisconHydroperiodDiff-');% add prefix and item to filename
            LegendTitle = 'Hydroperiod Class';
        else % else max continuous hydroperiod
            TitleFront = strcat(PrefixTitle, ' Max Continuous Hydroperiod Difference Distribution (days)-  ');% add prefix and item to title
            PlotName = strcat(PrefixFileName, '-MaxConHydroperiodDiff-');% add prefix and item to filename
            LegendTitle = 'Hydroperiod Class';
        end
    end
    fprintf('......Creating Figures for item %s\n', ItemName);
    ConversionFactor = 1; % If file is in Meters, convert to feet
    if strcmp(dfs2File.ItemInfo.Item(nI - 1).Quantity.Unit, 'eumUmeter')
        ConversionFactor = 1/0.3048; % convert to feet
    end
    
    % Writes a Section start to the respective Latex File
    if IsWetDry 
        generate_latex_blocks_maps(ActiveLatex, 2, 'Wet/Dry Season');
    else
        generate_latex_blocks_maps(ActiveLatex, 2, PrefixTitle);
    end
    for ti = 0:TimeAxis.NumberOfTimeSteps - 1 % For each timestep in file
        ItemData2D = dfs2File.ReadItemTimeStep(nI, ti); % Read dfs2 for item at time step
        currentDateTime = D0 + (ItemData2D.Time / 86400); % Find DateTime of Data
        if currentDateTime < StartDateTime % If before Analysis Period Start, move to next time step
            continue;
        elseif currentDateTime > EndDateTime % If after Analysis Period End, stop.
            break;
        end
        fprintf('........Creating Figures for Timestep %i / %i\n', ti + 1, TimeAxis.NumberOfTimeSteps);
        % For legend
        TitleText = ''; % Initialize final variable for title text
        YearStr = num2str(currentDateTime.Year); % turn year to string
        if IsWetDry % If Wet/Dry Seasons
            if currentDateTime.Month == 6 % If timestep is June, Wet Season
                TitleText = strcat('Wet Season ', TitleFront, '  ', YearStr); % final title
                plotfilename = strcat('Wet', PlotName, '-', YearStr); % final filename
            else % else, Dry Season
                TitleText = strcat('Dry Season ', TitleFront, '  ', YearStr);  % final title
                plotfilename = strcat('Dry', PlotName, '-', YearStr); % final filename
            end
        elseif IsMonthly % If monthly use Month and Year in title and filename
            TitleText = strcat(TitleFront, '  ', num2str(currentDateTime.Month), '/', YearStr); % final title
            plotfilename = strcat(PlotName, '-',  YearStr, '-',num2str(currentDateTime.Month, '%02i'));  % final filename
        else
            TitleText = strcat(TitleFront, '  ', YearStr); % final title
            plotfilename = strcat(PlotName, '-', YearStr);  % final filename
        end
        ItemData = double(ItemData2D.Data); % Convert from 2D array to 1D array
        clf % Clear Figure
        gca = axesm ('utm', 'Frame', 'off', 'Grid', 'off'); % Create a UTM map, turn the Frame on, and Grid On
        zone = utmzone(ProjLat, ProjLong); % Find the UTM zone, from dfs2 Projection Latitude and Longitude
        setm(gca, 'zone', zone) % set UTM map to specified zone
        
        % Uses the dfs2 X and Y Limits to limit map to model area
        % Limits are extended to allow space for map elements without
        % covering raster
        XLim = [XLimits(1) * (0.92) XLimits(2) * (1.02)];
        YLim = [YLimits(1) * (0.995) YLimits(2) * (1.002)];
        set(gca, 'XLim', XLim, 'YLim', YLim);
        
        % draws data from shape files to map
        mapshow(DomainShp,'FaceColor','none', 'EdgeColor', 'black');
        mapshow(RoadShp,'Color','black', 'LineWidth', 1);
        mapshow(CanalShp,'Color','blue', 'LineWidth', 1);
        
        %-------------Creates Raster from Dfs2-------------%
        % reshape 1D array to 2D array
        Z = reshape(ItemData, SpatialAxis.XCount, SpatialAxis.YCount);
        Z(Z == noData) = NaN; % replaces NoData values with NaN so they won't be drawn
        Z = Z * ConversionFactor; % converts from meters to feet if necessary
        % draws raster to map
        % has values minus 1000, so raster will draw under shape files 
        rasterMap = mapshow(Z' - 1000, R, 'DisplayType', 'surface');
        ColorMap = [];
        ii = 1;
        clear p;
        % constructs color scale
        for r = 1:size(LegendValues,1)
            % finds indexes for values in range of current step of color
            % scale, corrected for offset
            ci = rasterMap.ZData + 1000 >= LegendValues(r,1) & rasterMap.ZData + 1000 < LegendValues(r,2);
            rasterMap.CData(ci) = r; % Maps those indexes to correct color
            p(r) = patch(NaN, NaN, LegendColorMap(r,:)); % makes patch of color for legend
            % add color to colormap
            if any(any(ci))
                if isempty(ColorMap)
                    ColorMap = LegendColorMap(r,:);
                else
                    ColorMap = [ColorMap; LegendColorMap(r,:)];
                end
            end
        end
        % colors raster with contructed colormap
        colormap(ColorMap);
        %-------------------------------------------------%
        
        % Lower limit is Origin Lat long from dfs2 projection pushed out a bit
        % Map USA Coastline to figure, builtin shape file from Matlab Mapping Toolbox
        hleg = legend(p, SymbolLabels, 'Location', 'west', 'AutoUpdate', 'off', 'FontSize', 6);
        
        title(hleg, LegendTitle); % Title Legend
        title(TitleText);
        % Used to Alter Figure Title Font Size to fit in Figure
        ax = gca;
        ax.TitleFontSizeMultiplier = 1;
        
        
        % Adds Arrow pointing north to top right of map
        % TODO Use Projection and Spatial Axis to find Lat long position
        northarrow('latitude', 25.9, 'longitude', -80.25);
        h = handlem('NorthArrow');
        set(h,'FaceColor','white',...
            'EdgeColor','black')
        
        % Adds Scale to bottom of the map
        scaleruler('units', 'Miles', 'RulerStyle', 'patches'); % Set Units to Miles
        setm(handlem('scaleruler1'),...
            'XLoc', dfs2File.SpatialAxis.X0 + 24000,... % Set Location below and to the right of dfs2 Origin
            'YLoc', dfs2File.SpatialAxis.Y0 - 8000,...
            'MajorTick', 0:10:40, 'MinorTick', 0:5:10,...
            'MajorTickLength', 1) % Set Major and Minor ticks
        % Saves figure, as png, with specified filename, at a specific resolution
        dateparse = split(datestr(now), ' ');
        text(dfs2File.SpatialAxis.X0 - 12000, dfs2File.SpatialAxis.Y0 - 11000,...
            strcat('Plot Date: ', dateparse(1)), 'FontSize', 9);
        
        % saves figure as png
        print('-dpng',char(strcat(OutputDir, namesplit(1), '-', plotfilename)),'-r300')
        
        % writes figure to latex file
        generate_latex_blocks_maps( ActiveLatex, 3, TitleText, strcat(namesplit{1}, '-', plotfilename, '.png') )
    end
end
end
