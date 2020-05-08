function INI = BC2D_process_dfs0file_list(INI)

INI.MAP_H_DATA = containers.Map();

n = length(INI.LISTING);
for i = 1:n
    try
        s = INI.LISTING(i);
        NAME = s.name;
        FOLDER = s.folder;
        FILE_NAME = [FOLDER '/' NAME];
        %FILE_ID = fopen(char(FILE_NAME));
        fprintf('... reading: %d/%d: %s \n', i, n, char(NAME));
        
        % read database file
        DFS0 = read_file_DFS0_delete_nulls(FILE_NAME);
        nn = length(DFS0.V);
        % determine the file coordinates and make a structure
        C = strsplit(NAME,'.');
        % mapping is by site name
        STATION = INI.MAP_STATIONS(char(C{1}));
        STATION.V_OBS = DFS0.V;
        if isfield(STATION,'DATUM')
            if strcmp(STATION.DATUM,'NAVD88')
                if isnumeric(STATION.NAVD_CONV)
                    DFS0.V = DFS0.V - STATION.NAVD_CONV;
                else
                    fprintf('... WARNING: NO CONVERSION to NAVD88 %d/%d: %s \n', i, n, char(NAME));
                end
            end
        end
        STATION.TYPE = DFS0.TYPE;
        STATION.T = DFS0.T;
        STATION.V = DFS0.V;
        STATION.UNIT = DFS0.UNIT;
        INI.MAP_H_DATA(char(C(1))) = STATION;
%         H_POINTS(i).X = STATION.X_UTM;
%         H_POINTS(i).Y = STATION.Y_UTM;
%         H_POINTS(i).STATION = STATION.STATION;
%         H_POINTS(i).N = nn;
%         H_POINTS(i).DATE_I = DFS0.T(1);
%         H_POINTS(i).DATE_E = DFS0.T(length(DFS0.T));
        
        X(i) = STATION.X_UTM;
        Y(i) = STATION.Y_UTM;
        
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
%         DFS0 = assign_TYPE_UNIT(DFS0,NAME);
%         
%         DFS0.NAME = NAME;        
%         DFS0 = data_compute(DFS0);
%         
%         % generate Timeseries
%         plot_fig_TS_1(DFS0,INI);
%         
%         % generate Cumulative
%         %plot_fig_CUMULATIVE_1(DFS0,INI);
% 
%         % generate CDF
%         plot_fig_CDF_1(DFS0,INI)
%         
%         % generate PE
%         plot_fig_PE_1(DFS0,INI)
%         
%         % plot Monthly
%        % plot_fig_MM_1(DFS0,INI)
%         
%         % plot Annual       
%         plot_fig_YY_1(DFS0,INI)
 INI.MAP_H_DATA(char(C{1})) = STATION; 
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