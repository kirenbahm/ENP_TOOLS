function ComputeCalendarYearStatistics(INI)
% Reads the _2DSZ.dfs2 and _3DSZ.dfs3 to read depth and stage statistics, respectively. 
% Iterates through data to find Statistics for each complete Calendar Year for all avaiable data.
% Writes the Statistics to a Non Equidistant Time Step dfs2 file where the time steps are the 
% start of each complete Calendar Year 
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
fprintf('\nBeginning ComputeCalendarYearStatistics    (%s)',datestr(now));
fprintf('\n------------------------------------');
format compact

% Open _PreProcessed.DFS2 file and read topography and metadata
[topoData,~] = readModelTopo(INI);
topoArray = double(topoData.Data); % topo

% Open _2DSZ.dfs2 file and save metadata
dfs2DepthFile  = DfsFileFactory.DfsGenericOpen(INI.filePhreatic);%Dfs2File();
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
% Find what would be the previous time step
StartPrior = StartDateTime - TimeAxis.TimeStep/86400;

% If first file Time step is not first possible time step in a year, then the first complete Calendar year starts the next year
YearComplete = StartDateTime.Year ~= StartPrior.Year;
if ~YearComplete
    StartDateTime = datetime(StartDateTime.Year + 1, 1,1,0,0,0);
else % Else its the first poissible time step that year, and current year is first Calendar year
    StartDateTime = datetime(StartDateTime.Year, 1,1,0,0,0);
end

% Create output file
% set file metadata
factory = DfsFactory();
builder = Dfs2Builder.Create(char("Calendar Year Statistics"),'Matlab DFS',0);
builder.SetDataType(0);
builder.DeleteValueDouble = -1e-35;
builder.SetGeographicalProjection(factory.CreateProjectionGeoOrigin(ProjWktString,ProjLong,ProjLat,ProjOri));
builder.SetTemporalAxis(factory.CreateTemporalNonEqCalendarAxis...
    (eumUnit.eumUsec,System.DateTime(StartDateTime.Year,StartDateTime.Month,StartDateTime.Day,0,0,0)));
builder.SetSpatialAxis(dfs2DepthFile.ItemInfo.Item(itemDepth).SpatialAxis);

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
builder.AddDynamicItem(System.String('hydroperiod1 (total no. days per year, discontinuous)'), ...
    DHI.Generic.MikeZero.eumQuantity(eumItem.eumIItemUndefined,eumUnit.eumUUnitUndefined), ...
    DepthMetaData.DataType, DepthMetaData.ValueType);

% add output Item
builder.AddDynamicItem(System.String('mean water depth during hydroperiod1 (total no. days per year, discontinuous)'), ...
    DepthMetaData.Quantity, ...
    DepthMetaData.DataType, DepthMetaData.ValueType);

% add output Item
builder.AddDynamicItem(System.String('hydroperiod2 (max continuous no. days per year)'), ...
    DHI.Generic.MikeZero.eumQuantity(eumItem.eumIItemUndefined,eumUnit.eumUUnitUndefined), ...
    DepthMetaData.DataType, DepthMetaData.ValueType);

% add output Item
builder.AddDynamicItem(System.String('mean water depth during hydroperiod2 (max continuous no. days per year)'), ...
    DepthMetaData.Quantity, ...
    DepthMetaData.DataType, DepthMetaData.ValueType);

builder.CreateFile(INI.fileCalendarYearStats);
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
NoTSperYear = round(365.25*24*60*60/TimeAxis.TimeStep); % # of time steps per year
NoTSperDay = round(86400/TimeAxis.TimeStep); % # of time steps per Day
noData = dfs2DepthFile.FileInfo.DeleteValueFloat; % No data value for file
DT0 = datetime(TimeStart.Year, TimeStart.Month, TimeStart.Day, TimeStart.Hour,...
    TimeStart.Minute, TimeStart.Second);% First File Time Step DateTime
CurrentYear = DT0.Year;% Current Complete Calendar Year

% Keeps track of current date time, Offset by -Timestep so first timestep in
% loop matches elapsed time = 0
currentDateTime = DT0 - TimeAxis.TimeStep/86400; % Keeps track of current date time
WriteTime = 0; % Elapsed Time for Output TimeStep
nts = 0; % counter for # of time steps
try
    % Loop through all time steps, plus one
    % Runs 1 extra iteration that is caught in order to add final Month
    % values into output file before exiting loop.
    % i.e Final time step in file is Dec 31 2010. Run one more iteration,
    % currentDateTime moves to Jan 1 and triggers Dec 2010 write
    for ts = 0:TimeAxis.NumberOfTimeSteps
        if mod(ts,NoTSperYear) == 0 % print running update to Command Window
            fprintf('\n      reading step %i%s%i and counting',ts+1, '/', TimeAxis.NumberOfTimeSteps - 1);
        end
        currentDateTime = currentDateTime + TimeAxis.TimeStep/86400; % Increment current DateTime based on TimeStep
        if currentDateTime.Year ~= CurrentYear % If new Calendar Year
            if YearComplete % Write if a complete Calendar Year
                AverageStage = AverageStage / nts;  % Summed Stages divided by number of days
                AverageDepth = AverageDepth / nts; % Summed Depths divided by number of days
                HydroperiodFraction = DisConHydroPeriod / NoTSperYear; % Hydroperiod Fraction = Discontinuous Hydroperiod / # of days
                % Hydroperiod Statistic Calculations
                % Summed Discontinous Hydroperiod Depths divided by # of timesteps
                DisConHydroPeriodMeanDepth = DisConHydroPeriodMeanDepth ./ DisConHydroPeriod;
                % Summed Max Continous Hydroperiod Depths divided by # of timesteps
                MaxConHydroPeriodMeanDepth = MaxConHydroPeriodMeanDepth ./ MaxConHydroPeriod;
                % Convert Hydroperiod from Total Timesteps to Total Days
                DisConHydroPeriod = DisConHydroPeriod / NoTSperDay;
                MaxConHydroPeriod = MaxConHydroPeriod / NoTSperDay;
                
                % Find indexes where Disconinuous Hydroperiod = 0
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
            % reset arrays for calculating Calendar Year statistics
            AverageStage = zeros(1, nG);
            AverageDepth = zeros(1, nG);
            DisConHydroPeriod = zeros(1, nG);
            DisConHydroPeriodMeanDepth = zeros(1, nG);
            MaxConHydroPeriod = zeros(1, nG);
            MaxConHydroPeriodMeanDepth = zeros(1, nG);
            CurrentConHydroPeriod = zeros(1, nG);
            CurrentConHydroPeriodMeanDepth = zeros(1, nG);
            nts = 0; % reset Timestep counter
            EndPrior = currentDateTime - TimeAxis.TimeStep/86400; % Find previous time step
            CurrentYear = currentDateTime.Year; % Set calculation cut off to new Calendar Year
            WriteTime = seconds(currentDateTime - StartDateTime); % Find elapsed time from start to
            YearComplete = EndPrior.Year ~= currentDateTime.Year; % Complete year if current and previous timestep are in different years
        end
        % if final loop iteration, break loop after write, if necessary. No data left to read
        if ts == TimeAxis.NumberOfTimeSteps % If 
            break;
        end
        DepthData2D = dfs2DepthFile.ReadItemTimeStep(itemDepth + 1, ts); % 2D array with Depths
        DepthArray = double(DepthData2D.Data); % convert to 1D array
        AverageStage = AverageStage + DepthArray + topoArray; % Add depth and topography values to average stage
        DepthArray(DepthArray < 0 & DepthArray ~= noData) = 0; % Depth values below ground are 0
        AverageDepth = AverageDepth + DepthArray;% Add Depth values to average depth
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
    fprintf('\n      Calendar Year Statistics Successfully Generated.\n');
catch ME
    fprintf('ERROR generating Calendar Year Stats.\n');
    fprintf('-- %s.\n', ME.message);
    dfs2Out.Close();
    dfs2DepthFile.Close();
    delete(INI.fileCalendarYearStats);% Delete Partially Written File If there is an error
end
clear AverageStage AverageDepth DisConHydroPeriod DisConHydroPeriodMeanDepth WriteToGrid;
clear MaxConHydroPeriod MaxConHydroPeriodMeanDepth CurrentConHydroPeriod CurrentConHydroPeriodMeanDepth;

end
