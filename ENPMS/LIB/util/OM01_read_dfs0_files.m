function [STATION] = OM01_read_dfs0_files(INI,DIR,mapAllStations,LISTING)

station_index = 0;

DELIM = '.';

for current_file_number = 1:num_files
    try
        file_list = LISTING(current_file_number);
        FILENAME = file_list.name;
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
                    fprintf('\n... %s not in domain: %d/%d\n', char(STATION_NAME), current_file_number, num_files);
                    continue
                end
            elseif strcmpi(STR_TEMP{2}, "tail_water")
                try
                    TMP_STATION = mapAllStations(strcat(char(STATION_NAME), "_TW"));
                catch
                    fprintf('\n... %s not in domain: %d/%d\n', char(STATION_NAME), current_file_number, num_files);
                    continue
                end
            elseif strcmpi(DIR, "Q")
                try
                    TMP_STATION = mapAllStations(strcat(char(STATION_NAME), "_Q"));
                catch
                    fprintf('\n... %s not in domain: %d/%d\n', char(STATION_NAME), current_file_number, num_files);
                    continue
                end
            else
                fprintf('\n... %s not in domain: %d/%d\n', char(STATION_NAME), current_file_number, num_files);
                continue
            end
        end
        
        % increment only if data within the domain
        M1 = INI.MODEL;
        M2 = TMP_STATION.MODEL;
        if ~any(strcmp(M2,M1))
            fprintf('\n... %s not in %s domain %d/%d\n', char(STATION_NAME), char(INI.MODEL), current_file_number, num_files);
            continue
        end
        station_index = station_index + 1;
        
        STATION(station_index) = TMP_STATION;
        
        
        % read database file
        fprintf('... reading: %d/%d: %s \n', current_file_number, num_files, char(FILEPATH));
        DFS0 = read_file_DFS0(FILEPATH);
        
        % copy values to STATION
        STATION(station_index).TIMEVECTOR     = DFS0.T;
        STATION(station_index).DOBSERVED      = DFS0.V;
        STATION(station_index).DFSTYPE        = DFS0.TYPE;
        STATION(station_index).UNIT           = DFS0.UNIT;
        STATION(station_index).utmXmeters     = DFS0.utmXmeters;
        STATION(station_index).utmYmeters     = DFS0.utmYmeters;
        STATION(station_index).elev_ngvd29_ft = DFS0.elev_ngvd29_ft;

        STATION(station_index).STARTDATE  = DFS0.T(1);
        STATION(station_index).ENDDATE    = DFS0.T(end);

    catch
        fprintf('... exception in 0M01_read_dfs0_files.m: %d/%d: %s \n', current_file_number, num_files, char(FILEPATH));
    end
end

end