function ComputeTotalSimulationPeriodStatistics(INI)
% Reads the _2DSZ.dfs2 and _3DSZ.dfs3 to read depth and stage statistics, respectively. 
% Iterates through data to find Statistics for the whole period of record,excluding data from incomplete calendar years.
% For example, for a period between 1/1/2000 to 6/1/2005 
% only 1/1/2000 - 12/31/2004 is considered
% Writes the Statistics to a Non Equidistant Time Step dfs2 file where the only time step is the 
% start of the first complete Calendar Year 
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
fprintf('\nBeginning ComputeTotalPeriodStatistics    (%s)',datestr(now));
fprintf('\n------------------------------------');
format compact

% Open _2DSZ.dfs2 file and save metadata
dfs2DepthFile  = Dfs2File(DfsFileFactory.DfsGenericOpen(INI.filePhreatic));%Dfs2File();
search = '';
itemDepth = -1;
% Find depth to phreatic surface item
field = System.String('depth to phreatic surface (negative)');
while ~strcmp(char(search), char(field))  && itemDepth < dfs2DepthFile.ItemInfo.Count
    itemDepth = (itemDepth + 1);
    search = dfs2DepthFile.ItemInfo.Item(itemDepth).Name;
end

%Open _3DSZ.dfs3 file and save metadata
dfs3HeadFile = Dfs3File(DfsFileFactory.DfsGenericOpen(INI.fileSZ));
ProjWktString = dfs2DepthFile.FileInfo.Projection.WKTString;
ProjLong = dfs2DepthFile.FileInfo.Projection.Longitude;
ProjLat = dfs2DepthFile.FileInfo.Projection.Latitude;
ProjOri = dfs2DepthFile.FileInfo.Projection.Orientation;
DepthMetaData = dfs2DepthFile.ItemInfo.Item(itemDepth);
TimeAxis = dfs2DepthFile.FileInfo.TimeAxis;
TimeStart = dfs2DepthFile.FileInfo.TimeAxis.StartDateTime;

% Parse file start and end DateTime
StartDateTime = datetime(TimeStart.Year, TimeStart.Month, TimeStart.Day, TimeStart.Hour, TimeStart.Minute, TimeStart.Second);
EndDateTime = StartDateTime + seconds(TimeAxis.TimeStep * (TimeAxis.NumberOfTimeSteps - 1));
StartPrior = StartDateTime - TimeAxis.TimeStep/86400;
EndNext = EndDateTime + TimeAxis.TimeStep/86400;

% If first time step isnt at the begining of the year, then start data
% collection at start of first full year.
YearComplete = StartDateTime.Year ~= StartPrior.Year;
if ~YearComplete
    StartDateTime = datetime(StartDateTime.Year + 1, 1,1,0,0,0);
else
    StartDateTime = datetime(StartDateTime.Year, 1,1,0,0,0);
end

% If last time step isnt at the end of the year, then end data
% collection at end of last full year.
if EndDateTime.Year == EndNext.Year
    EndDateTime = datetime(EndDateTime.Year - 1, 12,31,23,59,59);
else
    EndDateTime = datetime(EndDateTime.Year, 12,31,23,59,59);
end

% If no complete years, report and end script
if EndDateTime - StartDateTime <= 0
    fprintf('ERROR generating Total Period Stats - No Complete Calendar Years.\n');
    return;
end

% Create output file
% set file metadata
factory = DfsFactory();
builder = Dfs2Builder.Create(char("Total Period Statistics"),'Matlab DFS',0);
builder.SetDataType(0);
builder.DeleteValueDouble = -1e-35;
builder.SetGeographicalProjection(factory.CreateProjectionGeoOrigin(ProjWktString,ProjLong,ProjLat,ProjOri));
builder.SetTemporalAxis(factory.CreateTemporalNonEqCalendarAxis...
    (eumUnit.eumUsec,System.DateTime(StartDateTime.Year,StartDateTime.Month,StartDateTime.Day,0,0,0)));
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
builder.AddDynamicItem(System.String('hydroperiod1 (avg. no. days per year, discontinuous)'), ...
    DHI.Generic.MikeZero.eumQuantity(eumItem.eumIItemUndefined,eumUnit.eumUUnitUndefined), ...
    DepthMetaData.DataType, DepthMetaData.ValueType);

% add output Item
builder.AddDynamicItem(System.String('mean water depth during hydroperiod1 (avg. no. days per year, discontinuous)'), ...
    DepthMetaData.Quantity, ...
    DepthMetaData.DataType, DepthMetaData.ValueType);

% add output Item
builder.AddDynamicItem(System.String('hydroperiod2 (avg. max continuous no. days per year)'), ...
    DHI.Generic.MikeZero.eumQuantity(eumItem.eumIItemUndefined,eumUnit.eumUUnitUndefined), ...
    DepthMetaData.DataType, DepthMetaData.ValueType);

% add output Item
builder.AddDynamicItem(System.String('mean water depth during hydroperiod2 (avg. max continuous no. days per year)'), ...
    DepthMetaData.Quantity, ...
    DepthMetaData.DataType, DepthMetaData.ValueType);

builder.CreateFile(INI.fileTotalSimulationPeriodStats);
dfs2Out = Dfs2File(builder.GetFile());
clear ProjWktString ProjLong ProjLat ProjOri HeadMetaData;

% Initialize Variable for calculations and Outputs
nG = dfs2Out.SpatialAxis.XCount * dfs2Out.SpatialAxis.YCount; % Find grid size from spatial Axis
AverageStage = zeros(1, nG);  % 1D  Array for writing Output Stage
AverageDepth = zeros(1, nG); % 1D  Array for writing Output Depth
DisConHydroPeriod = zeros(1, nG);  % 1D  Array for writing Output Discontinuous Hydroperiod
DisConHydroPeriodMeanDepth = zeros(1, nG);  % 1D  Array for writing Output Mean Depth during Discontinuous Hydroperiod
% For Max Continuous Hydroperiod we have 3 sets of arrays.
% One is the Max for the current year in the period.
% One is the current max as is iterates through the year
% One is the Total for the period. When a Max is found at the end of the
%   year it is added to the total in order to find the average max
%   continuous hyerperiod (#days per year) in the period. Same for the Average Depth during Max Hydroperiod
MaxConHydroPeriod = zeros(1, nG);
MaxConHydroPeriodMeanDepth = zeros(1, nG);
CurrentConHydroPeriod = zeros(1, nG);
CurrentConHydroPeriodMeanDepth = zeros(1, nG);
TotalConHydroPeriod = zeros(1, nG);
TotalConHydroPeriodMeanDepth = zeros(1, nG);

% Iteration variables
NoTSperYear = round(365.25*24*60*60/TimeAxis.TimeStep);   % # of time steps per year
NoTSperDay = round(86400/TimeAxis.TimeStep);  % # of time steps per Day
noData = dfs2DepthFile.FileInfo.DeleteValueFloat; % No data value for file
DT0 = datetime(TimeStart.Year, TimeStart.Month, TimeStart.Day, TimeStart.Hour,...
    TimeStart.Minute, TimeStart.Second); % First File Time Step DateTime
CurrentYear = DT0.Year;% Current Complete Calendar Year
currentDateTime = DT0 - TimeAxis.TimeStep/86400; % Keeps track of current date time
nts = 0;
try
    % Loop through all time steps, plus one
    % Runs 1 extra iteration that is caught in order to add final year
    % values into total arrays before exiting loop.
    for ts = 0:TimeAxis.NumberOfTimeSteps
        if mod(ts,NoTSperYear) == 0 % print running update to Command Window
            fprintf('\n      reading step %i%s%i and counting',ts+1, '/', TimeAxis.NumberOfTimeSteps-1);
        end
        currentDateTime = currentDateTime + (TimeAxis.TimeStep/ 86400); % Calculate DateTime for time step
        if currentDateTime.Year ~= CurrentYear % If current Time Step is a new year from prior, then sum Values from Max Hydroperiod into total
            if YearComplete % Sum only if calendar year is complete
                WriteToGrid = MaxConHydroPeriod == 0; % Find indexes where Max Hydroperiod = 0
                MaxConHydroPeriodMeanDepth(WriteToGrid) = 0; % Set the Mean Depth to 0 at indexes
                TotalConHydroPeriod = TotalConHydroPeriod + MaxConHydroPeriod; % Added yearly max to period max for averaging later
                TotalConHydroPeriodMeanDepth = TotalConHydroPeriodMeanDepth + MaxConHydroPeriodMeanDepth;% Added yearly max to period max for averaging later
            end
            % reset arrays for calculating yearly statistics
            MaxConHydroPeriod = zeros(1, nG); 
            MaxConHydroPeriodMeanDepth = zeros(1, nG);
            CurrentConHydroPeriod = zeros(1, nG);
            CurrentConHydroPeriodMeanDepth = zeros(1, nG);
            YearComplete = currentDateTime.Year ~= CurrentYear; 
            CurrentYear = currentDateTime.Year; % Set calculation cut off to new Calendar Year
        end
        if currentDateTime - StartDateTime < 0 % If timestep year was during a front end incomplete year, skip iteration
            continue;
        elseif currentDateTime - EndDateTime > 0 % If timestep year was during a back end incomplete year, break loop
            break;
        end
        DepthData2D = dfs2DepthFile.ReadItemTimeStep(itemDepth + 1, ts); % 2d array with depths
        DepthArray = double(DepthData2D.Data); % convert to 1D array
        StageData3D = dfs3HeadFile.ReadItemTimeStep(1, ts); % 3d array with depths
        HeadArray = double(StageData3D.Data); % convert to 1D array
        HeadTop = HeadArray(end - nG + 1: end); % Find top layer of head values
        AverageStage = AverageStage + HeadTop; % Add top layer head values to average stage
        AverageDepth = AverageDepth + DepthArray; % Add Depth values to average depth
        WriteToGrid = DepthArray > INI.HYDROPERIOD_THRESHOLD; % Find indexes where current depth is above hydroperiod threshhold. 
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
        nts = nts + 1; % Increment time step counter
    end
    yearsinperiod = EndDateTime.Year - StartDateTime.Year + 1; % Number of years in period for averaging
    AverageStage = AverageStage / nts; % Summed Stages divided by number of time steps
    AverageDepth = AverageDepth / nts; % Summed Depths divided by number of time steps
    HydroperiodFraction = DisConHydroPeriod / nts; % Hydroperiod Fraction = Discontinuous Hydroperiod time steps/ # of time steps
    
    % Hydroperiod Statistic Calculations
    % Summed Discontinous Hydroperiod Depths divided by # of timesteps
    DisConHydroPeriodMeanDepth = DisConHydroPeriodMeanDepth ./ DisConHydroPeriod;
    % Summed Max Continuous Hydroperiod Depths divided by # of timesteps
    TotalConHydroPeriodMeanDepth = TotalConHydroPeriodMeanDepth ./ TotalConHydroPeriod;
    
    % Hydroperiod Days per Year calculations
    % Discontinuous Hydroperiod (# of time steps/ #ofTimeStepsperday) / number of years
    DisConHydroPeriod = (DisConHydroPeriod /NoTSperDay) / yearsinperiod; % Average number of days per year
    % Sum of Max Continuous Hydroperiod (# of time steps/ #ofTimeStepsperday) / number of years
    TotalConHydroPeriod = (TotalConHydroPeriod / NoTSperDay) / yearsinperiod; % Average number of days per year
    
    % Find indexes where Discontinuous Hydroperiod = 0
    WriteToGrid = DisConHydroPeriod == 0; 
    % Set Discontinuous Hydroperiod Mean Depth at indexes = 0
    DisConHydroPeriodMeanDepth(WriteToGrid) = 0;  
    % Find indexes where Summed Max Continuous Hydroperiod = 0
    WriteToGrid = TotalConHydroPeriod == 0;
    % Set Max Continuous Hydroperiod Mean Depth at indexes = 0
    TotalConHydroPeriodMeanDepth(WriteToGrid) = 0;
    % Find indexes outside domain where noData values are
    WriteToGrid = HeadTop == noData;
    % Set values at indexes to noData Values
    AverageStage(WriteToGrid) = noData;
    % Find indexes outside domain where noData values
    WriteToGrid = DepthArray == noData;
    % Set values at indexes to noData Values
    AverageDepth(WriteToGrid) = noData;
    % Set values at indexes to noData Values
    HydroperiodFraction(WriteToGrid) = noData;
    % Set values at indexes to noData Values
    DisConHydroPeriod(WriteToGrid) = noData;
    % Set values at indexes to noData Values
    DisConHydroPeriodMeanDepth(WriteToGrid) = noData;
    % Set values at indexes to noData Values
    TotalConHydroPeriod(WriteToGrid) = noData;
    % Set values at indexes to noData Values
    TotalConHydroPeriodMeanDepth(WriteToGrid) = noData;
    % Write Output Arrays to Output dfs2 file
    dfs2Out.WriteItemTimeStepNext(0, NET.convertArray(single(AverageStage(:))));
    dfs2Out.WriteItemTimeStepNext(0, NET.convertArray(single(AverageDepth(:))));
    dfs2Out.WriteItemTimeStepNext(0, NET.convertArray(single(HydroperiodFraction(:))));
    dfs2Out.WriteItemTimeStepNext(0, NET.convertArray(single(DisConHydroPeriod(:))));
    dfs2Out.WriteItemTimeStepNext(0, NET.convertArray(single(DisConHydroPeriodMeanDepth(:))));
    dfs2Out.WriteItemTimeStepNext(0, NET.convertArray(single(TotalConHydroPeriod(:))));
    dfs2Out.WriteItemTimeStepNext(0, NET.convertArray(single(TotalConHydroPeriodMeanDepth(:))));
    dfs2Out.Close();
    dfs2DepthFile.Close();
    dfs3HeadFile.Close();
catch ME
    fprintf('ERROR generating Total Period Stats.\n');
    fprintf('-- %s.\n', ME.message);
    dfs2Out.Close();
    dfs2DepthFile.Close();
    dfs3HeadFile.Close();
    delete(INI.fileTotalSimulationPeriodStats); % Delete Partially Written File If there is an error
end
clear AverageStage AverageDepth DisConHydroPeriod DisConHydroPeriodMeanDepth WriteToGrid;
clear MaxConHydroPeriod MaxConHydroPeriodMeanDepth CurrentConHydroPeriod CurrentConHydroPeriodMeanDepth;

end
