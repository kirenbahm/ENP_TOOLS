% Use OutOption= -1 for options
function DATA = read_file_RES11(FILE_NAME, OutOption)

%------------------------------------
% Import Statements
%------------------------------------
dmi = NET.addAssembly('DHI.Mike.Install');
if (~isempty(dmi))
    DHI.Mike.Install.MikeImport.SetupLatest({DHI.Mike.Install.MikeProducts.MikeCore});
end
NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;

%% Lines for debugging
%%FILE_NAME = 'data\test_all_WM_outputs.res11';
%%FILE_NAME = 'data\test_all_WM_outputsHDAdd.res11';
%%OutOption = 0;

%------------------------------------
% Process user option selections
%------------------------------------
%% Determines Output Data
filetype = FILE_NAME(end-8:end);
if (OutOption == 0) % Outputs all information
    outType = System.String('All');
elseif (OutOption == -1) % Looks though all for report and display structure
    disp('OutOption value returns:');
    disp(' -1 : output options and data structure');
    disp(' 0 : all data in file. It can be time consuming');
    if (strcmpi(filetype, 'HDAdd.res11'))
        disp(' 1 : Elevation');
        disp(' 2 : Discharge');
        disp(' 3 : Flow Area');
        disp(' 4 : Flow velocity');
        disp(' 5 : Water Volume');
        disp(' 6 : Gate Level');
        disp(' 7 : Control Strategy');
        disp(' 8 : Flow Width');
        disp(' 9 : Head Elevation');
        disp(' 10 : Hydraulic Radius');
        disp(' 11 : Manning''s M');
        disp(' 12 : Water Volume Error');
        disp(' 13 : Conveyance');
        disp(' 14 : Froude No');
        disp(' 15 : Courant Number');
        disp(' 16 : Dimensionless factor');
        disp(' 17 : Shear stress');
        disp(' 18 : Flooded Area');
        disp(' 19 : Acc. Water Volume Error');
        disp(' 20 : TimeStep');
    else
        disp(' 1 : Water Level');
        disp(' 2 : Discharge');
    end
    outType = System.String('All');
elseif (OutOption == 1)
    if(strcmpi(filetype, 'HDAdd.res11'))
        outType = System.String('Elevation'); % Elevation for HDAdd.res11
    else
        outType = System.String('Water Level'); % Water Level for .res11
    end
elseif (OutOption == 2)
    outType = System.String('Discharge'); % Discharge in Either HDAdd.res11 or .res11
else
    if(strcmpi(filetype, 'HDAdd.res11')) % Remain only for Add.Res11
        if (OutOption == 3)
            outType = System.String('Flow Area');
        elseif (OutOption == 4)
            outType = System.String('Flow velocity');
        elseif (OutOption == 5)
            outType = System.String('Water Volume');
        elseif (OutOption == 6)
            outType = System.String('Gate Level');
        elseif (OutOption == 7)
            outType = System.String('Undefined'); %% Control Strategy
        elseif (OutOption == 8)
            outType = System.String('Flow Width');
        elseif (OutOption == 9)
            outType = System.String('Head Elevation');
        elseif (OutOption == 10)
            outType = System.String('Hydraulic Radius');
        elseif (OutOption == 11)
            outType = System.String('Manning''s M');
        elseif (OutOption == 12)
            outType = System.String('Water Volume Error');
        elseif (OutOption == 13)
            outType = System.String('Conveyance');
        elseif (OutOption == 14)
            outType = System.String('Froude No');
        elseif (OutOption == 15)
            outType = System.String('Courant number');
        elseif (OutOption == 16)
            outType = System.String('Dimensionless factor');
        elseif (OutOption == 17)
            outType = System.String('Shear stress');
        elseif (OutOption == 18)
            outType = System.String('Flooded Area');
        elseif (OutOption == 19)
            outType = System.String('Acc. Water Volume Error');
        elseif (OutOption == 20)
            outType = System.String('TimeStep');
        else % if invalid option number All for Add.Res11
            outType = System.String('All');
            OutOption = 0;
        end
    else %if invalid option number All for .res11
        outType = System.String('All');
        OutOption = 0;
    end
end

%--------------------------------------------
% Read header and item information from file
%--------------------------------------------
%% Open File
res11File  = DfsFileFactory.DfsGenericOpen(FILE_NAME);

%% Declare arrays for storing values
names = {};
type = {};
unit = {};
total = 0;
indices = zeros(res11File.ItemInfo.Count);
ind = 0;
headerInfo = 0; %for use in OutOption == -1 report

%% Initial Loop for finding size of output as well as which time series will be read
for iitem=1:res11File.ItemInfo.Count % for all ItemInfo.Items
    itemInfo = res11File.ItemInfo.Item(iitem-1);
    % If OutOption is all or Item matches desired output
    if(strcmpi(char(itemInfo.Quantity.ItemDescription), char(outType)) || strcmpi(char(System.String('All')), char(outType)))
        ind = ind + 1;
        indices(ind) = iitem - 1;
        % item name is on the form: Quantity, branchName chainagefrom-to
        % example: Water Level, VIDAA-NED 8775.000-10800.000
        itemName = char(itemInfo.Name);
        % Split on ', ' - seperates quantity and branch
        split = regexp(itemName,', ','split');
        itemQuantity = split{1};
        branch = split{2};
        % Branch name and chainages are split on the last ' '
        I = find(branch == ' ');
        if(isempty(I))
            branchName = branch;
        else
            I1 = I(end);
            branchName = branch(1:I1-1);
        end
        % If spatial axis contains coordinates
        if(itemInfo.SpatialAxis.Dimension > 0)
            coords = itemInfo.SpatialAxis.Coordinates;
            chainages = zeros(coords.Length,1);
            for co=1:coords.Length
                % chainage is stored as X coordinate
                chainages(co) = coords(co).X;
            end
            chainages = chainages.';
        else
            % if itemInfo.Name didn't conatin a chainage
            if(isempty(I))
                chainages = 0;
            else
                % use chainage from name
                chainages = str2double(branch(I1:end));
            end
        end
        % Loops through elements of an Item
        for e=1:itemInfo.ElementCount
            total = total + 1;
            ch = chainages(e);
            parse = num2str(ch, '%.3f');
            % Sets that items name
            names{total} = strcat(branchName, ';', pad(parse, 12, 'left'), ';', itemQuantity);
            if(OutOption == -1) %If only generating a report
                if (size(type) == zeros(1, 2)) %if only the first entry just place it
                    headerInfo = headerInfo + 1;
                    type(headerInfo) = {char(itemInfo.Quantity.ItemDescription)};
                    unit(headerInfo) = {char(itemInfo.Quantity.UnitAbbreviation)};
                else
                    found = false;
                    % otherwise loop through existing report entries
                    % So we don't repeat data set types
                    % This shortens the list to review of data series types
                    for t=1:headerInfo
                        if(strcmpi(type{t}, char(itemInfo.Quantity.ItemDescription)))
                            found = true;
                            t = size(type);
                        end
                    end
                    if(~found) % If data type not in list already, add it
                        headerInfo = headerInfo + 1;
                        type(headerInfo) = {char(itemInfo.Quantity.ItemDescription)};
                        unit(headerInfo) = {char(itemInfo.Quantity.UnitAbbreviation)};
                    end
                end
            else %% if not generating report, add to output array
                type(total) = {char(itemInfo.Quantity.ItemDescription)};
                unit(total) = {char(itemInfo.Quantity.UnitAbbreviation)};
            end
        end
    end
end

%------------------------------------
% Read data from file
%------------------------------------
%% declares arrays for storing output data
vals = zeros(res11File.FileInfo.TimeAxis.NumberOfTimeSteps,total);
time = zeros(1, res11File.FileInfo.TimeAxis.NumberOfTimeSteps);
if(OutOption == -1) %% if Output is Report
    DATA.V = size(vals); % List size of read values
    DATA.T = size(time'); % list amount of timesteps
    DATA.NAME = names; % list of names
    DATA.TYPE = type; % list of data types
    DATA.UNIT = unit; % list of data units
else
    res11File.Reset();
    %% Initializes variables for creating serial number time step values
    %% as well as the start date
    yy = double(res11File.FileInfo.TimeAxis.StartDateTime.Year);
    mo = double(res11File.FileInfo.TimeAxis.StartDateTime.Month);
    da = double(res11File.FileInfo.TimeAxis.StartDateTime.Day);
    hh = double(res11File.FileInfo.TimeAxis.StartDateTime.Hour);
    mi = double(res11File.FileInfo.TimeAxis.StartDateTime.Minute);
    se = double(res11File.FileInfo.TimeAxis.StartDateTime.Second);
    START_TIME = double(datenum(yy,mo,da,hh,mi,se));
    
    %% Read data from file and store in vals
    for i=1:res11File.FileInfo.TimeAxis.NumberOfTimeSteps
        readOrder = 0;
        %% searches through index of selected time series type
        for iitem=1:ind
            itemInfo = res11File.ItemInfo.Item(indices(iitem));
            current = res11File.ReadItemTimeStep(indices(iitem) + 1, i-1);
            dd = double(current.Data);
            %% if first element in time step, read timestep information
            if (iitem == 1)
                time(i) = (DfsExtensions.ToSeconds(res11File.FileInfo.TimeAxis, current.Time) / 86400.0) + START_TIME;
            end
            for e=1:itemInfo.ElementCount
                % Store the indexed values in vals, in the correct columns
                readOrder = readOrder + 1;
                vals(i, readOrder) = dd(e);
            end
        end
    end
    %% Stores Collected Information into Output
    DATA.T = time';
    DATA.V = vals;
    DATA.TYPE = type;
    DATA.UNIT = unit;
    DATA.NAME = names;
end

end
