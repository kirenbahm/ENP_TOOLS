function ComputeTotalAnalysisPeriodStatistics(INI, BaseFolder, BaseName, AltFolder, AltName)
% Reads the _MonthlyStats.dfs2 to read depth and stage statistics, respectively.
% Iterates through data to find Statistics for the whole analysis period,including data from incomplete calendar months.
% For example, for a period between 1/1/2000 to 12/15/2005
% the period 1/1/2000 - 12/31/2005 is considered
% Writes the Statistics to a Non Equidistant Time Step dfs2 file where the only time step is the
% start of the first complete Calendar Month in the Analysis Period

% Import Statements
NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfs0.*;
NET.addAssembly('DHI.Generic.MikeZero.EUM');
NET.addAssembly('DHI.Generic.MikeZero.DFS');
H = NETaddDfsUtil();
eval('import DHI.Generic.MikeZero.DFS.*');
eval('import DHI.Generic.MikeZero.DFS.dfs123.*');
eval('import DHI.Generic.MikeZero.*');

% Parse Monthly Stat File Names for both Simulations.
fileBaseMo      = [BaseFolder BaseName, '_MonthlyStats.dfs2'];  % Base Model Monthly Stats
fileAltMo       = [AltFolder AltName, '_MonthlyStats.dfs2'];  % Alternative Model Monthly Stats

% Open _MonthlyStats.dfs2 file and save metadata
dfs2BaseMo  = Dfs2File(DfsFileFactory.DfsGenericOpen(fileBaseMo));
search = '';
itemDepthBase = -1;
% Find Mean water depth item
field = System.String('mean water depth');
while ~strcmp(char(search), char(field))  && itemDepthBase < dfs2BaseMo.ItemInfo.Count
    itemDepthBase = (itemDepthBase + 1);
    search = dfs2BaseMo.ItemInfo.Item(itemDepthBase).Name;
end
search = '';
itemStageBase = -1;
% Find Mean water level item
field = System.String('mean water level');
while ~strcmp(char(search), char(field))  && itemStageBase < dfs2BaseMo.ItemInfo.Count
    itemStageBase = (itemStageBase + 1);
    search = dfs2BaseMo.ItemInfo.Item(itemStageBase).Name;
end

% Save File Metadata for use in creating outputs
ProjWktString = dfs2BaseMo.FileInfo.Projection.WKTString;
ProjLong = dfs2BaseMo.FileInfo.Projection.Longitude;
ProjLat = dfs2BaseMo.FileInfo.Projection.Latitude;
ProjOri = dfs2BaseMo.FileInfo.Projection.Orientation;
DepthMetaData = dfs2BaseMo.ItemInfo.Item(itemDepthBase);

% Open _MonthlyStats.dfs2 file and save metadata
dfs2AltMo  = Dfs2File(DfsFileFactory.DfsGenericOpen(fileAltMo));
search = '';
itemDepthAlt = -1;
% Find Mean water depth item
field = System.String('mean water depth');
while ~strcmp(char(search), char(field))  && itemDepthAlt < dfs2AltMo.ItemInfo.Count
    itemDepthAlt = (itemDepthAlt + 1);
    search = dfs2AltMo.ItemInfo.Item(itemDepthAlt).Name;
end
search = '';
itemStageAlt = -1;
% Find Mean water level item
field = System.String('mean water level');
while ~strcmp(char(search), char(field))  && itemStageAlt < dfs2AltMo.ItemInfo.Count
    itemStageAlt = (itemStageAlt + 1);
    search = dfs2AltMo.ItemInfo.Item(itemStageAlt).Name;
end

% Save TimeAxis and StartDateTime for monthly stat file for both models
TimeAxisBase = dfs2BaseMo.FileInfo.TimeAxis;
TimeAxisAlt = dfs2AltMo.FileInfo.TimeAxis;
TimeStartBase = TimeAxisBase.StartDateTime;
TimeStartAlt = TimeAxisAlt.StartDateTime;

% Parse file start and end DateTime
StartDateTimeBase = datetime(TimeStartBase.Year, TimeStartBase.Month, TimeStartBase.Day,...
    TimeStartBase.Hour, TimeStartBase.Minute, TimeStartBase.Second);
StartDateTimeAlt = datetime(TimeStartAlt.Year, TimeStartAlt.Month, TimeStartAlt.Day,...
    TimeStartAlt.Hour, TimeStartAlt.Minute, TimeStartAlt.Second);
StartDateTimeAnalysis = datetime(INI.ANALYZE_DATE_I);

EndDateTimeBase = StartDateTimeBase + (TimeAxisBase.TimeSpan / 86400);
EndDateTimeAlt = StartDateTimeAlt + (TimeAxisAlt.TimeSpan / 86400);
EndDateTimeAnalysis = datetime(INI.ANALYZE_DATE_F);

% StartDateTime is the Latest Start DateTime between files and analysis period
% EndDateTime is earliest End DateTime between files and analysis period
% ie Analysis Period 1/1/2000 - 12/31/2005 
    % with monthly stats for 1/1/1999 - 12/31/2004
    % Final Period is 1/1/2000 - 12/31/2004
StartDateTime = max([StartDateTimeBase StartDateTimeAlt StartDateTimeAnalysis]);
EndDateTime = min([EndDateTimeBase EndDateTimeAlt EndDateTimeAnalysis]);
% End Date Time is end of final month
% ie EndDateTime 12/15/2005 -> 12/31/2005
EndDateTime = datetime(EndDateTime.Year, EndDateTime.Month, calc_DaysInMonth(EndDateTime.Year, EndDateTime.Month), 0, 0, 0);

% If no complete years, report and end script
if EndDateTime - StartDateTime <= 0
    fprintf('ERROR generating Total Period Stats - No Complete Calendar Years.\n');
    return;
end

% Creat strings for Year and Month for both Start and End
% For use is file generation to define Analysis period without repeated
% calls to num2str
StartMonthStr = num2str(StartDateTime.Month);
StartYearStr = num2str(StartDateTime.Year);
EndMonthStr = num2str(EndDateTime.Month);
EndYearStr = num2str(EndDateTime.Year);

% Loop through Both model's Monthly file and generate Analysis Period Stats
for ii = 1:2
    % Use switch Statment to set generic names for Model specific
    % variables. Uses generic names in to loop through data and create
    % output files.
    switch ii
        case 1
            TimeAxis = TimeAxisBase; % Time axis for MonthlyStats.dfs2
            dfs2Monthly = dfs2BaseMo; % File Handle for MonthlyStats.dfs2
            itemDepth = itemDepthBase; % Item Index for Depth Data in MonthlyStats.dfs2
            itemStage = itemStageBase; % Item Index for Stage Data in MonthlyStats.dfs2
            AnalysisFileName = [BaseFolder BaseName '_TotalAnalysisPeriodStats(' StartMonthStr '_' StartYearStr '_' EndMonthStr '_' EndYearStr ').dfs2']; % Output file name
        case 2
            TimeAxis = TimeAxisAlt;
            dfs2Monthly = dfs2AltMo;
            itemDepth = itemDepthAlt;
            itemStage = itemStageAlt;
            AnalysisFileName = [AltFolder AltName, '_TotalAnalysisPeriodStats(' StartMonthStr '_' StartYearStr '_' EndMonthStr '_' EndYearStr ').dfs2'];
    end
    
    %Create Output dfs2 file
    % set file metadata
    factory = DfsFactory();
    builder = Dfs2Builder.Create(char(strcat('Total Analysis Period Statistics(', StartMonthStr, '/', StartYearStr,'-',...
        EndMonthStr, '/', EndYearStr,')')),'Matlab DFS',0);
    builder.SetDataType(0);
    builder.DeleteValueDouble = -1e-35;
    builder.SetGeographicalProjection(factory.CreateProjectionGeoOrigin(ProjWktString,ProjLong,ProjLat,ProjOri));
    builder.SetTemporalAxis(factory.CreateTemporalNonEqCalendarAxis...
        (eumUnit.eumUsec,System.DateTime(StartDateTime.Year,StartDateTime.Month,StartDateTime.Day,0,0,0)));
    builder.SetSpatialAxis(dfs2BaseMo.SpatialAxis);
    
    % add output Item
    builder.AddDynamicItem(System.String(...
        strcat('mean water level (', StartMonthStr, '/', StartYearStr,'-',...
        EndMonthStr, '/', EndYearStr,')')), ...
        DepthMetaData.Quantity, ...
        DepthMetaData.DataType, DepthMetaData.ValueType);
    
    % add output Item
    builder.AddDynamicItem(System.String(...
        strcat('mean water depth (', StartMonthStr, '/', StartYearStr,'-',...
        EndMonthStr, '/', EndYearStr,')')), ...
        DepthMetaData.Quantity, ...
        DepthMetaData.DataType, DepthMetaData.ValueType);
    
    builder.CreateFile(AnalysisFileName);
    dfs2Out = Dfs2File(builder.GetFile());
    
    % Initialize Variable for calculations and Outputs
    nG = dfs2Out.SpatialAxis.XCount * dfs2Out.SpatialAxis.YCount; % Find grid size from spatial Axis
    AverageStage = zeros(1, nG);  % 1D  Array for writing Output Stage
    AverageDepth = zeros(1, nG); % 1D  Array for writing Output Depth
    noData = dfs2Monthly.FileInfo.DeleteValueFloat; % No data value for file
    TimeStart = TimeAxis.StartDateTime; % Find Start DateTime
    D0 = datetime(TimeStart.Year, TimeStart.Month, TimeStart.Day, TimeStart.Hour,...
        TimeStart.Minute, TimeStart.Second);% First File Time Step DateTime
    try
        % Loop through all time steps
        for ts = 0:TimeAxis.NumberOfTimeSteps - 1
            if mod(ts,12) == 0 % print running update to Command Window
                fprintf('\n      reading step %i%s%i and counting',ts+1, '/', TimeAxis.NumberOfTimeSteps);
            end
            % Find Stage Data, Depth Data, and DateTime at timestep
            StageData3D = dfs2Monthly.ReadItemTimeStep(itemStage + 1, ts);
            DepthData3D = dfs2Monthly.ReadItemTimeStep(itemDepth + 1, ts);
            currentDateTime = D0 + StageData3D.Time / 86400;
            % If currentDateTime is before Analysis period, skip to next
            % time step
            if currentDateTime < StartDateTime
                continue;
            % If currentDateTime is after Analysis period, break loop
            elseif currentDateTime > EndDateTime
                break;
            end
            % 3d array with stages
            HeadArray = double(StageData3D.Data); % convert to 1D array
            
            % Calculate Stage for month using average and #days in month
            MonthHead = (HeadArray * calc_DaysInMonth(currentDateTime.Year, currentDateTime.Month));
            
            % Add to average Stage to get total average for season later
            AverageStage = AverageStage + MonthHead;
            
            % 3d array with depths
            DepthArray = double(DepthData3D.Data); % convert to 1D array
            
            % Calculate Depth for month using average and #days in month
            MonthDepth = (DepthArray * calc_DaysInMonth(currentDateTime.Year, currentDateTime.Month));
            
            % Add to average Depth to get total average for season later
            AverageDepth = AverageDepth + MonthDepth;
        end
        daysinperiod = days(EndDateTime - StartDateTime) + 1; %Finds # of days in Analysis Period
        AverageStage = AverageStage / daysinperiod; % divide total Stage by number of days for average
        AverageDepth = AverageDepth / daysinperiod; % divide total depth by number of days for average
        WriteToGrid = HeadArray == noData; % Find indexes of noData values
        AverageStage(WriteToGrid) = noData; % Write noData to those indexes
        WriteToGrid = DepthArray == noData;% Find indexes of noData values
        AverageDepth(WriteToGrid) = noData; % Write noData to those indexes
        dfs2Out.WriteItemTimeStepNext(0, NET.convertArray(single(AverageStage(:)))); % Write Stages to output file
        dfs2Out.WriteItemTimeStepNext(0, NET.convertArray(single(AverageDepth(:)))); % Write Depths to output file
        dfs2Monthly.Close(); % Close MonthlyStats.dfs2 File
        dfs2Out.Close();% Close output file
    catch ME
        fprintf('ERROR generating Total Period Stats.\n');
        fprintf('-- %s.\n', ME.message);
        dfs2Monthly.Close();
        dfs2Out.Close();
        delete(AnalysisFileName); % Delete Partially Written File If there is an error
    end
end
end