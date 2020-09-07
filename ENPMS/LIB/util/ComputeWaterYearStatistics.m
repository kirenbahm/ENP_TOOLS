function ComputeWaterYearStatistics(INI)
% Reads the _2DSZ.dfs2 and _3DSZ.dfs3 to read depth and stage statistics, respectively. 
% Iterates through data to find Statistics for each complete Water Year
% (Period begining on May 1 and ending April 30 the next year) for all avaiable data.
% Writes the Statistics to a Non Equidistant Time Step dfs2 file where the time steps are the 
% start of each complete Water Year 
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

fprintf('\n------------------------------------');
fprintf('\nBeginning ComputeWaterYearStatistics    (%s)',datestr(now));
fprintf('\n------------------------------------');
format compact

% Open _PreProcessed.DFS2 file and read topography and metadata
[topoData,~] = readModelTopo(INI);
topoArray = double(topoData.Data); % topo

% Open _2DSZ.dfs2 file and save metadata
dfs2DepthFile  = Dfs2File(DfsFileFactory.DfsGenericOpen(INI.filePhreatic));
search = '';
itemDepth = -1;
% Find depth to phreatic surface item
field = System.String('depth to phreatic surface (negative)');
while ~strcmp(char(search), char(field))  && itemDepth < dfs2DepthFile.ItemInfo.Count
    itemDepth = (itemDepth + 1);
    search = dfs2DepthFile.ItemInfo.Item(itemDepth).Name;
end

% Save _2DSZ.dfs2 metadata
ProjWktString = dfs2DepthFile.FileInfo.Projection.WKTString;
ProjLong = dfs2DepthFile.FileInfo.Projection.Longitude;
ProjLat = dfs2DepthFile.FileInfo.Projection.Latitude;
ProjOri = dfs2DepthFile.FileInfo.Projection.Orientation;
DepthMetaData = dfs2DepthFile.ItemInfo.Item(itemDepth);
TimeAxis = dfs2DepthFile.FileInfo.TimeAxis;
TimeStart = dfs2DepthFile.FileInfo.TimeAxis.StartDateTime;

% Parse file start and end DateTime
StartDateTime = datetime(TimeStart.Year, TimeStart.Month, TimeStart.Day, TimeStart.Hour, TimeStart.Minute, TimeStart.Second);

% Find Start of First Complete Water Year
% If first file Time step Occurs on May 1, then starting first
% complete water year
if datetime(StartDateTime.Year, 5,1,0,0,0) - StartDateTime == 0
    WaterYearStartDateTime = datetime(StartDateTime.Year, 5,1,0,0,0); % Start Date of first complete water year
    WaterYearComplete = true; % current water year is complete
    CurrentYear = StartDateTime.Year; % Start Year of First Water Year
% If first file Time step Occurs after May 1, then the first complete water year
% starts next year on May 1
elseif datetime(StartDateTime.Year, 5,1,0,0,0) - StartDateTime < 0
    WaterYearStartDateTime = datetime(StartDateTime.Year + 1, 5,1,0,0,0); % Start Date of first complete water year
    WaterYearComplete = false; % current water year is incomplete
    CurrentYear = StartDateTime.Year; % Start Year of First Water Year
% If first file Time step Occurs before May 1, then the first complete water year
% starts this year on May 1, and file start is partway through the incomplete
% previous water year
else % else the first complete water year starts on May 1 of the current year
    WaterYearStartDateTime = datetime(StartDateTime.Year, 5,1,0,0,0); % Start Date of first complete water year
    WaterYearComplete =false; % current water year is incomplete
    CurrentYear = StartDateTime.Year - 1; % Start Year of First Water Year
end

% Create output file
% set file metadata
factory = DfsFactory();
builder = Dfs2Builder.Create(char("Water Year Statistics"),'Matlab DFS',0);
builder.SetDataType(0);
builder.DeleteValueDouble = -1e-35;
builder.SetGeographicalProjection(factory.CreateProjectionGeoOrigin(ProjWktString,ProjLong,ProjLat,ProjOri));
builder.SetTemporalAxis(factory.CreateTemporalNonEqCalendarAxis...
    (eumUnit.eumUsec,System.DateTime(WaterYearStartDateTime.Year,WaterYearStartDateTime.Month,WaterYearStartDateTime.Day,0,0,0)));
builder.SetSpatialAxis(dfs2DepthFile.SpatialAxis);

% add output Item
builder.AddDynamicItem(System.String('mean water level'), ...
    DepthMetaData.Quantity, ...
    DepthMetaData.DataType, DepthMetaData.ValueType);

% add output Item
builder.AddDynamicItem(System.String('mean water depth'), ...
    DepthMetaData.Quantity, ...
    DepthMetaData.DataType, DepthMetaData.ValueType);

% add output Item
builder.AddDynamicItem(System.String('Hydroperiod1 Fraction'), ...
    DHI.Generic.MikeZero.eumQuantity(eumItem.eumIFraction,eumUnit.eumUPerCent), ...
    DepthMetaData.DataType, DepthMetaData.ValueType);

% add output Item
builder.AddDynamicItem(System.String('hydroperiod1 (total no. days per water year, discontinuous)'), ...
    DHI.Generic.MikeZero.eumQuantity(eumItem.eumIItemUndefined,eumUnit.eumUUnitUndefined), ...
    DepthMetaData.DataType, DepthMetaData.ValueType);

% add output Item
builder.AddDynamicItem(System.String('mean water depth during hydroperiod1 (total no. days per water year, discontinuous)'), ...
    DepthMetaData.Quantity, ...
    DepthMetaData.DataType, DepthMetaData.ValueType);

% add output Item
builder.AddDynamicItem(System.String('hydroperiod2 (max continuous no. days per water year)'), ...
    DHI.Generic.MikeZero.eumQuantity(eumItem.eumIItemUndefined,eumUnit.eumUUnitUndefined), ...
    DepthMetaData.DataType, DepthMetaData.ValueType);

% add output Item
builder.AddDynamicItem(System.String('mean water depth during hydroperiod2 (max continuous no. days per water year)'), ...
    DepthMetaData.Quantity, ...
    DepthMetaData.DataType, DepthMetaData.ValueType);

builder.CreateFile(INI.fileWaterYearStats);
dfs2Out = Dfs2File(builder.GetFile());
clear ProjWktString ProjLong ProjLat ProjOri HeadMetaData;

% Initialize Variable for calculations and Outputs
nG = dfs2Out.SpatialAxis.XCount * dfs2Out.SpatialAxis.YCount; % Spatial Axis Grid Size
AverageStage = zeros(1, nG); % 1D  Array for writing Output Stage
AverageDepth = zeros(1, nG); % 1D  Array for writing Output Depth
DisConHydroPeriod = zeros(1, nG); % 1D  Array for writing Output Discontinuous Hydroperiod
DisConHydroPeriodMeanDepth = zeros(1, nG); % 1D  Array for writing Output Mean Depth during Discontinuous Hydroperiod
% For Max Continuous Hydroperiod we have 2 sets of arrays.
% One is the Max for the current Water Year in the period.
% One is the current max as is iterates through the Water Year
MaxConHydroPeriod = zeros(1, nG);
MaxConHydroPeriodMeanDepth = zeros(1, nG);
CurrentConHydroPeriod = zeros(1, nG);
CurrentConHydroPeriodMeanDepth = zeros(1, nG);
% Iteration variables
NoTSperYear = round(365.25*24*60*60/TimeAxis.TimeStep);  % # of time steps per year
NoTSperDay = round(86400/TimeAxis.TimeStep); % # of time steps per Day
DT0 = datetime(TimeStart.Year, TimeStart.Month, TimeStart.Day, TimeStart.Hour,...
    TimeStart.Minute, TimeStart.Second);% First File Time Step DateTime
noData = dfs2DepthFile.FileInfo.DeleteValueFloat; % No data value for file
WriteTime = 0; % Elapsed Time for Output TimeStep
currentDateTime = DT0 - TimeAxis.TimeStep/86400; % Keeps track of current date time
nts = 0;  % counter for # of time steps
try
    % Loop through all time steps, plus one
    % Runs 1 extra iteration that is caught in order to add final Month
    % values into output file before exiting loop.
    % i.e Final time step in file is April 30. Run one more iteration,
    % currentDateTime moves to May 1 and triggers Water Year write
    for ts = 0:TimeAxis.NumberOfTimeSteps
        if mod(ts,NoTSperYear) == 0 % print running update to Command Window
            fprintf('\n      reading step %i%s%i and counting',ts+1, '/', TimeAxis.NumberOfTimeSteps);
        end
        currentDateTime = currentDateTime + TimeAxis.TimeStep/86400;  % Increment current DateTime based on TimeStep
        if currentDateTime > datetime(CurrentYear + 1, 4,30,0,0,0) % If new water year
            if WaterYearComplete
                AverageStage = AverageStage / nts; % Summed Stages divided by number of days
                AverageDepth = AverageDepth / nts; % Summed Depths divided by number of days
                HydroperiodFraction = DisConHydroPeriod / nts; % Hydroperiod Fraction = Discontinuous Hydroperiod / # of days
                % Hydroperiod Statistic Calculations
                % Summed Discontinous Hydroperiod Depths divided by # of days
                DisConHydroPeriodMeanDepth = DisConHydroPeriodMeanDepth ./ DisConHydroPeriod;
                % Summed Max Continous Hydroperiod Depths divided by # of days
                MaxConHydroPeriodMeanDepth = MaxConHydroPeriodMeanDepth ./ MaxConHydroPeriod;
                % Convert Hydroperiod from Total Timesteps to Total Days
                DisConHydroPeriod = DisConHydroPeriod / NoTSperDay;
                MaxConHydroPeriod = MaxConHydroPeriod / NoTSperDay;
                % Find indexes where Discontinuous Hydroperiod = 0
                WriteToGrid = DisConHydroPeriod == 0;
                % Set Discontinuous Hydroperiod Mean Depth at indexes = 0
                DisConHydroPeriodMeanDepth(WriteToGrid) = 0;
                % Find indexes where Max Continuous Hydroperiod = 0
                WriteToGrid = MaxConHydroPeriod == 0;
                % Set Max Continuous Hydroperiod Mean Depth at indexes = 0
                MaxConHydroPeriodMeanDepth(WriteToGrid) = 0;
                % Find indexes outside domain where noData values are
                WriteToGrid = DepthArray == noData;
                % Set values at indexes to noData Values
                AverageStage(WriteToGrid) = noData;
                WriteToGrid = DepthArray == noData;
                AverageDepth(WriteToGrid) = noData;
                HydroperiodFraction(WriteToGrid) = noData;
                DisConHydroPeriod(WriteToGrid) = noData;
                DisConHydroPeriodMeanDepth(WriteToGrid) = noData;
                MaxConHydroPeriod(WriteToGrid) = noData;
                MaxConHydroPeriodMeanDepth(WriteToGrid) = noData;
                % Write Output Arrays to Output dfs2 file
                dfs2Out.WriteItemTimeStepNext(WriteTime, NET.convertArray(single(AverageStage(:))));
                dfs2Out.WriteItemTimeStepNext(WriteTime, NET.convertArray(single(AverageDepth(:))));
                dfs2Out.WriteItemTimeStepNext(WriteTime, NET.convertArray(single(HydroperiodFraction(:))));
                dfs2Out.WriteItemTimeStepNext(WriteTime, NET.convertArray(single(DisConHydroPeriod(:))));
                dfs2Out.WriteItemTimeStepNext(WriteTime, NET.convertArray(single(DisConHydroPeriodMeanDepth(:))));
                dfs2Out.WriteItemTimeStepNext(WriteTime, NET.convertArray(single(MaxConHydroPeriod(:))));
                dfs2Out.WriteItemTimeStepNext(WriteTime, NET.convertArray(single(MaxConHydroPeriodMeanDepth(:))));
            end
            % reset arrays for calculating Water Year statistics
            AverageStage = zeros(1, nG);
            AverageDepth = zeros(1, nG);
            DisConHydroPeriod = zeros(1, nG);
            DisConHydroPeriodMeanDepth = zeros(1, nG);
            MaxConHydroPeriod = zeros(1, nG);
            MaxConHydroPeriodMeanDepth = zeros(1, nG);
            CurrentConHydroPeriod = zeros(1, nG);
            CurrentConHydroPeriodMeanDepth = zeros(1, nG);
            nts = 0; % reset Counter for Time steps
            CurrentYear = currentDateTime.Year; % Set calculation cut off to new Water Year
            WriteTime = seconds(currentDateTime - WaterYearStartDateTime); % Find elapsed time from start to
            EndPrior = currentDateTime - TimeAxis.TimeStep/86400; % Find previous time step
            % Water year complete if current time step and previous time
            % step are in different water years
            WaterYearComplete = currentDateTime - datetime(CurrentYear, 4,30,0,0,0) > 0 && ...
              EndPrior - datetime(CurrentYear, 4,30,0,0,0) <= 0;
        end
        % if final loop iteration, break loop after write, if necessary. No data left to read
        if ts == TimeAxis.NumberOfTimeSteps
            break;
        end
        DepthData3D = dfs2DepthFile.ReadItemTimeStep(itemDepth + 1, ts); % 3d array with depths
        DepthArray = double(DepthData3D.Data); % convert to 1D array
        AverageStage = AverageStage + DepthArray + topoArray; % Add top layer head values to average stage
        DepthArray(DepthArray < 0 & DepthArray ~= noData) = 0; % Depth values below ground are 0
        AverageDepth = AverageDepth + DepthArray; % Add Depth values to average depth
        nts = nts + 1; % Increment time step counter
        WriteToGrid = DepthArray > INI.HYDROPERIOD_THRESHOLD;% Find indexes where current depth is above hydroperiod threshhold.
        % At indexes, increment Discontinuous Hydroperiod
        % and add depth to Mean Depth
        DisConHydroPeriod(WriteToGrid) = DisConHydroPeriod(WriteToGrid) + 1;
        DisConHydroPeriodMeanDepth(WriteToGrid) = DisConHydroPeriodMeanDepth(WriteToGrid) + DepthArray(WriteToGrid);
        % Where current Continous Hydroperiod is managaed.
        % At indexes where depth is above hydroperiod threshold:
        % Increment Hydroperiod
        CurrentConHydroPeriod(WriteToGrid) = CurrentConHydroPeriod(WriteToGrid) + 1;
        % Add depth to Mean Depth
        CurrentConHydroPeriodMeanDepth(WriteToGrid) = CurrentConHydroPeriodMeanDepth(WriteToGrid) + DepthArray(WriteToGrid);
        % At indexes where depth is below hydroperiod threshold:
        % Set Hydroperiod to 0
        CurrentConHydroPeriod(~WriteToGrid) = 0;
        % Set Mean Depth to 0
        CurrentConHydroPeriodMeanDepth(~WriteToGrid) = 0;
        % Find indexes where Current Continuous Hydroperiod
        % is greater than Max Continuous Hydroperiod
        WriteToGrid = CurrentConHydroPeriod > MaxConHydroPeriod;
        % Set Max Values equal to Current values at those indexes.
        MaxConHydroPeriod(WriteToGrid)  = CurrentConHydroPeriod(WriteToGrid);
        MaxConHydroPeriodMeanDepth(WriteToGrid) = CurrentConHydroPeriodMeanDepth(WriteToGrid);
    end
    dfs2Out.Close();
    dfs2DepthFile.Close();
    fprintf('\n      Water Year Statistics Successfully Generated.\n');
catch ME
    fprintf('ERROR generating Calendar Year Stats.\n');
    fprintf('-- %s.\n', ME.message);
    dfs2Out.Close();
    dfs2DepthFile.Close();
    delete(INI.fileWaterYearStats); % Delete Partially Written File If there is an error
end
clear AverageStage AverageDepth DisConHydroPeriod DisConHydroPeriodMeanDepth WriteToGrid;
clear MaxConHydroPeriod MaxConHydroPeriodMeanDepth CurrentConHydroPeriod CurrentConHydroPeriodMeanDepth;

end
