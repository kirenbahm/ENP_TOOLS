function ComputeMonthlyStatistics(INI)
% Read the Depth to Phreatic Surface from the _2DSZ.dfs2 file and the
% topography from _PreProcessed.dfs2 file and computes Monthly Averages for
% Water Levels and Water Depths

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
fprintf('\nBeginning ComputeMonthlyStatistics    (%s)',datestr(now));
fprintf('\n------------------------------------');
format compact

% Open _PreProcessed.DFS2 file and read topography and metadata
[topoData,~] = readModelTopo(INI);
topoArray = double(topoData.Data); % topo

%Open _2DSZ.DFS2 file file and save metadata
dfs2DepthFile = Dfs2File(DfsFileFactory.DfsGenericOpen(INI.filePhreatic));
ProjWktString = dfs2DepthFile.FileInfo.Projection.WKTString;
ProjLong = dfs2DepthFile.FileInfo.Projection.Longitude;
ProjLat = dfs2DepthFile.FileInfo.Projection.Latitude;
ProjOri = dfs2DepthFile.FileInfo.Projection.Orientation;
search = '';
itemDepth = -1;
% Find depth to phreatic surface item
field = System.String('depth to phreatic surface (negative)');
while ~strcmp(char(search), char(field))  && itemDepth < dfs2DepthFile.ItemInfo.Count
    itemDepth = (itemDepth + 1);
    search = dfs2DepthFile.ItemInfo.Item(itemDepth).Name;
end
DepthMetaData = dfs2DepthFile.ItemInfo.Item(itemDepth);
TimeAxis = dfs2DepthFile.FileInfo.TimeAxis;
TimeStart = dfs2DepthFile.FileInfo.TimeAxis.StartDateTime;

% Parse file start DateTime
StartDateTime = datetime(TimeStart.Year, TimeStart.Month, TimeStart.Day, TimeStart.Hour, TimeStart.Minute, TimeStart.Second);

% Find Start of First Complete Month
% If first file Time step is the first possible timestep in a month, then month
% is complete. Else First complete month is the Month after First Time Step 
% Find what previous timestep would be
StartPrior = StartDateTime - TimeAxis.TimeStep/86400;
MonthComplete = StartDateTime.Month ~= StartPrior.Month; % If First Time step and previous time step would be in the same month
if ~MonthComplete % If Same Month, then First month is incomplete
    if StartDateTime.Month == 12 %If december, First complete month is Jan 1 next year
        StartDateTime = datetime(StartDateTime.Year + 1,1,1,0,0,0);
    else % else, First complete month is next month of current year   
        StartDateTime = datetime(StartDateTime.Year,StartDateTime.Month + 1,1,0,0,0);
    end
else % If month complete, then First Complete month is current Month
    StartDateTime = datetime(StartDateTime.Year, StartDateTime.Month, 1,0,0,0);
end

% Create output file
% set file metadata
factory = DfsFactory();
builder = Dfs2Builder.Create(char("Monthly Statistics"),'Matlab DFS',0);
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

% Finalize Output File
builder.CreateFile(INI.fileMonthlyStats);
dfs2Out = Dfs2File(builder.GetFile());
clear ProjWktString ProjLong ProjLat ProjOri HeadMetaData;

% Initialize Variable for calculations and Outputs
nG = dfs2Out.SpatialAxis.XCount * dfs2Out.SpatialAxis.YCount; % Spatial Axis Grid Size
AverageStage = zeros(1, nG); % 1D  Array for writing Output Stage
AverageDepth = zeros(1, nG); % 1D  Array for writing Output Depth
NoTSperYear = round(365.25*24*60*60/TimeAxis.TimeStep);
noData = dfs2DepthFile.FileInfo.DeleteValueFloat; % No data value for file
DT0 = datetime(TimeStart.Year, TimeStart.Month, TimeStart.Day, TimeStart.Hour,...
    TimeStart.Minute, TimeStart.Second);% First File Time Step DateTime
CurrentMonth = DT0.Month; % Current Calendar Month
WriteTime = 0;% Elapsed Time for Output TimeSteps

% Keeps track of current date time, Offset by -Timestep so first timestep in
% loop matches elapsed time = 0
currentDateTime = DT0 - TimeAxis.TimeStep/86400; % Keeps track of current date time
nts = 0; % # of time steps for averaging
try
    % Loop through all time steps, plus one
    % Runs 1 extra iteration that is caught in order to add final Month
    % values into output file before exiting loop.
    % i.e Final time step in file is Dec 31 2010. Run one more iteration,
    % currentDateTime moves to Jan 1 and triggers Dec 2010 write
    for kt = 0:TimeAxis.NumberOfTimeSteps
        if mod(kt,NoTSperYear) == 0 % print running update to Command Window
            fprintf('\n      reading step %i%s%i and counting',kt + 1, '/', TimeAxis.NumberOfTimeSteps);
        end
        currentDateTime = currentDateTime + TimeAxis.TimeStep/86400; % Increment current DateTime based on TimeStep
        if currentDateTime.Month ~= CurrentMonth %If new month
            % Find if Month was complete at the end
            % If so, average summed values based on number of time steps
            % read, then output to file.
            if MonthComplete
                AverageStage = AverageStage / nts; % Summed Stages divided by number of timesteps
                AverageDepth = AverageDepth / nts; % Summed Depths divided by number of timesteps
                
                % Find indexes outside domain where noData values are
                WriteToGrid = DepthArray == noData;
                % Set values at indexes to noData Values
                AverageStage(WriteToGrid) = noData;
                AverageDepth(WriteToGrid) = noData;
                
                % Write Output Array to Output dfs2 file
                dfs2Out.WriteItemTimeStepNext(WriteTime, NET.convertArray(single(AverageStage(:))));
                dfs2Out.WriteItemTimeStepNext(WriteTime, NET.convertArray(single(AverageDepth(:))));
            end
            AverageStage = zeros(1, nG); % reset array for calculating Monthly statistics
            AverageDepth = zeros(1, nG); % reset array for calculating Monthly statistics
            nts = 0; % reset counter for number of timesteps
            EndPrior = currentDateTime - TimeAxis.TimeStep/86400; % Find previous time step
            CurrentMonth = currentDateTime.Month; % Set calculation cut off to new Month
            
            % Check that current time step and previous time step are in different months
            MonthComplete = EndPrior.Month ~= currentDateTime.Month; 
            WriteTime = seconds(currentDateTime - StartDateTime);% Find elapsed time from start to current
        end
        % if final loop iteration, break loop after write, if necessary. No data left to read
        if kt == TimeAxis.NumberOfTimeSteps
            break;
        end
        DeptheData2D = dfs2DepthFile.ReadItemTimeStep(itemDepth + 1, kt); % 3d array with depths
        DepthArray = double(DeptheData2D.Data); % convert to 1D array
        AverageStage = AverageStage + DepthArray + topoArray; % Add Depth and Topography values to average stage
        DepthArray(DepthArray < 0 & DepthArray ~= noData) = 0; % Depth values below ground are 0
        AverageDepth = AverageDepth + DepthArray; % Add Depth values to average depth
        nts = nts + 1; % increment number of timesteps
    end
    dfs2Out.Close();
    dfs2DepthFile.Close();
    fprintf('\n      Monthly Statistics Successfully Generated.\n');
catch ME
    fprintf('ERROR generating Calendar Year Stats.\n');
    fprintf('-- %s.\n', ME.message);
    dfs2Out.Close();
    dfs2DepthFile.Close();
    delete(INI.fileMonthlyStats);% Delete Partially Written File If there is an error
end
clear AverageStage AverageDepth DisConHydroPeriod DisConHydroPeriodMeanDepth WriteToGrid;
clear MaxConHydroPeriod MaxConHydroPeriodMeanDepth CurrentConHydroPeriod CurrentConHydroPeriodMeanDepth;

end
