function DATA = read_file_RES1D(FILE_NAME)

fprintf('\n--- Reading res1d data file: %s\n',char(FILE_NAME));

%% Import Statements
rdAss = NETaddAssembly('DHI.Mike1D.ResultDataAccess.dll');
import DHI.Mike1D.ResultDataAccess.*

%% Process user option selections (legacy)
outType = System.String('All');

%% open file
% Create a ResultData object
rd = DHI.Mike1D.ResultDataAccess.ResultData();

% Connect to file
rd.Connection = DHI.Mike1D.Generic.Connection.Create(FILE_NAME);

%% Read header and item information from file
% Load header and data from file (Load(iDiagnostics) loads all data, LoadHeader(iDiagnostics) loads header data)
rd.Load();

%% Read date array
NumberOfTimeSteps = rd.NumberOfTimeSteps;
time = zeros(rd.NumberOfTimeSteps,1);
for t = 1:NumberOfTimeSteps
    yy = double(rd.TimesList.Item(t-1).Year);
    mo = double(rd.TimesList.Item(t-1).Month);
    da = double(rd.TimesList.Item(t-1).Day);
    hh = double(rd.TimesList.Item(t-1).Hour);
    mi = double(rd.TimesList.Item(t-1).Minute);
    se = double(rd.TimesList.Item(t-1).Second);
    time(t,1) = double(datenum(yy,mo,da,hh,mi,se));
end
DATA.T = time;

%% iterate over reaches, data items, and chainages to read data

% initialize data set counter
datasetcounter = 1;

for r = 1:rd.Reaches.Count
    reach = rd.Reaches.Item(r-1);
    reach_name = reach.Name;

    % iterate over data items in each reach (just 'Water Level' and 'Discharge')
    for d = 1:2  %(1=water level, 2=discharge, 3-6 are lateral flows. reach.DataItems.Count=6)
        HorQdataitem = reach.DataItems.Item(d-1);
        data_type =    HorQdataitem.Quantity.Description;
        numChainages = HorQdataitem.NumberOfElements;
        chainlist = double(GetChainages(reach,d-1));

        % Iterate over chainages for each data item in each reach
        for c=1:numChainages
            chainage = chainlist(c);
            parse = num2str(chainage, '%.3f');
            DATA.NAME{datasetcounter} = strcat(upper(char(reach_name)), ';', pad(parse, 12, 'left'), ';', char(data_type));
            DATA.TYPE{datasetcounter} = char(data_type);
            if strcmp(char(data_type),'Water Level') || strcmp(char(data_type),'Water level')
                DATA.UNIT{datasetcounter} = char('m');
                DATA.NAME{datasetcounter} = strcat(upper(char(reach_name)), ';', pad(parse, 12, 'left'), ';', char('Water Level')); % change case to be compatible with Excel data
            elseif strcmp(char(data_type),'Discharge')
                DATA.UNIT{datasetcounter} = char('m^3/s');
            else
                print "\n\n Cannot determine unit of input data form Res1D file \n\n"
            end
            DATA.V(:,datasetcounter) = double(HorQdataitem.CreateTimeSeriesData(c-1));

            datasetcounter = datasetcounter + 1;
        end
    end
end

fprintf('\n      done' );
end
