function createStatisticFigure(FileName, GridCells, LegendData, OutputDir)
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


dfs2File = Dfs2File(DfsFileFactory.DfsGenericOpen(FileName)); % Open dfs2 file
[~, fn, ~] = fileparts(FileName); % parse parts of filename
namesplit = split(fn,'_'); % split filename by '_'
IsDifference = contains(FileName, 'Diff'); % Finds if file was difference map
Prefix = '';
IsWetDry = false; % Flagged for more specific title
IsMonthly = false; % Flagged for more specific title
% Used to create Figure Titles and Figure *.png filename
if contains(FileName, 'CalYear') % For Calendar Year
    Prefix = 'Annual';
elseif contains(FileName, 'Monthly') % For Monthly
    Prefix = 'Monthly';
    IsMonthly = true; % Uses generic prefix but more specific time, and is flagged for later
elseif contains(FileName, 'WaterYear') % For Water Year
    Prefix = 'Water Year';
elseif contains(FileName, 'WetDry') % For WetDry Season
    IsWetDry = true; % Uses less generic prefix, thus is flagged for creating prefix later
elseif contains(FileName, 'TotalAnalysisPeriod') % For Total Analysis Period
    Prefix = 'Analysis Period';
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

% For each item in file
for nI = 1:dfs2File.ItemInfo.Count
    ItemName = char(dfs2File.ItemInfo.Item(nI - 1).Name); % save item name
    TitleFront = ''; % Initialize Title
    PlotName = ''; % Initalize File Name
    if contains(ItemName, 'Fraction') % Don't make figure for Hydroperiod Fraction
        continue;
    elseif contains(ItemName, 'water level') && ~IsDifference % mean water level, but not a DifferenceMap
        SymbolSpec = LegendData.StageSymbolSpec; % Save Symbol Colormap
        SymbolLabels = LegendData.StageLabels; % Save Legend Labels
        TitleFront = strcat(Prefix, ' Average Stage (ft) -  '); % add prefix and item to title
        PlotName = strcat(Prefix, '_Stage'); % add prefix and item to filename
        nLegendCategories = 6; % max size of legend
    elseif contains(ItemName, 'water level') && IsDifference % mean water level and a DifferenceMap
        SymbolSpec = LegendData.StageDepthDiffSymbolSpec; % Save Symbol Colormap
        SymbolLabels = LegendData.ElevDiffLabels; % Save Legend Labels
        TitleFront = strcat(Prefix, ' Average Stage Difference (ft) -  ');% add prefix and item to title
        PlotName = strcat(Prefix, '_StageDiff'); % add prefix and item to filename
        nLegendCategories = 9;% max size of legend
    elseif contains(ItemName, 'water depth') && ~IsDifference % mean water depth, but not a DifferenceMap
        SymbolSpec = LegendData.DepthSymbolSpec; % Save Symbol Colormap
        SymbolLabels = LegendData.DepthLabels; % Save Legend Labels
        if contains(ItemName, 'discontinuous') % mean water depth during discontinuous hydroperiod
            TitleFront = strcat(Prefix, ' Average Ponding Depth (ft) -  '); % add prefix and item to title
            PlotName = strcat(Prefix, '_PondingDepth'); % add prefix and item to filename
        elseif contains(ItemName, 'Max continuous')% mean water depth during max continuous hydroperiod
            TitleFront = strcat(Prefix, ' Average Ponding Depth (ft) during Max Continuous Hydroperiod -  ');% add prefix and item to title
            PlotName = strcat(Prefix, '_PondingDepthMaxHydroperiod'); % add prefix and item to filename
        else % mean water depth 
            TitleFront = strcat(Prefix, ' Average Water Depth (ft) -  ');% add prefix and item to title
            PlotName = strcat(Prefix, '_Depth'); % add prefix and item to filename
        end
        nLegendCategories = 7; % max size of legend
    elseif contains(ItemName, 'water depth') && IsDifference % mean water depth and a DifferenceMap
        SymbolSpec = LegendData.StageDepthDiffSymbolSpec; % Save Symbol Colormap
        SymbolLabels = LegendData.ElevDiffLabels; % Save Legend Labels
        if contains(ItemName, 'discontinuous') % mean water depth during discontinuous hydroperiod
            TitleFront = strcat(Prefix, ' Average Ponding Depth Difference (ft)-  '); % add prefix and item to title
            PlotName = strcat(Prefix, '_PondingDepthDiff'); % add prefix and item to filename
        elseif contains(ItemName, 'Max continuous')% mean water depth during max continuous hydroperiod
            TitleFront = strcat(Prefix, ' Average Ponding Depth During Max Continuous Hydroperiod Difference (ft)-  ');% add prefix and item to title
            PlotName = strcat(Prefix, '_PondingDepthMaxHydroperiodDiff'); % add prefix and item to filename
        else % mean water depth 
            TitleFront = strcat(Prefix, ' Average Water Depth Difference (ft)-  ');% add prefix and item to title
            PlotName = strcat(Prefix, '_DepthDiff'); % add prefix and item to filename
        end
        nLegendCategories = 9; % max size of legend
    elseif contains(ItemName, 'hydroperiod') && ~IsDifference % Hydroperiod but not a DifferenceMap
        SymbolSpec = LegendData.HPSymbolSpec; % Save Symbol Colormap
        SymbolLabels = LegendData.HPLabels; % Save Legend Labels
        if contains(ItemName, 'hydroperiod1') % If discontinuous hydroperiod
            TitleFront = strcat(Prefix, ' Hydroperiod Distribution (days)-  ');% add prefix and item to title
            PlotName = strcat(Prefix, '_DisconHydroperiod');% add prefix and item to filename
        else % else max continuous hydroperiod
            TitleFront = strcat(Prefix, ' Max Continuous Hydroperiod Distribution (days)-  ');% add prefix and item to title
            PlotName = strcat(Prefix, '_MaxConHydroperiod');% add prefix and item to filename
        end
        nLegendCategories = 7; % max size of legend
    elseif contains(ItemName, 'hydroperiod') && IsDifference % Hydroperiod and a DifferenceMap
        SymbolSpec = LegendData.HPDiffSymbolSpec; % Save Symbol Colormap
        SymbolLabels = LegendData.HPDiffLabels; % Save Legend Labels
        if contains(ItemName, 'hydroperiod1') % If discontinuous hydroperiod
            TitleFront = strcat(Prefix, ' Hydroperiod Difference Distribution (days)-  ');% add prefix and item to title
            PlotName = strcat(Prefix, '_DisconHydroperiodDiff_');% add prefix and item to filename
        else % else max continuous hydroperiod
            TitleFront = strcat(Prefix, ' Max Continuous Hydroperiod Difference Distribution (days)-  ');% add prefix and item to title
            PlotName = strcat(Prefix, '_MaxConHydroperiodDiff_');% add prefix and item to filename
        end
        nLegendCategories = 9; % max size of legend
    end
    fprintf('......Creating Figures for item %s\n', ItemName);
    ConversionFactor = 1; % If file is in Meters, convert to feet
    if strcmp(dfs2File.ItemInfo.Item(nI - 1).Quantity.Unit, 'eumUmeter')
        ConversionFactor = 1/0.3048; % convert to feet
    end
    for ti = 0:TimeAxis.NumberOfTimeSteps - 1 % For each timestep in file
        fprintf('........Creating Figures for Timestep %i / %i\n', ti + 1, TimeAxis.NumberOfTimeSteps);
        % For legend
        Cat0I = -1;Cat1I = -1;Cat2I = -1;Cat3I = -1;Cat4I = -1;Cat5I = -1;Cat6I = -1;Cat7I = -1;Cat8I = -1;
        ItemData2D = dfs2File.ReadItemTimeStep(nI, ti); % Read dfs2 for item at time step
        currentDateTime = D0 + (ItemData2D.Time / 86400); % Find DateTime of Data
        TitleText = ''; % Initialize final variable for title text
        YearStr = num2str(currentDateTime.Year); % turn year to string
        if IsWetDry % If Wet/Dry Seasons
            if currentDateTime.Month == 6 % If timestep is June, Wet Season
                TitleText = strcat('Wet Season ', TitleFront, '  ', YearStr); % final title
                plotfilename = strcat('Wet_', PlotName, '_', YearStr); % final filename
            else % else, Dry Season
                TitleText = strcat('Dry Season ', TitleFront, '  ', YearStr);  % final title
                plotfilename = strcat('Dry_', PlotName, '_', YearStr); % final filename
            end
        elseif IsMonthly % If monthly use Month and Year in title and filename
            TitleText = strcat(TitleFront, '  ', num2str(currentDateTime.Month), '/', YearStr); % final title
            plotfilename = strcat(PlotName, '_', num2str(currentDateTime.Month), '_', YearStr);  % final filename
        else
            TitleText = strcat(TitleFront, '  ', YearStr); % final title
            plotfilename = strcat(PlotName, '_', YearStr);  % final filename
        end
        ItemData = double(ItemData2D.Data); % Convert from 2D array to 1D array
        for cell = 1:size(GridCells, 2) % Loop Through GridCell Polygons
            GridCells(cell).Value = ItemData(GridCells(cell).Index) * ConversionFactor; % Save value from dfs2 to structure
            % Used to Construct the legend. The legend must be constructed
            % from elements within figure, so indexes of elements are
            % found.
            if Cat0I == -1 % if polygon that matches category has not been found found
                % If polygon falls into category
                if GridCells(cell).Value >= SymbolSpec.FaceColor{1,2}(1) && GridCells(cell).Value <= SymbolSpec.FaceColor{1,2}(2)
                    Cat0I = cell; % Save polygon index
                end
            end
            if Cat1I == -1 % if polygon that matches category has not been found found
                % If polygon falls into category
                if GridCells(cell).Value >= SymbolSpec.FaceColor{2,2}(1) && GridCells(cell).Value <= SymbolSpec.FaceColor{2,2}(2)
                    Cat1I = cell; % Save polygon index
                end
            end
            if Cat2I == -1 % if polygon that matches category has not been found found
                % If polygon falls into category
                if GridCells(cell).Value >= SymbolSpec.FaceColor{3,2}(1) && GridCells(cell).Value <= SymbolSpec.FaceColor{3,2}(2)
                    Cat2I = cell; % Save polygon index
                end
            end
            if Cat3I == -1 % if polygon that matches category has not been found found
                % If polygon falls into category
                if GridCells(cell).Value >= SymbolSpec.FaceColor{4,2}(1) && GridCells(cell).Value <= SymbolSpec.FaceColor{4,2}(2)
                    Cat3I = cell; % Save polygon index
                end
            end
            if Cat4I == -1 % if polygon that matches category has not been found found
                % If polygon falls into category
                if GridCells(cell).Value >= SymbolSpec.FaceColor{5,2}(1) && GridCells(cell).Value <= SymbolSpec.FaceColor{5,2}(2)
                    Cat4I = cell; % Save polygon index
                end
            end
            if Cat5I == -1 % if polygon that matches category has not been found found
                % If polygon falls into category
                if GridCells(cell).Value >= SymbolSpec.FaceColor{6,2}(1) && GridCells(cell).Value <= SymbolSpec.FaceColor{6,2}(2)
                    Cat5I = cell; % Save polygon index
                end
            end
            if Cat6I == -1 && nLegendCategories >= 7 % if polygon that matches category has not been found found, and 7 legend categories are used
                % If polygon falls into category
                if GridCells(cell).Value >= SymbolSpec.FaceColor{7,2}(1) && GridCells(cell).Value <= SymbolSpec.FaceColor{7,2}(2)
                    Cat6I = cell; % Save polygon index
                end
            end
            if Cat7I == -1 && nLegendCategories == 9 % if polygon that matches category has not been found found, and 9 legend categories are used
                % If polygon falls into category
                if GridCells(cell).Value >= SymbolSpec.FaceColor{8,2}(1) && GridCells(cell).Value <= SymbolSpec.FaceColor{8,2}(2)
                    Cat7I = cell; % Save polygon index
                end
            end
            if Cat8I == -1 && nLegendCategories == 9 % if polygon that matches category has not been found found, and 9 legend categories are used
                % If polygon falls into category
                if GridCells(cell).Value >= SymbolSpec.FaceColor{9,2}(1) && GridCells(cell).Value <= SymbolSpec.FaceColor{9,2}(2)
                    Cat8I = cell; % Save polygon index
                end
            end
        end
        clf % Clear Figure
        axesm ('utm', 'Frame', 'on', 'Grid', 'on'); % Create a UTM map, turn the Frame on, and Grid On 
        zone = utmzone(ProjLat, ProjLong); % Find the UTM zone, from dfs2 Projection Latitude and Longitude
        setm(gca, 'zone', zone) % set UTM map to specified zone
        % TODO upper limit from spatial axis. convert from utm x,y to lat and long. 
        % Lower limit is Origin Lat long from dfs2 projection pushed out a bit
        setm(gca, 'MapLatLimit', [(ProjLat - 0.1) 26], 'MapLonLimit', [(ProjLong - 0.3) -80.3]);
        % Map USA Coastline to figure, builtin shape file from Matlab Mapping Toolbox
        geoshow('usastatelo.shp','FaceColor','white');
        % Map Polygons from Grid shapefile
        % Colored according to Symbols and dfs2 Data
        hGrid = mapshow(GridCells, 'SymbolSpec', SymbolSpec);
        clear LegendCategoryItems LegendCategoryLabels
        % Create Legend
        ii = 1; % index in legend
        if Cat0I ~= -1 % If a polygon matched this category 
            LegendCategoryItems(ii) = hGrid.Children(Cat0I); % Add element to legend
            LegendCategoryLabels(ii) = SymbolLabels(1); % Add label to legend
            ii = ii + 1; % Increment Legend element index
        end
        if Cat1I ~= -1% If a polygon matched this category 
            LegendCategoryItems(ii) = hGrid.Children(Cat1I); % Add element to legend
            LegendCategoryLabels(ii) = SymbolLabels(2); % Add label to legend
            ii = ii + 1;% Increment Legend element index
        end
        if Cat2I ~= -1% If a polygon matched this category 
            LegendCategoryItems(ii) = hGrid.Children(Cat2I); % Add element to legend
            LegendCategoryLabels(ii) = SymbolLabels(3); % Add label to legend
            ii = ii + 1;% Increment Legend element index
        end
        if Cat3I ~= -1% If a polygon matched this category 
            LegendCategoryItems(ii) = hGrid.Children(Cat3I); % Add element to legend
            LegendCategoryLabels(ii) = SymbolLabels(4); % Add label to legend
            ii = ii + 1;% Increment Legend element index
        end
        if Cat4I ~= -1% If a polygon matched this category 
            LegendCategoryItems(ii) = hGrid.Children(Cat4I); % Add element to legend
            LegendCategoryLabels(ii) = SymbolLabels(5); % Add label to legend
            ii = ii + 1;% Increment Legend element index
        end
        if Cat5I ~= -1% If a polygon matched this category 
            LegendCategoryItems(ii) = hGrid.Children(Cat5I); % Add element to legend
            LegendCategoryLabels(ii) = SymbolLabels(6); % Add label to legend
            ii = ii + 1;% Increment Legend element index
        end
        if Cat6I ~= -1% If a polygon matched this category 
            LegendCategoryItems(ii) = hGrid.Children(Cat6I);% Add element to legend
            LegendCategoryLabels(ii) = SymbolLabels(7); % Add label to legend
            ii = ii + 1;% Increment Legend element index
        end
        if Cat7I ~= -1% If a polygon matched this category 
            LegendCategoryItems(ii) = hGrid.Children(Cat7I);% Add element to legend
            LegendCategoryLabels(ii) = SymbolLabels(8); % Add label to legend
            ii = ii + 1;% Increment Legend element index
        end
        if Cat8I ~= -1% If a polygon matched this category 
            LegendCategoryItems(ii) = hGrid.Children(Cat8I);% Add element to legend
            LegendCategoryLabels(ii) = SymbolLabels(9); % Add label to legend
            ii = ii + 1;% Increment Legend element index
        end
        % Add legend to map, 
        % Set Location to West edge of map, in the middle
        % Set AutoUpdate to Off, won't add remaining elements to legend
        hleg = legend(LegendCategoryItems, LegendCategoryLabels, 'Location', 'west', 'AutoUpdate', 'off');
        title(hleg, 'Legend'); % Title Legend
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
        scaleruler('units', 'Miles'); % Set Units to Miles
        setm(handlem('scaleruler1'),...
            'XLoc', dfs2File.SpatialAxis.X0 + 10000,... % Set Location below and to the right of dfs2 Origin
            'YLoc', dfs2File.SpatialAxis.Y0 - 10000,...
            'MajorTick', 0:10:40, 'MinorTick', 0:5:10) % Set Major and Minor ticks
        % Saves figure, as png, with specified filename, at a specific resolution
        print('-dpng',char(strcat(OutputDir, namesplit(1), '_', plotfilename)),'-r600')
    end
end
end