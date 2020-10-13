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
LegendData.HPColorMap = [1 0.2 0.2
                         1 0.73333 0.2
                         1 1 0.2
                         0.7765 1 0.2
                         0.2392 0.7765 0.2
                         0.2 1 1
                         0.2627 0.5216 1];
LegendData.HPValues = [ 0 60
                        60 120
                        120 180
                        180 240
                        240 300
                        300 330
                        330 367];
LegendData.HPLabels = {'0 - 60 days', '60 - 120 days',  '120 - 180 days',... 
    '180 - 240 days', '240 - 300 days', '300 - 330 days', '330 - 366 days'};

% Hydroperiod Difference ColorRamp
LegendData.HPDiffColorMap = [0.5216 0.2 0.2
                            1 0.2 0.2
                            0.9647 0.7137 0.5020
                            1 1 0.2
                            0.8275 0.8275 0.8275%%%%
                            0.6157 0.8784 0.9216
                            0.2 0.8 1
                            0.2 0.2 0.8431
                            0.2 0.2 0.2];
LegendData.HPDiffValues = [-366 -90
                           -90 -45
                           -45 -30
                           -30 -14
                           -14 14 %Fix Values
                           14 30
                           30 45
                           45 90
                           90 367];
LegendData.HPDiffLabels = {'90-366 days shorter', '45-90 days shorter', '30-45 days shorter',...
            '14-30 days shorter', '+-14 days', '14-30 days longer',...
            '30-45 days longer', '45-90 days longer', '90-366 days longer'};
        
% Stage ColorMap
LegendData.StageColorMap = [1 0.2 0.2
                            0.9216 0.7961 0.8314
                            0.8314 0.6627 0.6314
                            0.8549 0.6980 0.6078
                            0.9216 0.7882 0.6118
                            0.9608 0.8667 0.6431
                            0.9608 0.9176 0.6784
                            0.9255 0.9294 0.6863
                            0.7294 0.8000 0.5765
                            0.5529 0.6784 0.4784];
LegendData.StageValues = [ 20.0 24.0
                           18.0 20.0
                           15.0 18.0
                           12.0 15.0
                           9.0 12.0 
                           6.0 9.0
                           3.0 6.0
                           0.0 3.0
                           -3.0 0.0
                           -9999.0 -3.0];
LegendData.StageLabels = {'20.0 - 24.0', '18.0 - 20.0', '15.0 - 18.0', '12.0 - 15.0',...
            '9.0 - 12.0', '6.0 - 9.0', '3.0 - 6.0',...
            '0.0 - 3.0', '-3.0 - 0.0', '< -3.0'};

%Stage Difference ColorMap
LegendData.ElevDiffColorMap = [0.2 0.2 0.8431
                               0.2 0.8 1
                               0.4745 0.8392 0.9608
                               0.7412 0.8784 0.9216
                               0.8627 0.8627 0.8627 %%%%
                               1 1 0.2
                               0.9647 0.7137 0.5020
                               1 0.73333 0.2
                               1 0.2 0.2];
LegendData.ElevDiffValues = [1.0 9999.0
                             0.5 1.0
                             0.25 0.5
                             0.1 0.25
                             -0.1 0.1%%%
                             -0.25 -0.1
                             -0.5 -0.25
                             -1.0 -0.5
                             -9999.0 -1.0];
LegendData.ElevDiffLabels = {'>1.0 higher', '0.5-1.0 higher', '0.25-0.5 higher',...
            '0.1-0.25 higher', '+- 0.1', '0.1-0.25 lower',...
            '0.25-0.5 lower', '0.5-1.0 lower', '>1.0 lower'};
        
%Depth ColorMap
LegendData.DepthColorMap = [0.2627 0.5216 1
                            0.5765 0.8353 1
                            0.2 0.8078 0.3333
                            0.8118 1 0.5098
                            1 0.9922 0.4471
                            1 0.73333 0.2
                            1 0 0];
LegendData.DepthValues = [3.0 9999.0
                           2.0 3.0
                           1.0 2.0
                           0.5 1.0
                           0.0 0.5
                           0.0 0.0
                           -9999.0 0.0]; 
LegendData.DepthLabels = {'> 3.0', '2.0 - 3.0', '1.0 - 2.0',...
            '0.5 - 1.0', '0.0 - 0.5', '0.0', '< 0.0'};

%-----------------------------------------------------------------------------------------------
% Setup output directory
OutDir = [INI.POST_PROC_DIR '\figures\maps\'];
if ~exist(OutDir, 'dir')
   mkdir(OutDir)
end

% Copy the head and tail files for Latex
if ~exist(INI.LATEX_DIR,'file'),  mkdir(INI.LATEX_DIR), end
copyfile([INI.SCRIPTDIR 'head.sty'], INI.LATEX_DIR );
copyfile([INI.SCRIPTDIR 'tail.sty'], INI.LATEX_DIR );
%-----------------------------------------------------------------------------------------------

% Find Analysis Period Start and End Dates 
StartDateTime = datetime(INI.ANALYZE_DATE_I);
EndDateTime = datetime(INI.ANALYZE_DATE_F);

% Loop through models
nM = size(INI.MODEL_SIMULATION_SET, 2);
for ii=1:nM + 1 % Extra loop iteration is for the DifferenceMaps
    % Find list of files to read
    clear LISTING LATEX_FILES;
    if ii <= nM % If one of the input models, find filenames of dfs2 user selected for figures
        ModelNameParts = INI.MODEL_SIMULATION_SET{ii}; % Parse Base model Name
        fprintf('\nFinding .dfs2 Files For Model %s', ModelNameParts{2});
        ModelFolder = [INI.DATA_STATISTICS  ModelNameParts{2} '\']; % Base Model results folder% create directory and copy needed files
        LATEX_FILES.IsDifference = false;
        % Latex files names for output
        LATEX_FILES.FileNames{1} = [INI.LATEX_DIR '/' 'Hydroperiod_' ModelNameParts{3} '.tex'];
        LATEX_FILES.FileNames{2} = [INI.LATEX_DIR '/' 'Stage_' ModelNameParts{3} '.tex'];
        LATEX_FILES.FileNames{3} = [INI.LATEX_DIR '/' 'Depth_' ModelNameParts{3} '.tex'];
        LATEX_FILES.FileNames{4} = [INI.LATEX_DIR '/' 'Ponding_Depth_' ModelNameParts{3} '.tex'];
        fi = 1;
        % If Monthly Figures are being made add filename to list
        if INI.MONTHLY_FIGS
            LISTING(fi).name = [ModelFolder ModelNameParts{2} '_MonthlyStats.dfs2'];      % current model Monthly Stats
            fi = fi + 1;
            % If Monthly Figs, add Monthly Latex files to list
            LATEX_FILES.FileNames{5} = [INI.LATEX_DIR '/' 'Stage_Monthly_' ModelNameParts{3} '.tex'];
            LATEX_FILES.FileNames{6} = [INI.LATEX_DIR '/' 'Depth_Monthly' ModelNameParts{3} '.tex'];
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
        DiffDir = [INI.POST_PROC_DIR '\data\'];
        FILE_FILTER = [DiffDir '*.dfs2'];                            % list only files with extension *.dat
        LISTINGTEMP  = dir(char(FILE_FILTER));
        LISTINGTEMP = LISTINGTEMP';
        li = 1;
        for FI = 1:size(LISTINGTEMP, 2)
            LISTINGTEMP(FI).name = [LISTINGTEMP(FI).folder '\' LISTINGTEMP(FI).name];
            % If Monthly Figs are being made and the Monthly Difference
            % dfs2 files exist
            if INI.MONTHLY_FIGS && contains(LISTINGTEMP(FI).name, 'Monthly_Diff')
                LISTING(1, li) = LISTINGTEMP(FI);
                li = li + 1;
            % If Annual Figs are being made and the Annual Difference
            % dfs2 files exist
            elseif INI.CALENDAR_YEAR_FIGS && contains(LISTINGTEMP(FI).name, 'CalYear_Diff')
                LISTING(1, li) = LISTINGTEMP(FI);
                li = li + 1;
            % If Water Year Figs are being made and the Water Year Difference
            % dfs2 files exist
            elseif INI.WATER_YEAR_FIGS && contains(LISTINGTEMP(FI).name, 'WaterYear_Diff')
                LISTING(1, li) = LISTINGTEMP(FI);
                li = li + 1;
            % If Wet/Dry Season Figs are being made and the Wet/Dry Season Difference
            % dfs2 files exist
            elseif INI.WET_DRY_SEASON_FIGS && contains(LISTINGTEMP(FI).name, 'WetDry_Diff')
                LISTING(1, li) = LISTINGTEMP(FI);
                li = li + 1;
            % If Total Analysis Period Figs are being made and the Total Analysis Period Difference
            % dfs2 files exist
            elseif INI.TOTAL_PERIOD_FIGS && contains(LISTINGTEMP(FI).name, 'TotalAnalysisPeriod_Diff')
                LISTING(1, li) = LISTINGTEMP(FI);
                li = li + 1;
            end
        end
        ti = 1; % index for adding latex files per model
        nonBase = 1; % index for adding model name
        LATEX_FILES.IsDifference = true;
        % For Index purposes when generating figures to select the correct
        % output Latex files, as all dfs2 file difference maps are output 
        % to the same directory.
        % For all models
        for mi=1:nM
            % If the model is not the base model
            if mi ~= INI.BASE
                % Parse Base and alternative Model Names
                BaseNameParts = INI.MODEL_SIMULATION_SET{INI.BASE};
                ModelNameParts = INI.MODEL_SIMULATION_SET{mi};
                % Add Alternative name to array
                LATEX_FILES.ModelOrder{nonBase} = ModelNameParts{3};
                % Add output Latex Files for this alternative - Base
                % set of Difference Maps
                LATEX_FILES.FileNames{ti} = [INI.LATEX_DIR '/' 'Hydroperiod_Diffs_' ModelNameParts{3} '-' BaseNameParts{3} '.tex'];
                LATEX_FILES.FileNames{ti + 1} = [INI.LATEX_DIR '/' 'Stage_Diffs_' ModelNameParts{3} '-' BaseNameParts{3} '.tex'];
                ti = ti + 2; % increment latex file name index by 2
                nonBase = nonBase + 1; % increment model name index by 1
            end
        end
    end
    % For each Latex File, write Head
    for li = 1:size(LATEX_FILES.FileNames,2)
        generate_latex_blocks_maps( LATEX_FILES.FileNames{li}, 0, '', '' );
    end
    % For each dfs2 generate figures
    for FI = 1:size(LISTING, 2)
        [~, fn, ext] = fileparts(LISTING(FI).name); % Find current file name and extension
        fprintf('\n....Opening file %s', strcat(fn, ext));
        % check if dfs2 file exists
        if ~exist(LISTING(FI).name, 'file')
            fprintf('\n....%s file not found. skipping %s', strcat(fn, ext));
            continue;
        end
        fprintf('\n....Creating figures for file %s\n', LISTING(FI).name);
        createStatisticFigure(LISTING(FI).name, LegendData, OutDir, INI.GIS_DIR, StartDateTime, EndDateTime, LATEX_FILES); % Send dfs2 to script for writing figures
    end
    % For each Latex File, Write Tail
    for li = 1:size(LATEX_FILES.FileNames, 2)
        generate_latex_blocks_maps( LATEX_FILES.FileNames{li}, 1, '', '' );
    end
end
fprintf('\n------------------------------------');
fprintf('\nFinishing A11_Generate_Statistic_Graphics    (%s)',datestr(now));
fprintf('\n------------------------------------\n');
format compact
end
