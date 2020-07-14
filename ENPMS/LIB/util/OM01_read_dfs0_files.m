function [STATION] = OM01_read_dfs0_files(INI,DIR,mapAllStations,LISTING)
n = length(LISTING);

DATATYPE = 'M11';
DELIM = '.';
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
            if strcmpi(STR_TEMP{2}, "head_water")
                try
                    TMP_STATION = mapAllStations(strcat(char(STATION_NAME), "_HW"));
                catch
                    fprintf('\n... %s not in domain: %d/%d\n', char(STATION_NAME), i, n);
                    continue
                end
            elseif strcmpi(STR_TEMP{2}, "tail_water")
                try
                    TMP_STATION = mapAllStations(strcat(char(STATION_NAME), "_TW"));
                catch
                    fprintf('\n... %s not in domain: %d/%d\n', char(STATION_NAME), i, n);
                    continue
                end
            elseif strcmpi(DIR, "Q")
                try
                    TMP_STATION = mapAllStations(strcat(char(STATION_NAME), "_Q"));
                catch
                    fprintf('\n... %s not in domain: %d/%d\n', char(STATION_NAME), i, n);
                    continue
                end
            else
                fprintf('\n... %s not in domain: %d/%d\n', char(STATION_NAME), i, n);
                continue
            end
        end
        % increment only if data within the domain
        M1 = INI.MODEL;
        M2 = TMP_STATION.MODEL;
        if ~any(strcmp(M2,M1))
            fprintf('\n... %s not in %s domain %d/%d\n', char(STATION_NAME), char(INI.MODEL), i, n);
            continue
        end
        ii = ii + 1;
        
        STATION(ii) = TMP_STATION;
        
        %FILE_ID = fopen(char(FILE_NAME));
        fprintf('... reading: %d/%d: %s \n', i, n, char(FILEPATH));
        
        % read database file
        DFS0 = read_file_DFS0(FILEPATH);
        
        % convert NAVD88 to NGVD29
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
        
        % copy values to STATION
        STATION(ii).TIMEVECTOR = DFS0.T;
        STATION(ii).DOBSERVED = DFS0.V;
        STATION(ii).DFSTYPE = DFS0.TYPE;
        STATION(ii).UNIT = DFS0.UNIT;
        STATION(ii).STARTDATE = DFS0.T(1);
        STATION(ii).ENDDATE = DFS0.T(end);
        STATION(ii).DATATYPE = DATATYPE;
        
    catch
        fprintf('... exception in 0M01_read_dfs0_files.m: %d/%d: %s \n', i, n, char(FILEPATH));
    end
end

end