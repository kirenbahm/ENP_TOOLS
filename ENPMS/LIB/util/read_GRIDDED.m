function [MAP_COMPUTED_GROUPS] = read_GRIDDED(FILE_DFS, FILE_DIR, FILE_NAME_GROUP_DEFS, FILE_SHEETNAME)


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

% for z-direction flow in mm/day, converted to cubic feet per second integrated over cell face:
MMperDYToFT3perSperCell = (0.001/FT2M)*CellAreaFt/86400;

numcols = 6; % number of columns in Excel file with data (columns 7+ are currently ignored)

% Alldata array is: name,row,col,layer,multiplier,item,year,month,day,hour,min,sec,value
% this is currently hardcoded below and dependent on numcols variable above
myStation = 1;
myYear = 7;
myMonth = 8;
myDay = 9;
myData = 13;


% Pivot data(16) into date(10,11,12) vs station(1) format:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load group definition data from Excel file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

xlinfile = [FILE_DIR FILE_NAME_GROUP_DEFS '.xlsx'];
fprintf('%s Reading file: %s\n',datestr(now), char(xlinfile));
if ~exist(xlinfile,'file')
    fprintf('MISSING: %s, exiting...', xlinfile);
    return
end

stn_counter_begin = 0;
stn_counter_end = 0;
num_sheets = length(FILE_SHEETNAME);

for sheetnum = 1:num_sheets  % iterate through sheet names given in A0 setup script
    xlsheet = FILE_SHEETNAME{sheetnum};
    [~,~,xldata] = xlsread(xlinfile,xlsheet);
    [numrows,trash] = size(xldata);
    stn_counter_begin = stn_counter_end + 1;
    stn_counter_end = stn_counter_end + (numrows - 1); % subtract 1 for header row
    MyRequestedStnNames(stn_counter_begin:stn_counter_end) = xldata(2:numrows,1);
    rows0(stn_counter_begin:stn_counter_end) = xldata(2:numrows,2);
    cols0(stn_counter_begin:stn_counter_end) = xldata(2:numrows,3);
    lyrs1(stn_counter_begin:stn_counter_end) = xldata(2:numrows,4);
    multip(stn_counter_begin:stn_counter_end) = xldata(2:numrows,5);
    itms1(stn_counter_begin:stn_counter_end) = xldata(2:numrows,6);
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load model output data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% step 1: try opening file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% extract file type extension from name: dfs0 or dfs2 or dfs3
ns = length(FILE_DFS);
MyFileExtension = FILE_DFS(ns-4:ns); % last 5 characters of name

% try to open file with appropriate utility, get spatial dimension
% if opening is unsuccessful, return empty container
fprintf('%s Reading file: %s\n',datestr(now), char(FILE_DFS));
try
    if strcmp(MyFileExtension,'.dfs0')  % dfs0 is not enabled in code
        MAP_COMPUTED_GROUPS = containers.Map;  % return an empty structure
        fprintf('\nWARNING - file extension not .dfs2, or .dfs3: %s\n', char(FILE_DFS));
        fprintf('read_and_group_computed_timeseries cannot handle this type of file yet: %s\n', char(FILE_DFS));
        return;
    elseif strcmp(MyFileExtension,'.dfs2')
        TS.S = InputDFS2(FILE_DFS);
        DFS2 = true;
        DFS3 = false;
    elseif strcmp(MyFileExtension,'.dfs3')
        TS.S = InputDFS3v1(FILE_DFS);
        DFS2 = false;
        DFS3 = true;
    else
        MAP_COMPUTED_GROUPS = containers.Map;  % return an empty structure
        fprintf('\nWARNING - file extension not .dfs2, or .dfs3: %s\n', char(FILE_DFS));
        fprintf('read_and_group_computed_timeseries cannot handle this type of file yet: %s\n', char(FILE_DFS));
        return;
    end
catch
    MAP_COMPUTED_GROUPS = containers.Map;  % return an empty structure
    fprintf('\nWARNING - FILE NOT FOUND or DfsFileFactory CANNOT OPEN FILE: %s - skipping\n', char(FILE_DFS));
    return;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% map item names from Excel spreadsheet to item numbers in dfs file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  LEFT OFF HERE 2015-12-08  keb

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
num_dfs_days  = dfs_day_end - dfs_day_begin;
DfsDatesVector = datevec(linspace(dfs_day_begin,dfs_day_end,num_dfs_days));

TS.startdate = dfs_day_begin;   %start extract on this date
TS.enddate = dfs_day_end;

TS = nummthyr(TS);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read through file and pull out the specific items/locations we need
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get number of items in file to read
NumItemsInFile = TS.S.myDfs.ItemInfo.Count;

if DFS2
    % read current timestep for each item in file into array Fx
    % Then pick out item/cell values you need and save to fk array.
    % Assumes 2d array.
    for tstep=0:NumDfsSteps-1
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
    for tstep=0:NumDfsSteps-1
        for i = 1:NumItemsInFile
            Fx{i} = double(TS.S.myDfs.ReadItemTimeStep(i,tstep).To3DArray());
        end
        for k=1:length(MyRequestedStnNames) % iterate through lines in Excel file
            itemRequested = itms1{k};
            fk = Fx{itemRequested};
            TS.ValueMatrix(tstep+1,k) = fk(cols0{k}+1,rows0{k}+1,lyrs1{k}) * multip{k};
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iterate through all stations and copy data into AllData array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% define total number of columns in output array,
% and preallocate space for AllData array
numcolstot = numcols+7;
AllData = cell(length(MyRequestedStnNames)*TS.dlength,numcolstot);

for stn=1:length(MyRequestedStnNames)
    
    sd = TS.S.myDfs.FileInfo.TimeAxis.StartDateTime;
    dfsstartdatetime=datenum(double([sd.Year sd.Month sd.Day sd.Hour sd.Minute sd.Second]));
    DfsTime = double(dfsstartdatetime + TS.S.nsteps-1);
    
    TS.ValueVector =  TSmerge(TS.ValueMatrix(:,stn), TS.dlength, datenum(TS.startdate), datenum(TS.enddate), dfsstartdatetime, DfsTime);
    TS.utmx{:} = 0;
    TS.utmy{:} = 0;
    TS.gridgse{:} = 0;
    TS.title = char(MyRequestedStnNames(stn));
    TS.stationname = char(MyRequestedStnNames(stn));
    TS.stationtype = TS.S.item(itms1{1}).itemdescription;
    
    % Copy Excel data into array that repeats each row 'nsteps' times:
    for q=1:TS.dlength
        MyDat1(q,1) = MyRequestedStnNames(stn);
        MyDat1(q,2) = rows0(stn);
        MyDat1(q,3) = cols0(stn);
        if DFS2; MyDat1(q,4) = num2cell(1); end;
        if DFS3; MyDat1(q,4) = lyrs1(stn); end;
        MyDat1(q,5) = multip(stn);
        MyDat1(q,6) = itms1(stn);
    end
    MyDat2 = num2cell(TS.TIMEVECS);
    MyDat3 = transpose(num2cell(TS.ValueVector));
    
    % combine Excel data, time vectors, and value into one array
    MyData = 0;
    MyData = cat(2,MyDat1,MyDat2,MyDat3);
    
    % set up location to store data in AllData array, and copy it there
    beginindex = ((stn-1)*TS.dlength)+1;
    endindex = beginindex+(TS.dlength)-1;
    AllData(beginindex:endindex,1:numcolstot) = MyData;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pivot and save data structure arrays into container and exit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Alldata is:
% name,row,col,layer,multiplier,item,scratch,scratch,scratch,year,month,day,hour,min,sec,value

% Pivot data into date vs station format:
NewData = pivottable(AllData, [myYear myMonth myDay], myStation, myData, @sum);

NewDataSize = size(NewData); % size includes row and column headers.
num_stns = NewDataSize(1,2)-3; %Num columns minus 3 (for year,month,day headers)
for i=1:num_stns
    
    % get item metadata - hacky - using data for first station for all
    % stations - need to fix
    %   DFSTYPE = char(MyDfsFile.ItemInfo.Item(itms{1}).Quantity.ItemDescription);
    %   UNIT  =   char(MyDfsFile.ItemInfo.Item(itms{1}).Quantity.UnitDescription);
    DFSTYPE = char('Discharge');
    UNIT = char(TS.S.item(itms1{1}).itemunit);
    iNAME =  NewData(1 , 3+i);
    
    % here I am skipping daily data function and ASSUMING the data is
    % already daily.  should fix this...
    % put data into a 1-D array for get_daily_data function
    %D = TimeseriesData(:,i);
    
    % '2:end' skips the row with station names in the NewData array
    % '3+i' skips the first 3 columns, which are year, month, and day
    D = cell2mat(NewData(2:end , 3+i));
    
    % convert units
    %if strcmp(UNIT,'mm/day'), D = D*MMperDYToFT3perSperCell; UNIT = 'ft^3/s'; end;
    if strcmp(UNIT,'m^3/s'), D = D/CFS2M3; UNIT = 'ft^3/s'; end;
    if strcmp(UNIT,'meter'), D = D/FT2M;   UNIT = 'feet';   end;
    
    % extract daily values
    %D_DAILY = get_daily_data_v1(D,DfsTimeVector,num_dfs_days);
    D_DAILY = D;
    
    % save info in DATA_COMPUTED structure
    DATA_COMPUTED(i).TIMESERIES = D_DAILY;
    
    DATA_COMPUTED(i).NAME = {iNAME};
    DATA_COMPUTED(i).DFSTYPE = DFSTYPE;
    DATA_COMPUTED(i).UNIT = UNIT;
    DATA_COMPUTED(i).TIMEVECTOR = DfsDatesVector;
    
    % prep data to be saved into container
    NAME(i) = iNAME; %keys
    MAP_SIM(i) = {DATA_COMPUTED(i)}; %cells containing structures
end

fprintf('%s Closing file: %s\n',datestr(now), char(FILE_DFS));
TS.S.myDfs.Close();


% save data into container
MAP_COMPUTED_GROUPS = containers.Map(NAME,MAP_SIM);

%---------------------------------------------------------------

% AllData data fields:
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

% Pivot data into date vs station format:
% NewData = pivottable(AllData, [10 11 12], 1, 16, @sum)

% % Flow by transect and layer for POR
% pivottable(AllData, 1, 4, 16, @mean)
% pivottable(AllData, 1, 4, 16, @max)
% pivottable(AllData, 1, 4, 16, @min)
% pivottable(AllData, 1, 4, 16, @sum)
% pivottable(AllData, 1, 4, 16, @numel) % numel = number of values
%
% % Flow by transect and year
% pivottable(AllData, 1, 10, 16, @mean)
%
% % Flow by transect and month
% pivottable(AllData, 1, 11, 16, @mean)
%
% % Daily total timeseries of transect flows (all layers)
% %   station vs date format:
% pivottable(AllData, 1, [10 11 12], 16, @sum)
% %   date vs station format:
% pivottable(AllData, [10 11 12], 1, 16, @sum)
%
% % Total transect flows for POR (all layers)
% pivottable(AllData, 1, [], 16, @sum)
%
% % Max and Min for transect flows for POR by layer
% pivottable(AllData, 1, 4, [16 16], {@max, @min})
%
% % example included with pivottable code, I am not sure what this function
% % does but it looked interesting and I want to figure it out
% pivottable(AllData,  1, 2, [3 4], {@sum, @(x)(numel(x))})
%
% % list median and number of values for each transect
% pivottable(AllData, 1, 10, [16 16], {@median, @numel})
%
% % calculate number of values less than 0.01 for each transect
% pivottable(AllData, 1, 10, 16, @(x)(sum(lt((x),0.01) )))
%
% % calculate number of values greater than or equal to 0.005 and less than 0.01 for each transect
% pivottable(AllData, 1, 10, 16, @(x)((sum(lt(x,0.01)))-(sum(lt(x,0.005)))))
%
% % calculate number of elements less than the median for each transect
% pivottable(AllData, 1, 10, 16, @(x)(sum(lt(x,median(x)))))
%
% % % list all unique row-col pairs
% % pivottable(AllData, 2, 3, 1, @unique)
% % Error using cat
% % Dimensions of matrices being concatenated are not consistent.
% %wetMonths=[6 7 8 9 10];
% %dryMonths=[11 12 1 2 3 4 5];
% %sparrowMonths=[2 3 4 5 6];
% %ismember(2,sparrowMonths)
% %ismember(sparrowMonths,2)
% %
% % x = [1 3];
% % y = [1 1 1 3 3];
% % feval(@(x,y)(sum(lt((y),mean(x)))),x,y)
% %
% % ans =
% %
% %      3
%
%---------------------------------------------------------------

end



