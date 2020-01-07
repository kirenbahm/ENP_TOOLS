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

