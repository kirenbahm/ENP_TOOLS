function ComputeDepthOfPhreaticSurface(INI)
% This function reproduces the Depth of Phreatic Surface as computed
% optionally by MIKE SHE. If the phreatic surface is below the
% bottom of the top layer plus a threshhold = 0.01 m, MIKE SHE goes to the 
% next layer to extract the head. The threshold can be varied by the user 
% in the input parameter INI.SZ_HEADS_DRY_CELL_THRESHOLD, for example to 0.

% Import Statements
NET.addAssembly('DHI.Generic.MikeZero.DFS');
NET.addAssembly('DHI.Generic.MikeZero.DFS');
NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfs0.*;
import DHI.Generic.MikeZero.DFS.dfs123.*;

fprintf('\n------------------------------------');
fprintf('\nBeginning ComputeDepthOfPhreaticSurface    (%s)',datestr(now));
fprintf('\n------------------------------------\n');
format compact

% Open _PreProcessed.DFS2 file and read topography and metadata
[topoData, dfs2TopoFile] = readModelTopo(INI);
topoArray = double(topoData.Data); % topo

%Open SZ Heads file and save projection and item metadata
dfs3HeadFile = Dfs3File(DfsFileFactory.DfsGenericOpen(INI.fileSZ));
ProjWktString = dfs3HeadFile.FileInfo.Projection.WKTString;
ProjLong = dfs3HeadFile.FileInfo.Projection.Longitude;
ProjLat = dfs3HeadFile.FileInfo.Projection.Latitude;
ProjOri = dfs3HeadFile.FileInfo.Projection.Orientation;
HeadMetaData = dfs3HeadFile.ItemInfo.Item(0);
UseBots = false; % Flag to use Lower Level for the Layers
if exist(INI.fileBottomLevels,'file')
    % Open _PreProcessed_3DSZ.dfs3 file and save metadata
    dfs3BotFile  = Dfs3File(DfsFileFactory.DfsGenericOpen(INI.fileBottomLevels));
    search = '';
    itemBot = -1;
    okBot = false;
    % Find item for Lower Level
    field = System.String('Lower level');
    while ~startsWith(char(search), char(field))  && itemBot < dfs3BotFile.ItemInfo.Count - 1
        itemBot = (itemBot + 1);
        search = dfs3BotFile.ItemInfo.Item(itemBot).Name;
    end
    if startsWith(char(search), char(field))
        okBot = true;
    end
    dfs2TopoFile  = Dfs2File(DfsFileFactory.DfsGenericOpen(INI.filePP));
    search = '';
    itemDomain = -1;
    okDomain = false;
    % Find item for Model Domain
    field = System.String('Model domain');
    while ~startsWith(char(search), char(field))  && itemDomain < dfs2TopoFile.ItemInfo.Count - 1
        itemDomain = (itemDomain + 1);
        search = dfs2TopoFile.ItemInfo.Item(itemDomain).Name;
    end
    if startsWith(char(search), char(field))
        okDomain = true;
    end
    if okBot && okDomain % If Lower Level and Model Domain are both found
        UseBots = true; % Flag to use Lower Level for the Layers
        BottomData3D = dfs3BotFile.ReadItemTimeStep(itemBot + 1, 0); % Save Bottom Level Data
        DomainData2D = dfs2TopoFile.ReadItemTimeStep(itemDomain + 1, 0); % Save Bottom Level Data
        LevelBots = double(BottomData3D.Data); % Convert to 1D Array
        Domain = double(DomainData2D.Data); % Convert to 1D Array
    else
        fprintf(strcat('WARNING: Lower Level and/or Model Domain not found. %s.\n', ...
        'Proceeding With Depth Generation using Top Layer of Head values and Topography'),char(INI.fileBottomLevels));
    end
    
else
    fprintf(strcat('WARNING: INI.fileBottomLevels file was not found at %s.\n', ...
        'Proceeding With Depth Generation using Top Layer of Head values and Topography'),char(INI.fileBottomLevels));
end


% Create output file
% set file metadata
factory = DfsFactory();
builder = Dfs2Builder.Create(char("2D SZ results"),'MSHE',0);
builder.SetDataType(0);
builder.DeleteValueDouble = -1e-35;
builder.SetGeographicalProjection(factory.CreateProjectionGeoOrigin(ProjWktString,ProjLong,ProjLat,ProjOri));
builder.SetTemporalAxis(dfs3HeadFile.FileInfo.TimeAxis);
builder.SetSpatialAxis(dfs2TopoFile.SpatialAxis);
dfs2TopoFile.Close();

% add output Item
%save item metadata
ItemName = System.String('depth to phreatic surface (negative)');
builder.AddDynamicItem(ItemName, HeadMetaData.Quantity, HeadMetaData.DataType, HeadMetaData.ValueType);

% Finalize Output File
builder.CreateFile(INI.filePhreatic);
dfs2Out = Dfs2File(builder.GetFile());
clear ProjWktString ProjLong ProjLat ProjOri HeadMetaData;

% Write to Output
TimeAxis = dfs3HeadFile.FileInfo.TimeAxis; % Store Time axis from file 
NoTSperYear = round(365.25*24*60*60/TimeAxis.TimeStep); % # of time steps in 1 Year
nZ= dfs3HeadFile.SpatialAxis.ZCount; % number of layers
nG = dfs3HeadFile.SpatialAxis.XCount * dfs3HeadFile.SpatialAxis.YCount; % Grid Size
DepthPhreaticSurface = zeros(1, nG); % 1D  Array for writing Output Depth
noData = dfs2Out.FileInfo.DeleteValueFloat; % Output file noData value
clear topoData;
try
    for ts = 0:TimeAxis.NumberOfTimeSteps - 1
        % Every year's worth of time steps
        if mod(ts,NoTSperYear) ==0 % print running update to Command Window
            fprintf('\n      reading step %i%s%i and counting',ts+1, '/', TimeAxis.NumberOfTimeSteps);
        end
        HeadData3D = dfs3HeadFile.ReadItemTimeStep(1, ts); % 3d array with heads
        HeadArray = double(HeadData3D.Data); % convert to 1D array
        DepthPhreaticSurface(1,:) = noData; % Initialize output values
        n0 = (nZ - 1)*nG + 1; % Start index of Top layer in 1D array
        n1 = nZ*nG; % End index of Top layer in 1D array
        HeadArrayl = HeadArray(n0:n1); % head values at top layer
        WriteToGrid = HeadArrayl ~= noData; % find indexes where there is valid data
        DepthPhreaticSurface(WriteToGrid) = HeadArrayl(WriteToGrid) - topoArray(WriteToGrid); % write applicable depth values to output array
        if UseBots % If there is bottom level and Model Domain information
            nL = nZ;
            while nL > 1
                % Find Indexes where SZHead - Bottom is below threshold, SZHead
                % isn't noData, and within the domain. 
                % MSHE does not go down layers for cells on Model Domain boundary,
                % and consequently this calculation.
                WriteToGrid = (HeadArrayl - LevelBots(n0:n1)) < INI.SZ_HEADS_DRY_CELL_THRESHOLD ...
                    & HeadArrayl ~= noData & Domain == 1; 
                if any(any(WriteToGrid))
                    nL = nL - 1; % Decrease Layer number (next bottom layer)
                    n1 = n0 - 1; % End index of Current layer in 1D array
                    n0 = (nL - 1)*nG + 1; % Start index of Current layer in 1D array
                    HeadArrayl = HeadArray(n0:n1); % Head values of Next Layer
                    DepthPhreaticSurface(WriteToGrid) = HeadArrayl(WriteToGrid) - topoArray(WriteToGrid);% write applicable depth values to output array
                else
                    nL = -1; % If No need to go down layers, set condition to end while 
                end
            end
        end
        WriteToGrid = HeadArrayl == noData; % find indexes where there is noData
        DepthPhreaticSurface(WriteToGrid) = noData; % Set Values with noData
        dfs2Out.WriteItemTimeStepNext(0, NET.convertArray(single(DepthPhreaticSurface(:)))); % write timestep to file
    end
    % Close file handles
    dfs2Out.Close();
    dfs3HeadFile.Close();
    dfs2TopoFile.Close();
    fprintf('\n      Phreatic Depth Successfully Generated.\n');
catch ME
    fprintf('ERROR generating depth to phreatic surface (negative).\n');
    fprintf('-- %s.\n', ME.message);
    % Close file handles
    dfs2Out.Close();
    dfs3HeadFile.Close();
    dfs2TopoFile.Close();
    delete(INI.filePhreatic); % Delete Partially Written File If there is an error
end
end