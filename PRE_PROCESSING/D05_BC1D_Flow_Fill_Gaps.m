function D05_BC1D_Flow_Fill_Gaps()

% -------------------------------------------------------------------------
% Location of ENPMS library
% -------------------------------------------------------------------------
INI.MATLAB_SCRIPTS = '../ENPMS/';
try
    addpath(genpath(INI.MATLAB_SCRIPTS));
catch
    addpath(genpath(INI.MATLAB_SCRIPTS,0));
end
% -------------------------------------------------------------------------
% Import Startements
% -------------------------------------------------------------------------
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

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% BEGIN USER INPUT
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% Input Output Directories
INI.OBS_FLOW_IN_DIR = '../../ENP_TOOLS_Sample_Input/Obs_Data_Processed/FLOW/DFS0/';
INI.OBS_FLOW_OUT_DIR = '../../ENP_TOOLS_Output/Obs_Data_BC1D/';

INI.OBS_FILETYPE = '*.dfs0';

% Model Simulation Period
INI.START_DATE = '01/01/1999 00:00';
INI.END_DATE   = '12/31/2030 00:00';

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% END USER INPUT
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

INI.START_DATE_NUM = datenum(datetime(INI.START_DATE,'Inputformat','MM/dd/yyyy HH:mm'));
INI.END_DATE_NUM = datenum(datetime(INI.END_DATE,'Inputformat','MM/dd/yyyy HH:mm'));

% If input directory doesn't exist end
if ~exist(INI.OBS_FLOW_IN_DIR, 'dir')
    fprintf('No directory found');
    return
end
FILE_FILTER = [INI.OBS_FLOW_IN_DIR INI.OBS_FILETYPE]; % list only files with extension *.dfs0
LISTING  = dir(char(FILE_FILTER));

n = length(LISTING);
for i = 1:n
    try
        % iterate through each item in LISTING struc array (created by 'dir' matlab function)
        s = LISTING(i);
        NAME = s.name; % get filename
        fprintf('\n... processing %s - %d/%d: ', NAME, i, n);
        FOLDER = s.folder; % get folder name
        FILE_NAME = [FOLDER '\' NAME];
        myFILE = char(FILE_NAME);
        % Open dfs0 file and copy metadata for new file
        dfs0File  = DfsFileFactory.DfsGenericOpen(myFILE);
        FileTitle = dfs0File.FileInfo.FileTitle;
        station_name = dfs0File.ItemInfo.Item(0).Name;
        dfsDoubleOrFloat = dfs0File.ItemInfo.Item(0).DataType;
        ProjWktString = dfs0File.FileInfo.Projection.WKTString;
        ProjLong = dfs0File.FileInfo.Projection.Longitude;
        ProjLat = dfs0File.FileInfo.Projection.Latitude;
        ProjOri = dfs0File.FileInfo.Projection.Orientation;
        utmXmeters = dfs0File.ItemInfo.Item(0).ReferenceCoordinateX;
        utmYmeters = dfs0File.ItemInfo.Item(0).ReferenceCoordinateY;
        elev_ngvd29_ft = dfs0File.ItemInfo.Item(0).ReferenceCoordinateZ;
        % Read Time Series flow values
        dd = double(Dfs0Util.ReadDfs0DataDouble(dfs0File));
        % Read Start datetime
        yy = double(dfs0File.FileInfo.TimeAxis.StartDateTime.Year);
        mo = double(dfs0File.FileInfo.TimeAxis.StartDateTime.Month);
        da = double(dfs0File.FileInfo.TimeAxis.StartDateTime.Day);
        hh = double(dfs0File.FileInfo.TimeAxis.StartDateTime.Hour);
        mi = double(dfs0File.FileInfo.TimeAxis.StartDateTime.Minute);
        se = double(dfs0File.FileInfo.TimeAxis.StartDateTime.Second);
        % Create array of time step values 
        START_TIME = datenum(yy,mo,da,hh,mi,se);
        DFS0.T = datenum(dd(:,1))/86400 + START_TIME;
        DFS0.V = dd(:,2:end);
        
        for i = 0:dfs0File.ItemInfo.Count - 1
            DFS0.TYPE(i+1) = {char(dfs0File.ItemInfo.Item(i).Quantity.ItemDescription)};
            DFS0.UNIT(i+1) = {char(dfs0File.ItemInfo.Item(i).Quantity.UnitAbbreviation)};
            DFS0.NAME(i+1) = {char(dfs0File.ItemInfo.Item(i).Name)};
        end
        
        % remove all delete values - first remove the timevector elements
        DFS0.T(DFS0.V == dfs0File.FileInfo.DeleteValueFloat)= [];
        % second remove the data vector elements
        DFS0.V(DFS0.V == dfs0File.FileInfo.DeleteValueFloat)= [];
        
        dfs0File.Close();
        
        % initialize new time series arrays at minimum size
        measurements = zeros(size(DFS0.V, 1), 1);
        time_vector = zeros(size(DFS0.V, 1), 1);
        DFSi = 1;
        newi = 1;
        % Loop through dfs0 data. 
        while DFSi <= size(DFS0.V, 1)
            if DFSi > 1
                % if period between time steps is more than a day, create
                % new time step with flow of zero
                if DFS0.T(DFSi) - time_vector(newi - 1, 1) > 1
                    measurements(newi, 1) = 0;
                    time_vector(newi, 1) = floor(time_vector(newi - 1)) + 1;
                    newi = newi + 1;
                % otherwise use current value
                else
                    
                    measurements(newi, 1) = DFS0.V(DFSi, 1);
                    time_vector(newi, 1) = DFS0.T(DFSi, 1);
                    newi = newi + 1;
                    DFSi = DFSi + 1;
                end
            else
                % If first time step is after simulation start create a new
                % time step at simulation start with zero flow
                if DFS0.T(DFSi, 1) > INI.START_DATE_NUM && time_vector(1, 1) ~= INI.START_DATE_NUM
                    measurements(newi, 1) = 0;
                    time_vector(newi, 1) = INI.START_DATE_NUM;
                    newi = newi + 1;
                    % If first time step is also not zero, then add azero
                    % flow time step the day before first time step from
                    % dfs0
                    if DFS0.V(DFSi, 1) ~= 0
                        measurements(newi, 1) = 0;
                        if mod(DFS0.T(DFSi, 1), 1) > 0
                            time_vector(newi, 1) = floor(DFS0.T(DFSi, 1));
                        else
                            time_vector(newi, 1) = floor(DFS0.T(DFSi, 1)) - 1;
                        end
                        newi = newi + 1;
                    end
                % otherwise use current value
                else
                    measurements(newi, 1) = DFS0.V(DFSi, 1);
                    time_vector(newi, 1) = DFS0.T(DFSi, 1);
                    newi = newi + 1;
                    DFSi = DFSi + 1;
                end
            end
        end
        %If last time from dfs0 is before simulation end date step
        if DFS0.T(end, 1) < INI.END_DATE_NUM
            %if last vlaue is non zero, add a zero flow time step the day
            %after
            if DFS0.V(end, 1) ~= 0
                measurements(newi, 1) = 0;
                if mod(DFS0.T(end, 1), 1) > 0
                    time_vector(newi, 1) = ceil(DFS0.T(end, 1));
                else
                    time_vector(newi, 1) = ceil(DFS0.T(end, 1)) + 1;
                end
                newi = newi + 1;
            end
            % Then add a time step at end simulation date
            measurements(newi, 1) = 0;
            time_vector(newi, 1) = INI.END_DATE_NUM;
        end
        % create output dfs0
        factory = DfsFactory();
        builder = DfsBuilder.Create(char(FileTitle),'Matlab DFS',0);
        %save projection and file metadata 
        T = datevec(time_vector(1));
        builder.SetDataType(0);
        builder.DeleteValueDouble = -1e-35;
        builder.SetGeographicalProjection(factory.CreateProjectionGeoOrigin(ProjWktString,ProjLong,ProjLat,ProjOri));
        builder.SetTemporalAxis(factory.CreateTemporalNonEqCalendarAxis...
            (eumUnit.eumUsec,System.DateTime(T(1),T(2),T(3),T(4),T(5),T(6))));
        
        % Add an Item
        item1 = builder.CreateDynamicItemBuilder();
        
        %save item metadata
        myStationName = char([station_name]);
        item1.Set(myStationName, DHI.Generic.MikeZero.eumQuantity...
            (eumItem.eumIDischarge,eumUnit.eumUft3PerSec), dfsDoubleOrFloat);
        item1.SetValueType(DataValueType.Instantaneous);
        item1.SetAxis(factory.CreateAxisEqD0());
        item1.SetReferenceCoordinates(utmXmeters,utmYmeters,elev_ngvd29_ft);
        builder.AddDynamicItem(item1.GetDynamicItemInfo());
        
        dfs0FileName = strcat(INI.OBS_FLOW_OUT_DIR, NAME);
        if exist(dfs0FileName,'file')
            delete(dfs0FileName)
        end
        builder.CreateFile(dfs0FileName);
        
        dfs = builder.GetFile();
        % Add data in the file
        tic
        % Write to file using the MatlabDfsUtil
        MatlabDfsUtil.DfsUtil.WriteDfs0DataDouble(dfs, NET.convertArray((time_vector-time_vector(1))*86400), ...
            NET.convertArray(measurements, 'System.Double', size(measurements,1), size(measurements,2)))
        %toc
        
        dfs.Close();
    catch ME
        fprintf('... failed, DFSi = %d, newi =  %d', DFSi, newi);
        rethrow(ME)
    end
end

fclose('all');
fprintf('\n DONE \n\n');
end
