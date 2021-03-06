function INI = BC2D_process_dfs0file_list(INI)

% Select Hourly or Daily dfs0 files
if strcmpi(INI.OLorSZ,'OL')
    FILE_FILTER = 'DFS0HR/*.dfs0'; % list only files with extension .out
elseif strcmpi(INI.OLorSZ,'SZ')
    FILE_FILTER = 'DFS0DD/*.dfs0'; % list only files with extension .out
end

LIST_DFS0_F = [INI.STAGE_DIR FILE_FILTER];
INI.LISTING = dir(char(LIST_DFS0_F));

% open stations metadata file and print header info:
fileNameForFileList = [INI.DFS2 '-station_list.txt'];
fileListingID = fopen(fileNameForFileList,'w');
fprintf(fileListingID,"Files used to create %s:\n", INI.DFS2);
fprintf(fileListingID,"Current Date: %s\n", char(datetime));
fprintf(fileListingID,"Time period: %s to %s\n", INI.DATE_I, INI.DATE_E);

if strcmpi(INI.OLorSZ,'OL')
    fprintf(fileListingID,"Increment: hourly\n");
elseif strcmpi(INI.OLorSZ,'SZ')
    fprintf(fileListingID,"Increment: daily\n");
end

if INI.USE_FOURIER
    fprintf(fileListingID,"Method: Fourier\n\n");
elseif INI.USE_JULIAN
    fprintf(fileListingID,"Method: Julian Day\n\n");
elseif INI.USE_UNFILLED
    fprintf(fileListingID,"Method: Unfilled Timeseries\n\n");
else
    fprintf("\n\nERROR - Cannot determine which data to use for BC2D interpolation\n\n");
end

INI.MAP_H_DATA = containers.Map();

num_stations = length(INI.LISTING);
for i = 1:num_stations
    try
        s = INI.LISTING(i);
        NAME = s.name;
        FOLDER = s.folder;
        FILE_NAME = [FOLDER '/' NAME];
        
        fprintf('... %d/%d ', i, num_stations);
        
        % read database file
        DFS0 = read_file_DFS0_delete_nulls(FILE_NAME);
        
        nn = length(DFS0.V);
        
        % determine the file coordinates and make a structure
        C = strsplit(NAME,'.');
        STATION.NAME    = char(NAME);
        STATION.STATION = char(NAME);
        
        STATION.V_OBS = DFS0.V;
        STATION.V     = DFS0.V;
        
        STATION.T = DFS0.T;
        STATION.UNIT = DFS0.UNIT;
        
        STATION.utmXmeters = DFS0.utmXmeters;
        STATION.utmYmeters = DFS0.utmYmeters;
        X(i)               = DFS0.utmXmeters;
        Y(i)               = DFS0.utmYmeters;
        
        INI.MAP_H_DATA(char(C(1))) = STATION;
        
        II(i) = floor((X(i) - INI.X0)/1600);
        II(i) = max(0,II(i));
        II(i) = min(INI.nx-1,II(i));
        STATION.I = II(i);
        
        JJ(i) = floor((Y(i) - INI.Y0)/1600);
        JJ(i) = max(0,JJ(i));
        JJ(i) = min(INI.ny-1,JJ(i));
        STATION.J = JJ(i);
        
        NAME_STATION(i) = C(1);
        N(i) = nn;
        DATE_I(i) = DFS0.T(1);
        DATE_F(i) = DFS0.T(length(DFS0.T));
        
        INI.MAP_H_DATA(char(C{1})) = STATION;
        
        fprintf(fileListingID,"%s\\%s\t%s\n",INI.LISTING(i).folder, INI.LISTING(i).name, INI.LISTING(i).date);
        
        fprintf('  done\n' );
    catch
        fprintf('%s:  EXCEPTION in: %d/%d: with n=%d observations\n', char(NAME), i, num_stations, nn);
    end
end

fclose(fileListingID);

INI.H_POINTS.X = X;
INI.H_POINTS.Y = Y;
INI.H_POINTS.STATION = NAME_STATION;
INI.H_POINTS.N = N;
INI.H_POINTS.DATE_I = DATE_I;
INI.H_POINTS.DATE_E = DATE_F;
INI.H_POINTS.I = II;
INI.H_POINTS.J = JJ;

end
