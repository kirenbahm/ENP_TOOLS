function D08_edit_dfs0_metadata()
%
% Update script so if the Excel file has an empty cell, it doesn't fail.??? 
%
% This function is used to rename DFE dfs0 files and change metadata to those used in the MIKE model.
%
% For example, it takes a file 'S333.flow.dfs0' with item 'S333' and changes it to file 'S333_Q' with item name 'S333_Q' and title 'S333_Q'
%
% It uses an Excel file to lookup the translation between DFE station name and datatype, and MIKE station name
%
% The program prints an error message and skips the file under the following conditions:
%   There is no match found in the Excel file
%   There are multiple matches in the Excel file
%   There is more than one item in the dfs0 file

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% BEGIN USER INPUT
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% Location of ENPMS library
INI.MATLAB_SCRIPTS = '../ENPMS/';

% -------------------------------------------------------------------------
% Location of metadata info
% -------------------------------------------------------------------------
EXCEL_METADATA_FILE = '../../ENP_FILES/ENP_TOOLS_Sample_Input/Data_Common/dfs0_rename.xlsx';

%DATA_SHEET_NAME = 'Flow_Dataset_Selection';
DATA_SHEET_NAME = 'Stage_Dataset_Selection';

MIKE_STATION_NAME_COLUMN = 'MIKE_name';
DFE_STATION_NAME_COLUMN  = 'DFE_station';
DFE_DATATYPE_NAME_COLUMN = 'DFE_datatype';

% -------------------------------------------------------------------------
% Input/output directories
% -------------------------------------------------------------------------
DIR_DFS0_IN  = '../../ENP_FILES/ENP_TOOLS_Sample_Input/Obs_Processed_MATLAB/in/Stage/';
DIR_DFS0_OUT = '../../ENP_TOOLS_Output/D08_edit_dfs0_metadata/Stage-renamed/';

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% END USER INPUT
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
INI.OBS_FILETYPE = '*.dfs0';

% Import Statements
try
    addpath(genpath(INI.MATLAB_SCRIPTS));
catch
    addpath(genpath(INI.MATLAB_SCRIPTS,0));
end

% -------------------------------------------------------------------------
% MikeZero Import Statements
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

% Create output directories if they don't already exist
if ~exist(DIR_DFS0_OUT,  'dir'); mkdir(DIR_DFS0_OUT);  end

%Initialize .NET libraries
INI = initializeLIB(INI);

%Read In Excel for translation between DFE station name and datatype, and MIKE station name
[~,~,RAW] = xlsread(char(EXCEL_METADATA_FILE),char(DATA_SHEET_NAME));
[numRows,numCols]=size(RAW);

% Find Column numbers for needed fields
MIKE_STATION_NAME_COLUMN_NUM = -1;
DFE_STATION_NAME_COLUMN_NUM = -1;
DFE_DATATYPE_NAME_COLUMN_NUM = -1;
for c = 1:numCols
    if strcmp(char(RAW(1,c)),MIKE_STATION_NAME_COLUMN) 
        MIKE_STATION_NAME_COLUMN_NUM = c;
    elseif strcmp(char(RAW(1,c)),DFE_STATION_NAME_COLUMN) 
        DFE_STATION_NAME_COLUMN_NUM = c;
    elseif strcmp(char(RAW(1,c)),DFE_DATATYPE_NAME_COLUMN) 
        DFE_DATATYPE_NAME_COLUMN_NUM = c; 
    end
end

% If any columns aren't found, abort run
if MIKE_STATION_NAME_COLUMN_NUM == -1 || DFE_STATION_NAME_COLUMN_NUM == -1 || DFE_DATATYPE_NAME_COLUMN_NUM == -1
    fprintf('ERROR: Needed Fields not found in Excel Sheet: %s in workbook %s.\n',char(EXCEL_METADATA_FILE), char(DATA_SHEET_NAME));
    if MIKE_STATION_NAME_COLUMN_NUM == -1; fprintf('--Column %s not found.\n',char(MIKE_STATION_NAME_COLUMN)); end
    if DFE_STATION_NAME_COLUMN_NUM == -1; fprintf('--Column %s not found.\n',char(DFE_STATION_NAME_COLUMN)); end
    if DFE_DATATYPE_NAME_COLUMN_NUM == -1; fprintf('--Column %s not found.\n',char(DFE_DATATYPE_NAME_COLUMN)); end
    return;
end

%Find Listing of input Dfs0 files
FILE_FILTER = [DIR_DFS0_IN INI.OBS_FILETYPE]; % list only files with extension *.dfs0
LISTING  = dir(char(FILE_FILTER)); % list only files input directory with extension *.dfs0

%Loop through files
n = length(LISTING);
for i = 1:n
    try
        % iterate through each item in LISTING struc array (created by 'dir' matlab function)
        s = LISTING(i);
        myFILE = [s.folder '/' s.name]; %%find full file name and path
        NAME = s.name; % get filename
        fprintf('\n... %d/%d:  reading %s ...', i, n, NAME); % report running status
        [~,myname,myext] = fileparts(myFILE);
        dfs0In = DfsFileFactory.DfsGenericOpen(myFILE); % Open dfs0
        
        % check if dfs0 has multiple items
        if dfs0In.ItemInfo.Count > 1
        fprintf('\n---Error: Skipping due to Multiple Dfs0 Items');
           continue; % If multiple items found, skip file and move to next iteration
        end
        
        Station_Datatype = strsplit(myname,'.'); % split to obtain DFE Station Name and Datatype
        
        % Set Loop variables
        rI = -1; % Row index in Excel of dfs0 data 
        Found = 0; % How many Rows of data match the dfs0 file
        %Loop through xls to find file info
        for r = 2:numRows % each row has data for a different station
            try
                % If the row's DFE Station Name and Datatype match the dfs0 file
                if strcmp(Station_Datatype{1}, char(RAW(r, DFE_STATION_NAME_COLUMN_NUM)))...
                    && strcmp(Station_Datatype{2}, char(RAW(r, DFE_DATATYPE_NAME_COLUMN_NUM)))
                rI = r; % save row index
                Found = Found + 1; % increment # of found matches
                end
            catch % Error reading Excel sheet
                fprintf('--- exception line in %d::%s\n', i, char(STATION_NAME));
            end
        end
        if Found == 0 % If no matches Skip File
        fprintf('\n---Error: Skipping due to No match in Excel Lookup Table');
           continue;
        elseif Found > 1 % If multiple matches Skip File
        fprintf('\n---Error: Skipping due to Multiple matches in Excel Lookup Table');
           continue;
        end
        
        % Recreate File with updated metadata
        dfs0File  = DfsFileFactory.DfsGenericOpen(myFILE);
        AppTitle         = dfs0File.FileInfo.ApplicationTitle;
        AppVersionNo     = dfs0File.FileInfo.ApplicationVersion;
        NoData           = dfs0File.FileInfo.DeleteValueDouble;
        ProjWktString    = dfs0File.FileInfo.Projection.WKTString;
        ProjLong         = dfs0File.FileInfo.Projection.Longitude;
        ProjLat          = dfs0File.FileInfo.Projection.Latitude;
        ProjOri          = dfs0File.FileInfo.Projection.Orientation;
        TimeAxis         = dfs0File.FileInfo.TimeAxis;  
        dfsDoubleOrFloat = dfs0File.ItemInfo.Item(0).DataType;
        itemQuantity     = dfs0File.ItemInfo.Item(0).Quantity;
        utmXmeters       = dfs0File.ItemInfo.Item(0).ReferenceCoordinateX;
        utmYmeters       = dfs0File.ItemInfo.Item(0).ReferenceCoordinateY;
        elev_ngvd29_ft   = dfs0File.ItemInfo.Item(0).ReferenceCoordinateZ;
        
        % Read Time Series flow values
        dd = double(Dfs0Util.ReadDfs0DataDouble(dfs0File));
        
        % Read Start datetime
        yy = double(TimeAxis.StartDateTime.Year);
        mo = double(TimeAxis.StartDateTime.Month);
        da = double(TimeAxis.StartDateTime.Day);
        hh = double(TimeAxis.StartDateTime.Hour);
        mi = double(TimeAxis.StartDateTime.Minute);
        se = double(TimeAxis.StartDateTime.Second);
        
        % Create array of time step values 
        START_TIME = datenum(yy,mo,da,hh,mi,se);
        DFS0.T = datenum(dd(:,1));
        DFS0.V = dd(:,2:end);
        
        %Create New FileName
        station_name = char(RAW(rI, MIKE_STATION_NAME_COLUMN_NUM));
        dfs0FileName = [DIR_DFS0_OUT station_name myext];
        factory = DfsFactory();
        builder = DfsBuilder.Create(station_name, char(AppTitle), AppVersionNo);
        
        %save projection and file metadata 
        T = datevec(DFS0.T(1)/86400 + START_TIME);
        builder.SetDataType(0);
        builder.DeleteValueDouble = NoData;
        builder.SetGeographicalProjection(factory.CreateProjectionGeoOrigin(ProjWktString,ProjLong,ProjLat,ProjOri));
        builder.SetTemporalAxis(factory.CreateTemporalNonEqCalendarAxis...
            (eumUnit.eumUsec,System.DateTime(T(1),T(2),T(3),T(4),T(5),T(6))));
        
        % Add an Item
        item1 = builder.CreateDynamicItemBuilder();
        
        %save item metadata
        item1.Set(station_name, itemQuantity, dfsDoubleOrFloat);
        item1.SetValueType(DataValueType.Instantaneous);
        item1.SetAxis(factory.CreateAxisEqD0());
        item1.SetReferenceCoordinates(utmXmeters,utmYmeters,elev_ngvd29_ft);
        builder.AddDynamicItem(item1.GetDynamicItemInfo());
        
        if exist(dfs0FileName,'file')
            delete(dfs0FileName)
        end
        builder.CreateFile(dfs0FileName);
        
        dfs = builder.GetFile();
        % Add data in the file

        % Write to file using the MatlabDfsUtil
        MatlabDfsUtil.DfsUtil.WriteDfs0DataDouble(dfs, NET.convertArray(DFS0.T), ...
            NET.convertArray(DFS0.V, 'System.Double', size(DFS0.V,1), size(DFS0.V,2)))

        
        dfs.Close();
        fprintf(' done');
        
    catch ME
        fprintf('\n---Error: File Read Failed');
        rethrow(ME)
    end
end

fclose('all');
fprintf('\n DONE \n\n');
end

