function [STATION] = OM01_read_dfs0_files(INI,DIR,mapAllStations,LISTING)
n = length(LISTING);

if strcmp(DIR,'Q_M11HR')
    DATATYPE = 'M11';
    DELIM = '_Q';
elseif strcmp(DIR,'H_M11HR')
    DATATYPE = 'M11';
    DELIM = '.';
elseif strcmp(DIR,'H_MSHEHR')
    DATATYPE = 'MSHE';
    DELIM = '.';    
end

ii = 0;
for i = 1:n
    try
        s = LISTING(i);
        FILENAME = s.name;
        FILEPATH = [INI.DIR_DFS0_FILES FILENAME];
        
        % get the name of the file without _Q, .stage .tailwater .headwater
        STR_TEMP = strsplit(FILENAME,DELIM);
        STATION_NAME = STR_TEMP{1};
        try
            TMP_STATION = mapAllStations(char(STATION_NAME));
        catch
            fprintf('... %s not in domain: %d/%d\n', char(STATION_NAME), i, n);
            continue
        end
        % increment only if data within the domain
        M1 = INI.MODEL;
        M2 = TMP_STATION.MODEL;
        if ~any(strcmp(M2,M1))
            fprintf('... %s not in %s domain %d/%d\n', char(STATION_NAME), char(INI.MODEL), i, n);
            continue
        end
        ii = ii + 1;
        STATION(ii) = TMP_STATION;
        if strcmp(STR_TEMP{2},'head_water')
            STATION_NAME = [STATION_NAME '_HW'];
        end
        if strcmp(STR_TEMP{2},'tail_water')
            STATION_NAME = [STATION_NAME '_TW'];
        end
        if strcmp(DELIM,'_Q')
            STATION_NAME = [STATION_NAME '_Q'];
        end        
        STATION(ii).STATION_NAME = STATION_NAME;
        
        %FILE_ID = fopen(char(FILE_NAME));
        fprintf('... reading: %d/%d: %s \n', i, n, char(FILEPATH));
        
        % read database file
        DFS0 = OM02_read_file_DFS0(FILEPATH);
        if strcmp(DFS0.UNIT,'ft')
            if isfield(TMP_STATION,'DATUM')
                if strcmp(TMP_STATION.DATUM,'NAVD88')
                    if isnumeric(TMP_STATION.NAVD_CONV)
                        DFS0.V = DFS0.V - TMP_STATION.NAVD_CONV;
                    else
                        fprintf('... WARNING: NO CONVERSION to NAVD88 %d/%d: %s \n', i, n, char(NAME));
                    end
                end
            end
        end
        STATION(ii).TIMEVECTOR = DFS0.T;
        STATION(ii).DOBSERVED = DFS0.V;
        STATION(ii).DFSTYPE = DFS0.TYPE;
        STATION(ii).UNIT = DFS0.UNIT;
        STATION(ii).STARTDATE = DFS0.T(1);
        STATION(ii).ENDDATE = DFS0.T(end);
        STATION(ii).DATATYPE = DATATYPE;        
        
%         DFS0 = assign_TYPE_UNIT(DFS0,NAME);
%         DFS0.NAME = NAME;
%         
%         fprintf('... reducing: %d/%d: %s \n', i, n, char(FILE_NAME))       
%         DFS0 = data_reduce_HR(DFS0);
%         
% % create a hourly file dfs0 file.   
%         [A, B, C] = fileparts(char(FILE_NAME));
%         FILE_NAME = [INI.CURRENT_PATH,'DFS0HR/',B,'.dfs0']; 
%         DFS0.STATION = B;
%         % save the file in a new directory
%         create_DFS0_GENERIC_Q(INI,DFS0,FILE_NAME);
% 
%         % read the new hourly file
%         fprintf('... reading: %d/%d: %s \n', i, n, char(FILE_NAME));
%         DFS0 = read_file_DFS0(FILE_NAME);
%         DFS0 = assign_TYPE_UNIT(DFS0,NAME);
%         DFS0.NAME = NAME;
%         
%         DFS0 = data_compute(DFS0);
%         INI.DIR_DFS0_FILES = strrep(INI.DIR_DFS0_FILES,'DFS0','DFS0HR');
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
%  
    catch
        fprintf('... exception in: %d/%d: %s \n', i, n, char(FILEPATH));
    end
end

end