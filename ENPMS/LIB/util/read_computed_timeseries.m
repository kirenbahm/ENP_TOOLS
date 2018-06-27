function [MAP_COMPUTED_DFS] = read_computed_timeseries(FILE_DFS)

%---------------------------------------------
% FUNCTION DESCRIPTION:
%
% This function will open dfs0 files and read data within.
% Files are read for all timesteps but only DAILY values are saved.
% Units are converted
% It saves the data in a container called MAP_COMPUTED_DFS.
%
% ARGUMENTS:
% FILE_DFS: file containing timeseries data you want to extract
% MAP_COMPUTED_DFS: container with station names for keys and timeseries and metadata as values
%
% EXAMPLES:
% dfs0 example: read_computed_timeseries(FILE_MSHE)
%
% COMMENTS:
%
%----------------------------------------
% REVISION HISTORY:
%
% v3  keb 2016-01-15
%   - removed unused code (including unused functionality for dfs2 and 3 files)
%
% changes introduced to v1:  (keb 8/2011)
%  -uses the 2011 version of the DHI MATLAB Toolbox instead of 2008 version.
%  -added function 'get_dfs23_timeseries_v0' to process dfs2 and dfs3 files
%  -added function 'get_cells_from_xls_v0' to read .xls cell list of desired cells to extract
%   from dfs2 and dfs3 files
%  -added working area at end of script
%
% changes introduced to v2:  (keb 10/2011)
%  -removed INI.PostProcTimeVector input argument - now extracts entire time series present in file
%   (I checked and it takes the same amount of time to extract 1 day as 1
%   year - the time commitment seems to depend on number of
%   stations requested... it is possible some looping order needs to be
%   rearranged, didn't check)
%  -added code to create and save DfsTimeVector
%  -added/edited comments
%  -changed variable name CELL_DEF_FILE_NAMES to CELL_DEF_FILE_NAME
%
% FUTURE REVISIONS:
% -keb: plan to add functionality to read res11 files (some code written and in working area below)
% -keb: plan to add functionality to read dfs2&3 files with no time axis (this could become fixed/irrelevant in v2 - didn't check yet)
% -keb: should probably make unit conversions explicit or part of input arguments somehow
% -keb: might be nice to use text files instead of Excel spreadsheets (k.i.s.s.)
%----------------------------------------

NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;

FT2M = 0.3048;
CFS2M3 = (0.3048^3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% step 1: try opening file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% find file type: dfs0 or dfs2 or dfs3
ns = length(FILE_DFS);
MyFileExtension = FILE_DFS(ns-4:ns);

% try to open file
try
    if strcmp(MyFileExtension,'.dfs0')
        import DHI.Generic.MikeZero.DFS.dfs0.*;
        MyDfsFile=DfsFileFactory.DfsGenericOpen(FILE_DFS);
        MyDfsFileDim = MyDfsFile.ItemInfo.Item(0).SpatialAxis.Dimension;
    else
        MAP_COMPUTED_DFS = containers.Map;  % return an empty structure
        fprintf('\nWARNING - file extension not .dfs0 %s\n', char(FILE_DFS));
        return;
    end
catch
    MAP_COMPUTED_DFS = containers.Map;  % return an empty structure
    fprintf('\nWARNING - FILE NOT FOUND or DfsFileFactory CANNOT OPEN FILE: %s - skipping\n', char(FILE_DFS));
    return;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% step 2: read data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('...%s: Reading file: %s\n', datestr(now), char(FILE_DFS));

%---------------------------------------------------------------
% dfs0 files: read ALL items and ALL timesteps in file
%---------------------------------------------------------------
% Use the Dfs0Util for bulk-reading all data and timesteps
% Data is 2-D array with times as first item, and item values after
% THIS is HARDCODED to read ALL timesteps from file. So far it still goes fast, so maybe no need to fix.
AllFileData = double(Dfs0Util.ReadDfs0DataDouble(MyDfsFile)); % read all data in file

TimeseriesData = AllFileData(:,2:end); % parse out item timeseries data from array
TimesInSeconds = AllFileData(:,1);     % parse out timestamp array (seconds since startdate)

% set up station name array
num_stns = MyDfsFile.ItemInfo.Count;
for i=1:num_stns
    MyRequestedStnNames(:,i) = {char(MyDfsFile.ItemInfo.Item(i-1).Name)};
end

% set up start date vector
sd=MyDfsFile.FileInfo.TimeAxis.StartDateTime;
dfsstartdatetime=datenum(double([sd.Year sd.Month sd.Day sd.Hour sd.Minute sd.Second]));

% transfer timestamp array (in seconds since startdate) to time vectors
for t=1:length(TimesInSeconds)
    DfsTime = datenum(double([0 0 0 0 0 TimesInSeconds(t)]));
    DfsTimeVector(t,:) = datevec(DfsTime + dfsstartdatetime);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% step 3: save data structure arrays into container and exit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
num_dfs_steps = length(DfsTimeVector);
dfs_day_begin = floor(datenum(DfsTimeVector(1,:)));
dfs_day_end   = floor(datenum(DfsTimeVector(num_dfs_steps,:)));
num_dfs_days  = dfs_day_end - dfs_day_begin;
%DfsDatesVector = datevec(linspace(dfs_day_begin,dfs_day_end,num_dfs_days));
DfsDatesVector = datevec([dfs_day_begin:dfs_day_end]);
%DfsDatesVector = int32(DfsTimeVector); % The purpose of DfsDatesVector is not clear, seems it has to be DfsTimeVector

for i=1:num_stns
    
    % get item metadata
    if MyDfsFileDim == 0
        myitem = i;
    elseif MyDfsFileDim == 2 || MyDfsFileDim == 3
        myitem = MyRequestedStns{i,4};
    end
    
    DFSTYPE = char(MyDfsFile.ItemInfo.Item(myitem-1).Quantity.ItemDescription);
    UNIT  =   char(MyDfsFile.ItemInfo.Item(myitem-1).Quantity.UnitDescription);
    iNAME =  MyRequestedStnNames(i);
    
    % put data into a 1-D array for get_daily_data function
    D = TimeseriesData(:,i);
    
    % convert units
    if strcmp(UNIT,'m^3/s'), D = D/CFS2M3; UNIT = 'ft^3/s'; end;
    if strcmp(UNIT,'meter^3/sec'), D = D/CFS2M3; UNIT = 'ft^3/s'; end;
    if strcmp(UNIT,'meter'), D = D/FT2M;   UNIT = 'feet';   end;
    
    % extract daily values
    D_DAILY = get_daily_data(D,DfsTimeVector,num_dfs_days);
    
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

% fprintf('...%s: Closing file: %s\n', datestr(now), char(FILE_DFS));
% closing file is instantaneous and has no meaning

MyDfsFile.Close();

% save data into container
MAP_COMPUTED_DFS = containers.Map(NAME,MAP_SIM);

end


