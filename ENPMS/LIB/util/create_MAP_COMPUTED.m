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


