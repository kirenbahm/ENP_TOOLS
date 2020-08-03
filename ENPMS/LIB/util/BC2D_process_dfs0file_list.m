function INI = BC2D_process_dfs0file_list(INI)

INI.MAP_H_DATA = containers.Map();

n = length(INI.LISTING);
for i = 1:n
    try
        s = INI.LISTING(i);
        NAME = s.name;
        FOLDER = s.folder;
        FILE_NAME = [FOLDER '/' NAME];
        
        fprintf('... reading: %d/%d: %s...', i, n, char(FILE_NAME));
        
        % read database file
        DFS0 = read_file_DFS0_delete_nulls(FILE_NAME);
        
        nn = length(DFS0.V);
        
        % determine the file coordinates and make a structure
        C = strsplit(NAME,'.');
        % mapping is by site name
        try
            STATION = INI.MAP_STATIONS(char(C{1}));
        catch
            fprintf('%s:  EXCEPTION in: %d/%d: Not in Domain\n', char(NAME), i, n);
            continue;
        end
        STATION.V_OBS = DFS0.V;
        STATION.V     = DFS0.V;
        
        STATION.T = DFS0.T;
        STATION.UNIT = DFS0.UNIT;
        
        STATION.utmXmeters = DFS0.X_UTM_METERS;
        STATION.utmYmeters = DFS0.Y_UTM_METERS;
        X(i)               = DFS0.X_UTM_METERS;
        Y(i)               = DFS0.Y_UTM_METERS;
        
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
        fprintf('%s:  EXCEPTION in: %d/%d: with n=%d observations\n', char(NAME), i, n, nn);
    end
end
    INI.H_POINTS.X = X;
    INI.H_POINTS.Y = Y;
    INI.H_POINTS.STATION = NAME_STATION;
    INI.H_POINTS.N = N;
    INI.H_POINTS.DATE_I = DATE_I;
    INI.H_POINTS.DATE_E = DATE_F;
    INI.H_POINTS.I = II;
    INI.H_POINTS.J = JJ;

end
