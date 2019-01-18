function MAP_COMPUTED_GROUPS = get_GRIDDED_DATA(FILE_DFS, INI)


%  UNDER CONSTRUCTION


%---------------------------------------------
% FUNCTION DESCRIPTION:
%
% This function reads MIKESHE and MIKE11 raw output files and saves
%   selected items into a .MATLAB file.
% The data is saved as 1-dimensional daily timeseries, and currently only
%   saves the last timestep of each day.

% variable names are given 0 or 1 suffix to indicate whether it is a 0-based
% value or a 1-based value. since we are switching between these so much...
%
% The data saved into the .MATLAB file is in the form of a container,
%   called MAP_ALL_DATA, that uses the station names as keys.
%The structures are stored in a map with station name as
%MAP KEY and computed data as MAP VALUE. The structure is accessed
%by providing the key as a character string e.g. D = MAP_ALL_DATA('NP205')

% COMMENTS:
%
%----------------------------------------
% REVISION HISTORY:
%
% keb 2016-07-19  removed or rearranged comments.
%
% v6:   keb 2015-12-08
%  -changed DFS read code to allow for a variable number of items in file
%   (but it still assumes you know the item numbers for the data you want)
%
% v4:
%  -added functionality for dfs2 files  keb 2015-11-10
%  -incremented to InputDFS2v2
%  -removed confusing references that opened the file a second time and
%   referred to the same variables by different names
% v3:
%  -added syntax for reading many Excel worksheets (within the same Excel
%   file) instaead of just one worksheet.
%  -changed number of columns of Excel data to save in array (minus 3
%  'scratch' columns that weren't used)
%----------------------------------------

format compact

NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;

FT2M = 0.3048;
CFS2M3 = (0.3048^3);
CellAreaFt = (400/FT2M)^2;

FILE_DIR =  INI.CELL_DEF_FILE_DIR_3DSZQ;
FILE_NAME_GROUP_DEFS = INI.CELL_DEF_FILE_NAME_3DSZQ;
FILE_SHEETNAME = INI.CELL_DEF_FILE_SHEETNAME_3DSZQ;

% for z-direction flow in mm/day, converted to cubic feet per second integrated over cell face:
MMperDYToFT3perSperCell = (0.001/FT2M)*CellAreaFt/86400;

numcols = 6; % number of columns in Excel file with data (columns 7+ are currently ignored)

% Alldata is currently hardcoded below and dependent on numcols variable above
% AllData data fields are:
% 1: Station name (Ie transect or indicator region name)
% 2: Row (Y) (base 1)
% 3: Col (X) (base 1)
% 4: Layer (3 is top, 1 is bottom)
% 5: Multiplier (usually 1 or -1)
% 6: Item number
% 7: Direction (not used)
% 8: Row (base 0, not used)
% 9: Col (base 0, not used)
% 10: Year
% 11: Month
% 12: Day
% 13: Hour (usually 0)
% 14: Minute (usually 0)
% 15: Second (usually 0)
% 16: Value

myStation = 1;
myYear = 7;
myMonth = 8;
myDay = 9;
myData = 13;

DFS2 = false;
DFS3 = false;
[DIR,FNAME,MyFileExtension] = fileparts(FILE_DFS);
if strcmp(MyFileExtension,'.dfs2')
    DFS2 = true;
end
if strcmp(MyFileExtension,'.dfs3')
    DFS3 = true;
end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Load group definition data from Excel or Matlab file
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

XLARRAY = load_XL_GRID(FILE_DFS, INI);

% Assign each vector to corresponding array column
MyRequestedStnNames=XLARRAY(:,1);
rows0=XLARRAY(:,2);
cols0=XLARRAY(:,3);
lyrs1=XLARRAY(:,4);
multip=XLARRAY(:,5);
itms1=XLARRAY(:,6);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% step 1: get timeseries data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [DIR,FNAME,MyFileExtension] = fileparts(FILE_DFS);

TS.S = get_TS_GRID(FILE_DFS);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% set up dates, times, etc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get vector of system.datetime-type timesteps in dfs file
dfstimes = DfsExtensions.GetDateTimes(TS.S.myDfs.FileInfo.TimeAxis);

% get number of timesteps in file
NumDfsSteps = TS.S.nsteps;

% transfer system.datetime-type timestamp array to datetime-type vectors
for t=1:NumDfsSteps
    MyDateTime=dfstimes(t);
    thistimestep=datenum(double([MyDateTime.Year MyDateTime.Month MyDateTime.Day MyDateTime.Hour MyDateTime.Minute MyDateTime.Second]));
    DfsTimeVector(t,:) = datevec(thistimestep);
end

dfs_day_begin = floor(datenum(DfsTimeVector(1,:)));
dfs_day_end   = floor(datenum(DfsTimeVector(NumDfsSteps,:)));
num_dfs_days  = dfs_day_end - dfs_day_begin + 1;
DfsDatesVector = datevec(linspace(dfs_day_begin,dfs_day_end,num_dfs_days));

TS.startdate = dfs_day_begin;   %start extract on this date
TS.enddate = dfs_day_end;

TS = nummthyr(TS);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read through file and pull out the specific items/locations we need
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get number of items in file to read
NumItemsInFile = TS.S.myDfs.ItemInfo.Count;

[DIR,FNAME,MyFileExtension] = fileparts(FILE_DFS);

if DFS2
    % read current timestep for each item in file into array Fx
    % Then pick out item/cell values you need and save to fk array.
    % Assumes 2d array.
    for tstep=0:NumDfsSteps-1
        ds = datestr(DfsTimeVector(tstep+1,:));
        if mod(tstep-1,10) == 0
            fprintf('.');
        end
        if mod(tstep-1,366) == 0
            fprintf('\n... now on step %i%s%i:: %s ::and counting',tstep+1, '/', NumDfsSteps-1, ds);
        end
        %fprintf('... Step %i%s%i:: %s :: reading: %s%s\n',...
        %     tstep+1, '/', NumDfsSteps-1, ds, char(FNAME), char(MyFileExtension))
        for i = 1:NumItemsInFile
            Fx{i} = double(TS.S.myDfs.ReadItemTimeStep(i,tstep).To2DArray());
        end
        for k=1:length(MyRequestedStnNames) % iterate through lines in Excel file
            itemRequested = itms1{k};
            fk = Fx{itemRequested};
            TS.ValueMatrix(tstep+1,k)=fk(cols0{k}+1,rows0{k}+1) * multip{k};
        end
    end
end

if DFS3
    % read current timestep for each item in file into array (Fx1, Fx2, Fx3)
    % Then pick out item/cell values you need and save to fk array.
    % Assumes 3d array.
    try
        for tstep=0:NumDfsSteps-1
            ds = datestr(DfsTimeVector(tstep+1,:));
            if mod(tstep-1,10) == 0
                fprintf('.');
            end
            if mod(tstep-1,366) == 0
                fprintf('\n... now on step %i%s%i:: %s ::and counting',tstep+1, '/', NumDfsSteps-1, ds);
            end
            %fprintf('... Step %i%s%i:: %s :: reading: %s%s\n',...
            %     tstep+1, '/', NumDfsSteps-1, ds, char(FNAME), char(MyFileExtension))
            try
                for i = 1:NumItemsInFile
                    Fx{i} = double(TS.S.myDfs.ReadItemTimeStep(i,tstep).To3DArray());
                end
            catch
                fprintf('\nException: number of requested items greater than available in dfs3 :  %i%s%i \n', i, ' out of ', NumItemsInFile);
            end
            for k=1:length(MyRequestedStnNames) % iterate through lines in Excel file
                % the XL sheet requires 6 data items in the .dfs3 file,
                % otherwise code breaks. This requires specific set up in
                % the MIKE grid series output file:
                % groundwater flow in x-direction
                % groundwater flow in y-direction
                % groundwater flux in z-direction for MIKE 2019: the other flux items i.e. x and y directions should be unchecked
                % groundwater flow in z-direction for MIKE 2016 and 2017
                itemRequested = itms1{k};
                fk = Fx{itemRequested};
                TS.ValueMatrix(tstep+1,k) = fk(cols0{k}+1,rows0{k}+1,lyrs1{k}) * multip{k};
            end
        end
    catch
        fprintf('\nException in reading dfs3, step %i, item %i\n',tstep, k);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ds  = datestr(clock);
fprintf('\n%s:: Grouping extracted seepage values from %s\n',ds, char(FNAME));
ARRAY_GROUPS = sum_ARRAY_GROUPS(TS.ValueMatrix,MyRequestedStnNames);
TV = TS.TIMEVECS(:,1:3);
DATA = [TV ARRAY_GROUPS];
GROUPS = unique(MyRequestedStnNames);
HEADER = [{'Year'}; {'Month'}; {'Day'}; GROUPS]';
sz = size(ARRAY_GROUPS);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ds  = datestr(clock);
% create a map of stations and corresponding sumation 
fprintf('%s:: Creating a MAP of computed from: %s\n',ds, char(FNAME))
MAP_COMPUTED_GROUPS = create_MAP_COMPUTED(TS,GROUPS,ARRAY_GROUPS,TV,itms1,DfsDatesVector);
%---------------------------------------------------------------
end

function MAP_COMPUTED_GROUPS = create_MAP_COMPUTED(TS,GROUPS,ARRAY,TV,itms1,DV)

%NewDataSize = size(NewData); % size includes row and column headers.

%num_stns = NewDataSize(1,2)-3; %Num columns minus 3 (for year,month,day headers)
num_stns = length(GROUPS);
FT2M = 0.3048;
CFS2M3 = (0.3048^3);
CellAreaFt = (400/FT2M)^2;

for i=1:num_stns
    
    % get item metadata - hacky - using data for first station for all
    % stations - need to fix
    %   DFSTYPE = char(MyDfsFile.ItemInfo.Item(itms{1}).Quantity.ItemDescription);
    %   UNIT  =   char(MyDfsFile.ItemInfo.Item(itms{1}).Quantity.UnitDescription);
    DFSTYPE = char('Discharge');
    UNIT = char(TS.S.item(itms1{1}).itemunit);
    iNAME = GROUPS(i);
    
    % here I am skipping daily data function and ASSUMING the data is
    % already daily.  should fix this...
    % put data into a 1-D array for get_daily_data function
    %D = TimeseriesData(:,i);
    
    % '2:end' skips the row with station names in the NewData array
    % '3+i' skips the first 3 columns, which are year, month, and day
    D = ARRAY(:,i);
    
    % convert units
    %if strcmp(UNIT,'mm/day'), D = D*MMperDYToFT3perSperCell; UNIT = 'ft^3/s'; end;
    if strcmp(UNIT,'m^3/s'), D = D/CFS2M3; UNIT = 'ft^3/s'; end;
    if strcmp(UNIT,'meter'), D = D/FT2M;   UNIT = 'feet';   end;
    if strcmp(UNIT,'m'), D = D/FT2M;   UNIT = 'feet';   end;
    
    % extract daily values
    %D_DAILY = get_daily_data_v1(D,DfsTimeVector,num_dfs_days);
    D_DAILY = D;
    
    % save info in DATA_COMPUTED structure
    DATA_COMPUTED(i).TIMESERIES = D_DAILY;
    
    DATA_COMPUTED(i).NAME = {iNAME};
    DATA_COMPUTED(i).DFSTYPE = DFSTYPE;
    DATA_COMPUTED(i).UNIT = UNIT;
    DATA_COMPUTED(i).TIMEVECTOR = DV;
    
    % prep data to be saved into container
    NAME(i) = iNAME; %keys
    MAP_SIM(i) = {DATA_COMPUTED(i)}; %cells containing structures
end

% fprintf('%s Closing file: %s\n',datestr(now), char(FILE_DFS));
TS.S.myDfs.Close();

% save data into container
MAP_COMPUTED_GROUPS = containers.Map(NAME,MAP_SIM);

end


function TS = get_TS_GRID(FILE_DFS)

fprintf('%s Reading file: %s\n',datestr(now), char(FILE_DFS));
[DIR,FNAME,EXT] = fileparts(FILE_DFS);

try
    if strcmp(EXT,'.dfs2')
        TS = InputDFS2(FILE_DFS);
    end
    
    if strcmp(EXT,'.dfs3')
        TS = InputDFS3v1(FILE_DFS);
    end
    
    if isempty(TS)
        fprintf('\nWARNING - file extension not .dfs2, or .dfs3: %s\n', char(FILE_DFS));
        fprintf('read_and_group_computed_timeseries cannot handle this type of file yet: %s\n', char(FILE_DFS));
        return;
    end
    
catch
    fprintf('\nException in get_TS_GRID reading .dfs2, or .dfs3: %s\n', char(FILE_DFS));
    
end
end

function ARRAY_GROUPS = sum_ARRAY_GROUPS(ARRAY,MyRequestedStnNames);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variable ARRAY contains the computed values, ARRRAY_GROUPS is the
% sumation over the unique names
n_array = size(ARRAY);
GROUPS = unique(MyRequestedStnNames);
n_groups = size(GROUPS);
ARRAY_GROUPS(1:n_array(1),n_groups(1)) = 0;
i = 0;
for N = GROUPS'
    i = i + 1;
    IND = ismember(MyRequestedStnNames,N)';  
    ARRAY_GROUPS(:,i)  = sum(ARRAY(:,IND),2);
end

end

function XLARRAY = load_XL_GRID(FILE_DFS, INI)

FILE_DIR =  INI.CELL_DEF_FILE_DIR_3DSZQ;
FILE_NAME_GROUP_DEFS = INI.CELL_DEF_FILE_NAME_3DSZQ;

FILE_XL_GRID = [ FILE_DIR FILE_NAME_GROUP_DEFS '.xlsx'];
MATFILE = [ FILE_DIR FILE_NAME_GROUP_DEFS '.MATLAB'];

[DIR,FNAME,FEXT] = fileparts(FILE_DFS);
if strcmp(FEXT,'.dfs2')
    FILE_SHEETNAME = [INI.CELL_DEF_FILE_SHEETNAME_OL];
end
if strcmp(FEXT,'.dfs3')
    FILE_SHEETNAME = [INI.CELL_DEF_FILE_SHEETNAME_3DSZQ];
end

try
% if there there is an existing MATLAB file read read XL file
% if the user specifies this file to be regenerated read XL file
% else load the MATLAB for faster

if INI.OVERWRITE_GRID_XL | ~exist(MATFILE,'file')
        % read monitoring points from excel file, slower process
        XLARRAY = read_XL_GRID(FILE_XL_GRID,FILE_SHEETNAME);
        %save the file in a structure for reading
        fprintf('\n--- Saving Gridded XL data in: %s\n', char(MATFILE))
        MAPXLS = INI.MAPXLS
        save(MATFILE,'XLARRAY','-v7.3');
    else
        % load Monitoring point data from MATLAB for faster processing
        fprintf('\n--- Loading Gridded XL data from: %s\n', char(MATFILE))
        load(MATFILE, '-mat');
    end
catch
    fprintf('... Exception in load_XL_GRIDDED(), %s .xlsx and .MATLAB files missing \n', ...
        char(FILE_NAME_GROUP_DEFS));
end

end

function XLARRAY = read_XL_GRID(xlinfile,FILE_SHEETNAME)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load group definition data from Excel file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('%s Reading file: %s\n',datestr(now), char(xlinfile));

% if ~exist(xlinfile,'file')
%     fprintf('MISSING: %s, exiting...', xlinfile);
%     return
% end

% stn_counter_begin = 0;
% stn_counter_end = 0;
num_sheets = length(FILE_SHEETNAME);

XLARRAY=[];
try
    for sheetnum = 1:num_sheets  % iterate through sheet names given in A0 setup script
        xlsheet = FILE_SHEETNAME{sheetnum};
        [~,~,xldata] = xlsread(xlinfile,xlsheet);
        [numrows,trash] = size(xldata);
        
        % append array of numrows and 11 columns
        XLARRAY = [XLARRAY;xldata(2:numrows,1:11)];
        
        %     stn_counter_begin = stn_counter_end + 1;
        %     stn_counter_end = stn_counter_end + (numrows - 1); % subtract 1 for header row
        %     MyRequestedStnNames(stn_counter_begin:stn_counter_end) = xldata(2:numrows,1);
        %     rows0(stn_counter_begin:stn_counter_end) = xldata(2:numrows,2);
        %     cols0(stn_counter_begin:stn_counter_end) = xldata(2:numrows,3);
        %     lyrs1(stn_counter_begin:stn_counter_end) = xldata(2:numrows,4);
        %     multip(stn_counter_begin:stn_counter_end) = xldata(2:numrows,5);
        %     itms1(stn_counter_begin:stn_counter_end) = xldata(2:numrows,6);
    end
catch
    fprintf('\n--- Exception in read_XL_GRIDDED(): %s\n', char(xlinfile))
    
end
end
