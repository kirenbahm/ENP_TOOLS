function [ INI ] = A10_make_alternatives_difference_maps(INI)

fprintf('\n------------------------------------');
fprintf('\nBeginning A10_make_alternatives_difference_maps    (%s)',datestr(now));
fprintf('\n------------------------------------');
format compact

% Import Statements
dmi = NET.addAssembly('DHI.Mike.Install');
if (~isempty(dmi))
    DHI.Mike.Install.MikeImport.SetupLatest({DHI.Mike.Install.MikeProducts.MikeCore});
end
NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfs0.*;
NET.addAssembly('DHI.Generic.MikeZero.EUM');
NET.addAssembly('DHI.Generic.MikeZero.DFS');
H = NETaddDfsUtil();
eval('import DHI.Generic.MikeZero.DFS.*');
eval('import DHI.Generic.MikeZero.DFS.dfs123.*');
eval('import DHI.Generic.MikeZero.*');

% Setup output directory
OutDir = [INI.POST_PROC_DIR '\data\'];
if ~exist(OutDir, 'dir')
   mkdir([OutDir '\data\'])
end

% Analysis Period
StartDateTime = datetime(INI.ANALYZE_DATE_I);
EndDateTime = datetime(INI.ANALYZE_DATE_F);
Period = strcat(num2str(INI.ANALYZE_DATE_I(2)), '_', num2str(INI.ANALYZE_DATE_I(1)), '_',...
                num2str(INI.ANALYZE_DATE_F(2)), '_', num2str(INI.ANALYZE_DATE_F(1)));

% Number Of Models
nD = length(INI.MODEL_ALL_RUNS);

% Base Model Data and Files
BaseNameParts = INI.MODEL_SIMULATION_SET{INI.BASE}; % Parse Base model Name
BaseFolder = [INI.DATA_STATISTICS  BaseNameParts{2} '\']; % Base Model results folder 

fileMonthly_Base        = [BaseFolder BaseNameParts{2} '_MonthlyStats.dfs2'];      % Base model Monthly Stats
fileWetDry_Base         = [BaseFolder BaseNameParts{2} '_WetDryStats.dfs2'];       % Base Model WetDry Stats
fileCalendarYear_Base   = [BaseFolder BaseNameParts{2} '_CalYearStats.dfs2'];      % Base Model Calendar Year Stats
fileWaterYear_Base      = [BaseFolder BaseNameParts{2} '_WaterYearStats.dfs2'];    % Base Model Water Year Stats
fileTotalPeriod_Base    = [BaseFolder BaseNameParts{2}, '_TotalAnalysisPeriodStats(' Period ').dfs2']; % Base Model Total Period Stats

CompareMonthly_Base     = exist(fileMonthly_Base,'file') == 2;      % Check if Monthly Stats exist
CompareWetDry_Base      = exist(fileWetDry_Base,'file') == 2;       % Check if Wet Dry Season Stats exist
CompareCalYear_Base     = exist(fileCalendarYear_Base,'file') == 2; % Check if Calendar Stats exist
CompareWaterYear_Base   = exist(fileWaterYear_Base,'file') == 2;    % Check if Water Year Stats exist
CompareTotalPeriod_Base = exist(fileTotalPeriod_Base,'file') == 2;  % Check if Total Period Stats exist

alt = 0;
for i=1:nD
    if i ~= INI.BASE % If model isn't base
        alt = alt + 1;
        AltNameParts = INI.MODEL_SIMULATION_SET{i}; % Parse Alternative model Name
        AltNumStr = num2str(alt,'%i');  % String of Alternative number
        AltFolder = [INI.DATA_STATISTICS  AltNameParts{2} '\']; % Alternative Model results folder
        
        fileMonthly_Alt      = [AltFolder AltNameParts{2} '_MonthlyStats.dfs2'];      % Alternative Model Monthly       Stats
        fileWetDry_Alt       = [AltFolder AltNameParts{2} '_WetDryStats.dfs2'];       % Alternative Model WetDry        Stats
        fileCalendarYear_Alt = [AltFolder AltNameParts{2} '_CalYearStats.dfs2'];      % Alternative Model Calendar Year Stats
        fileWaterYear_Alt    = [AltFolder AltNameParts{2} '_WaterYearStats.dfs2'];    % Alternative Model Water Year    Stats
        fileTotalPeriod_Alt  = [AltFolder AltNameParts{2}, '_TotalAnalysisPeriodStats(' Period ').dfs2']; % Alternative Model Total Period  Stats
        
        CompareMonthly     = CompareMonthly_Base     && exist(fileMonthly_Alt,'file')      == 2; % Check if Monthly        Stats compare is possible
        CompareWetDry      = CompareWetDry_Base      && exist(fileWetDry_Alt,'file')       == 2; % Check if Wet/Dry Season Stats compare is possible
        CompareCalYear     = CompareCalYear_Base     && exist(fileCalendarYear_Alt,'file') == 2; % Check if Calendar Year  Stats compare is possible
        CompareWaterYear   = CompareWaterYear_Base   && exist(fileWaterYear_Alt,'file')    == 2; % Check if Water Year     Stats compare is possible
        CompareTotalPeriod = CompareTotalPeriod_Base && exist(fileTotalPeriod_Alt,'file')  == 2; % Check if Total Period   Stats compare is possible
        
        for fi=1:5 % For each Stat type
            
            % First iteration compares monthly
            if fi == 1 
                if CompareMonthly % if both models had stats
                    File0 = fileMonthly_Alt;
                    File1 = fileMonthly_Base;
                    FileType = 'Monthly';
                    fprintf('\n      comparing Monthly Stats');
                else % else skip to next iteration
                    fprintf('\n      One or Both models do not have Monthly Stats....skipping');
                    continue;
                end
                
            % Second iteration compares Wet/Dry Seasons
            elseif fi == 2
                if CompareWetDry% if both models had stats
                    File0 = fileWetDry_Alt;
                    File1 = fileWetDry_Base;
                    FileType = 'WetDry';
                    fprintf('\n      comparing WetDry season Stats');
                else % else skip to next iteration
                    fprintf('\n      One or Both models do not have WetDry season Stats....skipping');
                    continue;
                end
                
            % Third iteration compares Calendar Year
            elseif fi == 3
                if CompareCalYear% if both models had stats
                    File0 = fileCalendarYear_Alt;
                    File1 = fileCalendarYear_Base;
                    FileType = 'CalYear';
                    fprintf('\n      comparing Calendar Year Stats');
                else % else skip to next iteration
                    fprintf('\n      One or Both models do not have Calendar Year Stats....skipping');
                    continue;
                end
                
            % Fourth iteration compares Water Year
            elseif fi == 4
                if CompareWaterYear% if both models had stats
                    File0 = fileWaterYear_Alt;
                    File1 = fileWaterYear_Base;
                    FileType = 'WaterYear';
                    fprintf('\n      comparing Water Year Stats');
                else % else skip to next iteration
                    fprintf('\n      One or Both models do not have Water Year Stats....skipping');
                    continue;
                end
                
            % Fifth iteration compares Total Period
            elseif fi == 5
                fprintf('\n     Creating individual Total Analysis Period dfs2 files')
                ComputeTotalAnalysisPeriodStatistics(INI, BaseFolder, BaseNameParts{2}, AltFolder, AltNameParts{2});
                CompareTotalPeriod = exist(fileTotalPeriod_Base,'file') == 2 && exist(fileTotalPeriod_Alt,'file')  == 2;
                if CompareTotalPeriod
                    File0 = fileTotalPeriod_Alt;
                    File1 = fileTotalPeriod_Base;
                    FileType = 'TotalAnalysisPeriod';
                    fprintf('\n      comparing Total Period Stats');
                else % else skip to next iteration
                    fprintf('\n      One or Both models do not have Total Period Stats....skipping');
                    continue;
                end
            end
            
            % Create Output file name
            FileNameOut = [OutDir AltNameParts{3} '-' BaseNameParts{3} '_' FileType '_Diff.dfs2'];
            
            % Open Alternative Model's Stat file
            dfs2File0  = Dfs2File(DfsFileFactory.DfsGenericOpen(File0));
            
            % Open Base Model's Stat file and save metadata
            dfs2File1   = Dfs2File(DfsFileFactory.DfsGenericOpen(File1));
            ProjWktString = dfs2File1.FileInfo.Projection.WKTString;
            ProjLong      = dfs2File1.FileInfo.Projection.Longitude;
            ProjLat       = dfs2File1.FileInfo.Projection.Latitude;
            ProjOri       = dfs2File1.FileInfo.Projection.Orientation;
            
            % Create output file
            % set file metadata
            factory = DfsFactory();
            Title = strcat("2D Stat Compare Alt", AltNumStr, " - Base ", FileType);
            builder = Dfs2Builder.Create(char(Title),'Matlab DFS',0);
            builder.SetDataType(0);
            builder.DeleteValueDouble = -1e-35;
            builder.SetGeographicalProjection(factory.CreateProjectionGeoOrigin(ProjWktString,ProjLong,ProjLat,ProjOri));
            builder.SetTemporalAxis(factory.CreateTemporalNonEqCalendarAxis...
                (eumUnit.eumUsec,System.DateTime(StartDateTime.Year,StartDateTime.Month,StartDateTime.Day,0,0,0)));
            builder.SetSpatialAxis(dfs2File1.SpatialAxis);
            
            % add output Item
            %save item metadata
            for itemI=0:dfs2File1.ItemInfo.Count - 1
                ItemName = dfs2File1.ItemInfo.Item(itemI).Name;
                builder.AddDynamicItem(ItemName,...
                    dfs2File1.ItemInfo.Item(itemI).Quantity,...
                    dfs2File1.ItemInfo.Item(itemI).DataType,...
                    dfs2File1.ItemInfo.Item(itemI).ValueType);
            end
            builder.CreateFile(FileNameOut);
            dfs2Out = Dfs2File(builder.GetFile());
            
            clear ProjWktString ProjLong ProjLat ProjOri HeadMetaData;
            
            % Write to Output
            nG = dfs2File1.SpatialAxis.XCount * dfs2File1.SpatialAxis.YCount; % Spatial Axis Grid Size
            FileOut = zeros(1, nG); % 1D Array for wriiting Output
            noData = dfs2File1.FileInfo.DeleteValueFloat; % File NoData value
            TimeStart = dfs2File1.FileInfo.TimeAxis.StartDateTime; 
            D0 = datetime(TimeStart.Year, TimeStart.Month, TimeStart.Day, TimeStart.Hour,...
                TimeStart.Minute, TimeStart.Second);% First File Time Step DateTime
            try
                % for each time step
                for ts = 0:dfs2File1.FileInfo.TimeAxis.NumberOfTimeSteps - 1
                        File0Data2D = dfs2File0.ReadItemTimeStep(1, ts); % 2d array with stat values
                        currentDateTime = D0 + File0Data2D.Time / 86400; % find datetime of time step
                        if StartDateTime - currentDateTime > 0 % if time step is before analysis period
                            continue; % skip time step
                        elseif EndDateTime - currentDateTime < 0 % if time step is after analysis period
                            break; % end loop
                        end
                    for ii = 1:dfs2File1.ItemInfo.Count % for each item in files
                        File0Data2D = dfs2File0.ReadItemTimeStep(ii, ts); % 2d array with stat values
                        File0Array = double(File0Data2D.Data); % convert to 1D array
                        File1Data2D = dfs2File1.ReadItemTimeStep(ii, ts); % 2d array with stat values
                        File1Array = double(File1Data2D.Data); % convert to 1D array
                        WriteTime = seconds(currentDateTime - StartDateTime); % find elapsed time since output start
                        FileOut(1,:) = noData; % Initialize output values
                        WriteToGrid = File0Array ~= noData & File1Array ~= noData; % find indexes where there is valid data in both files
                        FileOut(WriteToGrid) = File0Array(WriteToGrid) - File1Array(WriteToGrid); % write applicable values to output array
                        dfs2Out.WriteItemTimeStepNext(WriteTime, NET.convertArray(single(FileOut(:)))); % write timestep to file
                    end
                end
                
                dfs2Out.Close();
                dfs2File1.Close();
                dfs2File0.Close();
                
            catch ME
                fprintf('ERROR generating Statistic Differences for model Alt%i and Base for %s period.\n', i, FileType);
                fprintf('-- %s.\n', ME.message);
                dfs2Out.Close();
                dfs2File1.Close();
                dfs2File0.Close();
                delete(FileNameOut); % delete incomplete file, if error during generation
            end
        end
    end
end
end

