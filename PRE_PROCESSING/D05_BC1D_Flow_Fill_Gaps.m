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
%% Import Startements
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
INI.OBS_FLOW_DFE_DIR = '../../ENP_FILES/ENP_TOOLS_Sample_Input/Obs_Data_Processed/FLOW/DFS0/';
INI.OBS_FLOW_OUT_DIR = '../../ENP_TOOLS_Output_Sequential/D05_BC1D_Flow_Fill_Gaps_output/';
INI.OBS_DFE_FILETYPE = '*.dfs0';

% Model Simulation Period
INI.START_DATE = '01/01/1999 00:00';
INI.END_DATE   = '12/31/2010 00:00';

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% END USER INPUT
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

INI.START_DATE_NUM = datenum(datetime(INI.START_DATE,'Inputformat','MM/dd/yyyy HH:mm'));
INI.END_DATE_NUM = datenum(datetime(INI.END_DATE,'Inputformat','MM/dd/yyyy HH:mm'));

% If input directory doesn't exist end
if ~exist(INI.OBS_FLOW_DFE_DIR, 'dir')
    fprintf('No directory found');
    return
end
FILE_FILTER = [INI.OBS_FLOW_DFE_DIR INI.OBS_DFE_FILETYPE]; % list only files with extension *.dfs0
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
        dfs0File  = DfsFileFactory.DfsGenericOpen(myFILE);
        dfsDoubleOrFloat = dfs0File.ItemInfo.Item(0).DataType;
        utmXmeters = dfs0File.ItemInfo.Item(0).ReferenceCoordinateX;
        utmYmeters = dfs0File.ItemInfo.Item(0).ReferenceCoordinateY;
        elev_ngvd29_ft = dfs0File.ItemInfo.Item(0).ReferenceCoordinateZ;
        dd = double(Dfs0Util.ReadDfs0DataDouble(dfs0File));
        
        yy = double(dfs0File.FileInfo.TimeAxis.StartDateTime.Year);
        mo = double(dfs0File.FileInfo.TimeAxis.StartDateTime.Month);
        da = double(dfs0File.FileInfo.TimeAxis.StartDateTime.Day);
        hh = double(dfs0File.FileInfo.TimeAxis.StartDateTime.Hour);
        mi = double(dfs0File.FileInfo.TimeAxis.StartDateTime.Minute);
        se = double(dfs0File.FileInfo.TimeAxis.StartDateTime.Second);
        
        START_TIME = datenum(yy,mo,da,hh,mi,se);
        
        DFS0.T = datenum(dd(:,1))/86400 + START_TIME;
        %DFS0.TSTR = datestr(DFS0.T); not needed, slow
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
        
        % plot(DFS0.T,DFS0.V)
        % A = datestr(DFS0.T);
        % plot(A,DFS0.V);
        
        dfs0File.Close();
        
        measurements = zeros(size(DFS0.V, 1), 1);
        time_vector = zeros(size(DFS0.V, 1), 1);
        DFSi = 1;
        newi = 1;
        while DFSi <= size(DFS0.V, 1)
            if DFSi > 1
                if DFS0.T(DFSi) - time_vector(newi - 1, 1) > 1
                    measurements(newi, 1) = 0;
                    time_vector(newi, 1) = floor(time_vector(newi - 1)) + 1;
                    newi = newi + 1;
                else
                    
                    measurements(newi, 1) = DFS0.V(DFSi, 1);
                    time_vector(newi, 1) = DFS0.T(DFSi, 1);
                    newi = newi + 1;
                    DFSi = DFSi + 1;
                end
            else
                if DFS0.T(DFSi, 1) > INI.START_DATE_NUM && time_vector(1, 1) ~= INI.START_DATE_NUM
                    measurements(newi, 1) = 0;
                    time_vector(newi, 1) = INI.START_DATE_NUM;
                    newi = newi + 1;
                    if DFS0.V(DFSi, 1) ~= 0
                        measurements(newi, 1) = 0;
                        if mod(DFS0.T(DFSi, 1), 1) > 0
                            time_vector(newi, 1) = floor(DFS0.T(DFSi, 1));
                        else
                            time_vector(newi, 1) = floor(DFS0.T(DFSi, 1)) - 1;
                        end
                        newi = newi + 1;
                    end
                else
                    measurements(newi, 1) = DFS0.V(DFSi, 1);
                    time_vector(newi, 1) = DFS0.T(DFSi, 1);
                    newi = newi + 1;
                    DFSi = DFSi + 1;
                end
            end
        end
        if DFS0.T(end, 1) < INI.END_DATE_NUM
            if DFS0.V(end, 1) ~= 0
                measurements(newi, 1) = 0;
                if mod(DFS0.T(end, 1), 1) > 0
                    time_vector(newi, 1) = ceil(DFS0.T(end, 1));
                else
                    time_vector(newi, 1) = ceil(DFS0.T(end, 1)) + 1;
                end
                newi = newi + 1;
            end
            measurements(newi, 1) = 0;
            time_vector(newi, 1) = INI.END_DATE_NUM;
        end
        
        NameSplit = strsplit(NAME, '_');
        station_name = NameSplit{2};
        
        factory = DfsFactory();
        builder = DfsBuilder.Create(char(station_name),'Matlab DFS',0);
        
        T = datevec(time_vector(1));
        builder.SetDataType(0);
        builder.DeleteValueDouble = -1e-35;
        builder.SetGeographicalProjection(factory.CreateProjectionGeoOrigin('UTM-17',12,54,2.6));
        builder.SetTemporalAxis(factory.CreateTemporalNonEqCalendarAxis...
            (eumUnit.eumUsec,System.DateTime(T(1),T(2),T(3),T(4),T(5),T(6))));
        
        % Add an Item
        item1 = builder.CreateDynamicItemBuilder();
        
        % if statement that translates the Data Type Flag 'DType_Flag' into the
        % appropriate DHI required inputs for DFS0 creation. This will ned to be
        % expanded upon as new datatypes and DType_Flags are added.
        myStationName = char([station_name '_Q']);
        item1.Set(myStationName, DHI.Generic.MikeZero.eumQuantity...
            (eumItem.eumIDischarge,eumUnit.eumUft3PerSec), dfsDoubleOrFloat);
        
        item1.SetValueType(DataValueType.Instantaneous);
        item1.SetAxis(factory.CreateAxisEqD0());
        item1.SetReferenceCoordinates(utmXmeters,utmYmeters,elev_ngvd29_ft);
        builder.AddDynamicItem(item1.GetDynamicItemInfo());
        
        dfs0FileName = strcat(INI.OBS_FLOW_OUT_DIR, "BC_", myStationName, ".dfs0");
        if exist(dfs0FileName,'file')
            delete(dfs0FileName)
        end
        builder.CreateFile(dfs0FileName);
        
        dfs = builder.GetFile();
        % Add  data in the file
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
