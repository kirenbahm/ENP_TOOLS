function MAP_COMPUTED_GROUPS = get_GRIDDED_DATA(FILE_DFS, INI)

%---------------------------------------------
% FUNCTION DESCRIPTION:
%
% This function reads MIKESHE raw output files and saves
%   selected items into a .MATLAB file.
% The structures are stored in a map with station name as
% MAP KEY and computed data as MAP VALUE. The structure is accessed
% by providing the key as a character string e.g. D = MAP_ALL_DATA('NP205')

% Note dfs file has first timestep as 0 and matlab saves first timestep
% as 1

% note this script reads the items specified in the Excel sheet. If the
% number of items in the dfs output file changes, this script might be
% reading the wrong items. For example, if SZflow in the x-direction is
% item 1 in one file, and item 2 in another file, this script might pull
% the wrong data, if the Excel sheet item number was not changed.
% This will need to be fixed in future revisions of this function.

% the XL sheet requires 6 data items in the .dfs3 file,
% otherwise code breaks. This requires specific set up in
% the MIKE grid series output file. The variables could be:
% groundwater flow in x-direction
% groundwater flow in y-direction
% groundwater flux in z-direction for MIKE 2019: the other flux items i.e. x and y directions should be unchecked
% groundwater flow in z-direction for MIKE 2016 and 2017

% This code seems very inefficient, copying arrays of data multiple times,
% and looping over the same datasets multiple times.
% This is a good candidate for improvement, if you have the time!

format compact

NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load group definition data from Excel or Matlab file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

XLARRAY = load_XL_GRID(FILE_DFS, INI);

% Assign each vector to corresponding array column
MyRequestedStnNames=XLARRAY(:,1);
rows0=XLARRAY(:,2);  % rows0 is grid row, start counting at 0 (not 1)
cols0=XLARRAY(:,3);  % cols0 is grid column, start counting at 0 (not 1)
%lyrs1=XLARRAY(:,4);  % (NO LONGER USED) lyrs1 is grid layer, start counting at 1 (not 0)
multip=XLARRAY(:,5); % multiplier (usually 1 or -1, depending on flow direction needed)
itms1=XLARRAY(:,6);  % item number, start counting at 1 (not 0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get timeseries data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

% determine whether this is DFS2 or DFS3 file
DFS2 = false;
DFS3 = false;
[~,FNAME,MyFileExtension] = fileparts(FILE_DFS);
if strcmp(MyFileExtension,'.dfs2')
    DFS2 = true;
end
if strcmp(MyFileExtension,'.dfs3')
    DFS3 = true;
end

if DFS2
    % read current timestep for each item in file into array Fx
    % Then pick out item/cell values you need and save to fk array.
    % Assumes 2d array.
    for tstep=0:NumDfsSteps-1

        % Print progress bar to screen as we read file
        ds = datestr(DfsTimeVector(tstep+1,:));
        if mod(tstep-1,10) == 0
            fprintf('.');
        end
        if mod(tstep-1,366) == 0
            fprintf('\n... now on step %i%s%i:: %s ::and counting',tstep+1, '/', NumDfsSteps-1, ds);
        end

        % Read file and save in array.
        for i = 1:NumItemsInFile
            Fx{i} = double(TS.S.myDfs.ReadItemTimeStep(i,tstep).To2DArray());
        end

        % Pull out data we want and save in new array.
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

            % Print progress bar to screen as we read file
            ds = datestr(DfsTimeVector(tstep+1,:));
            if mod(tstep-1,10) == 0
                fprintf('.');
            end
            if mod(tstep-1,366) == 0
                fprintf('\n... now on step %i%s%i:: %s ::and counting',tstep+1, '/', NumDfsSteps-1, ds);
            end

            % Read all items for this timestep and save in array Fx.
            try
                for i = 1:NumItemsInFile
                    Fx{i} = double(TS.S.myDfs.ReadItemTimeStep(i,tstep).To3DArray());
                end
            catch
                fprintf('\nException: number of requested items greater than available in dfs3 :  %i%s%i \n', i, ' out of ', NumItemsInFile);
            end

            % Determine number of layers in data array
            [~,~,numLayers] = size(Fx{1}); % [numCols,numRows,numLayers]

            % Pull out data we want and save in new array.
            for k=1:length(MyRequestedStnNames) % iterate through lines in Excel file
                % Figure ut which item we want data for
                itemRequested = itms1{k};
                % Copy data for that item into a new array
                fk = Fx{itemRequested};
                % Copy data for first layer to TS
                TS.ValueMatrix(tstep+1,k) = fk(cols0{k}+1,rows0{k}+1,1) * multip{k};
                % Loop over remaining model layers and sum data into TS
                for layerNum=2:numLayers
                    TS.ValueMatrix(tstep+1,k) = TS.ValueMatrix(tstep+1,k) + fk(cols0{k}+1,rows0{k}+1,layerNum) * multip{k}; % hardcode layer to 1 to make sure script doesn't break with new Excel file - CONFIRMED!
                end  % end loop over model layers
            end
        end
    catch
        fprintf('\nException in reading dfs3, step %i, item %i\n',tstep, k);
    end
end

%---------------------------------------------------------------

ds  = datestr(clock);
fprintf('\n%s:: Grouping extracted seepage values from %s\n',ds, char(FNAME));
ARRAY_GROUPS = sum_ARRAY_GROUPS(TS.ValueMatrix,MyRequestedStnNames);

%---------------------------------------------------------------

ds  = datestr(clock);
% create a map of stations and corresponding sumation
fprintf('%s:: Creating a MAP of computed from: %s\n',ds, char(FNAME))
TV = TS.TIMEVECS(:,1:3);
GROUPS = unique(MyRequestedStnNames);
MAP_COMPUTED_GROUPS = create_MAP_COMPUTED(TS,GROUPS,ARRAY_GROUPS,TV,itms1,DfsDatesVector);

end

