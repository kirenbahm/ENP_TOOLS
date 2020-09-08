function INI = A11_Generate_Statistic_Graphics(INI)

fprintf('\n------------------------------------');
fprintf('\nBeginning A11_Generate_Statistic_Graphics    (%s)',datestr(now));
fprintf('\n------------------------------------\n');
format compact

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


fprintf('\nGenerating ColorMaps\n');
%---------------------------------------Define ColorRamps---------------------------------------
% Hydroperiod ColorRamp
LegendData.HPSymbolSpec = makesymbolspec('Polygon',...
    {'Value',[331 366], 'FaceColor', [0.2627 0.5216 1], 'EdgeColor', 'none'},...
    {'Value',[301 330], 'FaceColor', [0.2 1 1], 'EdgeColor', 'none'},...
    {'Value',[241 300], 'FaceColor', [0.2392 0.7765 0.2], 'EdgeColor', 'none'},...
    {'Value',[181 240], 'FaceColor', [0.7765 1 0.2], 'EdgeColor', 'none'},...
    {'Value',[121 180], 'FaceColor', [1 1 0.2], 'EdgeColor', 'none'},...
    {'Value',[61 120], 'FaceColor', [1 0.73333 0.2], 'EdgeColor', 'none'},...
    {'Value',[0 60], 'FaceColor', [1 1 1], 'EdgeColor', 'none'});
LegendData.HPLabels = {'330 - 366', '300 - 330', '240 - 300',...
            '180 - 240', '120 - 180', '60 - 120', '0 - 60'};

% Hydroperiod Difference ColorRamp
LegendData.HPDiffSymbolSpec = makesymbolspec('Polygon',...
    {'Value',[-240 -180], 'FaceColor', [0.5216 0.2 0.2], 'EdgeColor', 'none'},...
    {'Value',[-180 -120], 'FaceColor', [1 0.2 0.2], 'EdgeColor', 'none'},...
    {'Value',[-120 -60], 'FaceColor', [0.9647 0.7137 0.5020], 'EdgeColor', 'none'},...
    {'Value',[ -60 -15], 'FaceColor', [1 1 0.2], 'EdgeColor', 'none'},...
    {'Value',[-14 14], 'FaceColor', [0.8275 0.8275 0.8275], 'EdgeColor', 'none'},...
    {'Value',[15 60], 'FaceColor', [0.6157 0.8784 0.9216], 'EdgeColor', 'none'},...
    {'Value',[60 120], 'FaceColor', [0.2 0.8 1], 'EdgeColor', 'none'},...
    {'Value',[120 180], 'FaceColor', [0.2 0.2 0.8431], 'EdgeColor', 'none'},...
    {'Value',[180 240], 'FaceColor', [0.2 0.2 0.2], 'EdgeColor', 'none'});
LegendData.HPDiffLabels = {'180-240 days shorter', '120-180 days shorter', '60-120 days shorter',...
            '15-60 days shorter', '+-14 days', '15-60 days longer',...
            '60-120 days longer', '120-180 days longer', '180-240 days longer'};
        
% Stage ColorMap
LegendData.StageSymbolSpec = makesymbolspec('Polygon',...
    {'Value',[9.0 9999.0], 'FaceColor', [0.9216 0.7882 0.6118], 'EdgeColor', 'none'},... % > 9
    {'Value',[6.0 9.0], 'FaceColor', [0.9608 0.8667 0.6431], 'EdgeColor', 'none'},...
    {'Value',[3.0 6.0], 'FaceColor', [0.9608 0.9176 0.6784], 'EdgeColor', 'none'},...
    {'Value',[0.0 3.0], 'FaceColor', [0.9255 0.9294 0.6863], 'EdgeColor', 'none'},...
    {'Value',[-3.0 0.0], 'FaceColor', [0.7294 0.8000 0.5765], 'EdgeColor', 'none'},...
    {'Value',[-9999.0 -3.0], 'FaceColor', [0.5529 0.6784 0.4784], 'EdgeColor', 'none'}); % < -3
LegendData.StageLabels = {'> 9.0', '6.0 - 9.0', '3.0 - 6.0',...
            '0.0 - 3.0', '-3.0 - 0.0', '< -3.0'};

%Stage Difference ColorMap
LegendData.StageDepthDiffSymbolSpec = makesymbolspec('Polygon',...
    {'Value',[1.0 9999.0], 'FaceColor', [0.2 0.2 0.8431], 'EdgeColor', 'none'},...
    {'Value',[0.5 1.0], 'FaceColor', [0.2 0.8 1], 'EdgeColor', 'none'},...
    {'Value',[0.25 0.5], 'FaceColor', [0.4745 0.8392 0.9608], 'EdgeColor', 'none'},...
    {'Value',[0.1 0.25], 'FaceColor', [0.7412 0.8784 0.9216], 'EdgeColor', 'none'},...
    {'Value',[-0.1 0.1], 'FaceColor', [0.8627 0.8627 0.8627], 'EdgeColor', 'none'},...
    {'Value',[-0.25 -0.1], 'FaceColor', [1 0.9608 1], 'EdgeColor', 'none'},...
    {'Value',[-0.5 -0.25], 'FaceColor', [1 1 0.2], 'EdgeColor', 'none'},...
    {'Value',[-1.0 -0.5], 'FaceColor', [0.9647 0.7137 0.5020], 'EdgeColor', 'none'},...
    {'Value',[-9999.0 -1.0], 'FaceColor', [1 0.2 0.2], 'EdgeColor', 'none'});
LegendData.ElevDiffLabels = {'>1.0 higher', '0.5-1.0 higher', '0.25-0.5 higher',...
            '0.1-0.25 higher', '+- 0.1', '0.1-0.25 lower',...
            '0.25-0.5 lower', '0.5-1.0 lower', '>1.0 lower'};
        
%Depth ColorMap
LegendData.DepthSymbolSpec = makesymbolspec('Polygon',...
    {'Value',[3.0 9999.0], 'FaceColor', [0.2627 0.5216 1], 'EdgeColor', 'none'},...
    {'Value',[2.0 3.0], 'FaceColor', [0.5765 0.8353 1], 'EdgeColor', 'none'},...
    {'Value',[1.0 2.0], 'FaceColor', [0.2 0.8078 0.3333], 'EdgeColor', 'none'},...
    {'Value',[0.5 1.0], 'FaceColor', [0.8118 1 0.5098], 'EdgeColor', 'none'},...
    {'Value',[0.0 0.5], 'FaceColor', [1 0.9922 0.4471], 'EdgeColor', 'none'},...
    {'Value',[0.0 0.0], 'FaceColor', [1 1 1], 'EdgeColor', 'none'},...
    {'Value',[-9999.0 0.0], 'FaceColor', [1 0.73333 0.2], 'EdgeColor', 'none'});
LegendData.DepthLabels = {'> 3.0', '2.0 - 3.0', '1.0 - 2.0',...
            '0.5 - 1.0', '0.0 - 0.5', '0.0', '< 0.0'};

%-----------------------------------------------------------------------------------------------
% Setup output directory
OutDir = [INI.POST_PROC_DIR '\StatisticFigures\'];
if ~exist(OutDir, 'dir')
   mkdir(OutDir)
end
%-----------------------------------------------------------------------------------------------
% Shape File of grid cells
fprintf('Reading in Grid Cell Shape Data: %s\n', 'M06_grid_cells.shp');
grid = shaperead(INI.GRID_CELLS);

% Loop through models
nM = size(INI.MODEL_SIMULATION_SET, 2);
for ii=1:nM + 1 % Extra loop iteration is for the DifferenceMaps
    % Find list of files to read
    if ii <= nM % If one of the input models, find filenames of dfs2 user selected for figures
        ModelNameParts = INI.MODEL_SIMULATION_SET{ii}; % Parse Base model Name
        fprintf('\nFinding .dfs2 Files For Model %s', ModelNameParts{2});
        ModelFolder = [INI.DATA_STATISTICS  ModelNameParts{2} '.she - Result Files\']; % Base Model results folder
        fi = 1;
        % If Monthly Figures are being made add filename to list
        if INI.MONTHLY_FIGS
            LISTING(fi).name = [ModelFolder ModelNameParts{2} '_MonthlyStats.dfs2'];      % current model Monthly Stats
            fi = fi + 1;
        end
        % If Calendar year Figures are being made add filename to list
        if INI.CALENDAR_YEAR_FIGS
            LISTING(fi).name = [ModelFolder ModelNameParts{2} '_CalYearStats.dfs2'];      % current Model Calendar Year Stats
            fi = fi + 1;
        end
        % If Monthly Figures are being made add filename to list
        if INI.WATER_YEAR_FIGS
            LISTING(fi).name = [ModelFolder ModelNameParts{2} '_WaterYearStats.dfs2'];    % Base Model Water Year Stats
            fi = fi + 1;
        end
        % If Wet and Dry Seasons are being made add filename to list
        if INI.WET_DRY_SEASON_FIGS
            LISTING(fi).name = [ModelFolder ModelNameParts{2} '_WetDryStats.dfs2'];       % Base Model WetDry Stats
            fi = fi + 1;
        end
        % If Total Period Figures are being made add filename to list
        if INI.TOTAL_PERIOD_FIGS
            Period = strcat(num2str(INI.ANALYZE_DATE_I(2)), '_', num2str(INI.ANALYZE_DATE_I(1)), '_',...
                num2str(INI.ANALYZE_DATE_F(2)), '_', num2str(INI.ANALYZE_DATE_F(1)));
            LISTING(fi).name = [ModelFolder ModelNameParts{2}, '_TotalAnalysisPeriodStats(' Period ').dfs2']; % Base Model Total Period Stats
        end
    elseif INI.DIFFERENCE_MAP_FIGS % occurs at condition ii == nM + 1
        % find listing of all difference map dfs2 files
        fprintf('\nFinding .dfs2 Files For Difference Maps');
        DiffDir = [INI.POST_PROC_DIR '\DifferenceMaps\'];
        FILE_FILTER = [DiffDir '*.dfs2'];                            % list only files with extension *.dat
        LISTING  = dir(char(FILE_FILTER));
        for FI = 1:size(LISTING, 2)
            LISTING(FI).name = [LISTING(FI).folder '\' LISTING(FI).name]; 
        end
    end
    % Loop through files
    for FI = 1:size(LISTING, 2)
        [~, fn, ext] = fileparts(LISTING(FI).name); % Find current file name and extension
        fprintf('\n....Finding active grid cells in file %s', strcat(fn, ext));
        dfs2File = Dfs2File(DfsFileFactory.DfsGenericOpen(LISTING(FI).name)); % Open dfs2file
        % save file metadata
        noData = dfs2File.FileInfo.DeleteValueFloat;
        SpatialAxis = dfs2File.SpatialAxis;
        
        Data2D = dfs2File.ReadItemTimeStep(1, 0);% read in the first timestep of the first item.
        dfs2File.Close(); % Close dfs2 file
        index = -1; % initialize variable. Used to store shape grid cell's index in dfs2 
        Data = double(Data2D.Data); % Convert from 2D to 1D array
        % Working Grid is the structure that wll be mapped into a figure.
        % This step initializes the objects and memory for the structures.
        WorkingGrid(sum(Data ~= noData)) = struct();
        ii = 1; % Index in WorkingGrid Structure array
        updateperiod = size(grid, 1) / 10; % How often to print a period to console
        
        % This limits how many Grid Cells we are working with. Instead of
        % finding which shape polygons are being used in each file , at each
        % timestep and per item it finds which shape file's cells have don't have 
        % noData values in the dfs2 file. Then these are saved to the
        % WorkingGrid. Thus we only look once per each file.
        for cell = 1:size(grid, 1) % Loop through shape file grid cells
            if mod(cell, updateperiod) == 0 % Loop is time consuming, prints a period every ~10%
                fprintf('.');
            end
            % polygons in shape file are not necessarily in the same order
            % as the values read from the dfs2. Uses the 0-based row and
            % column values in the shape file fields to calculate the index
            % within the shape file.
            index = (grid(cell).RowBase0 * SpatialAxis.XCount) + (grid(cell).ColBase0 + 1);
            if Data(index) ~= noData % if cell isn't noData, then it is active in the dfs2
                WorkingGrid(ii).Geometry = grid(cell).Geometry; % for Figure, is Polygon
                WorkingGrid(ii).BoundingBox = grid(cell).BoundingBox; % for Figure, max and min XY limits of polygon
                WorkingGrid(ii).X = grid(cell).X; % Array of Vertices, X values
                WorkingGrid(ii).Y = grid(cell).Y; % Array of Vertices, Y values
                WorkingGrid(ii).Index = (grid(cell).RowBase0 * SpatialAxis.XCount) + (grid(cell).ColBase0 + 1); % Index in dfs2 array
                WorkingGrid(ii).Value = 0.0; % Initialize value field
                ii = ii + 1; % increment index in Structure array
            end
        end
        fprintf('\n....Creating figures for file %s\n', LISTING(FI).name);
        createStatisticFigure(LISTING(FI).name, WorkingGrid, LegendData, OutDir); % Send dfs2 to script for writing figures
        clear WorkingGrid % Clear memory for Working Grid when file is done
    end
end
fprintf('\n------------------------------------');
fprintf('\nFinishing A11_Generate_Statistic_Graphics    (%s)',datestr(now));
fprintf('\n------------------------------------\n');
format compact
end
