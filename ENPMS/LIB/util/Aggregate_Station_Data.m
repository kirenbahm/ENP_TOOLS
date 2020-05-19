function INI = Aggregate_Stations (INI)
% Read Text file with equations
StationEqFile = [INI.DATA_COMMON 'aggregate_rules_file_example.txt'];
fid = fopen(StationEqFile);
tline = fgetl(fid);
stations = {};
while ischar(tline)
    % Line isn't empty and doesn't contain a comment 
    if ~contains(tline,'#') && ~isempty(tline)
        parts = strsplit(tline, ' '); % split line based on spaces Ex A = B + C => [{A} {=} {B} {+} {C}]
        sizeparts = size(parts); % get size of split
        pass = true;
        try
            % Block will complete if desired Aggregate station name is
            % already taken
            STATION = INI.mapCompSelected(char(parts{1}));
            errormsg = '';
            for emi = 1:sizeparts(2)
                if emi == 1
                    errormsg = strcat(errormsg, char(parts{emi}), ' (not calculated) ');
                else
                    errormsg = strcat(errormsg, " ", char(parts{emi}));
                end
            end
            fprintf('%s \n',errormsg);
            pass = false;
        catch
            % Aggregate Station name isn't taken
            EqReport = {}; % Stores parts of print line 
            EqRi = 4;
            EqReport{1} = char(parts{1});
            sumi = 2;
            stationsexist = {}; % stores if station is found
            stationsdaily = {}; % stores if sation timeseries is daily
            
            % stores scalar for timeseries values
            % Ex + = 1, - = -1, not found = 0
            stationaddsub = {}; 
            stationi = 1;
            modcheck = false; % used to alternate between parsing of operators and station names
            DateMin = 999999999; % Earliest Date for Aggregated values
            DateMax = 0; % Latest Date for Aggregated values
            UsableAggregate = false; % True if any station data found
            % Begin checks for if line is a valid equation
            while sumi <= sizeparts(2)
                % Second cell should be equals
                if sumi == 2
                    EqReport{2} = char(parts{2});
                    if strcmp('=',char(parts{sumi})) == true
                        pass = pass & true;
                    else
                        pass = pass & false;
                    end
                % Third cell should be either station name or a +/-
                elseif sumi == 3
                    % If 3rd cell is operator, modcheck changes to match
                    if strcmp('-',char(parts{sumi})) || strcmp('+',char(parts{sumi}))
                        modcheck = false;
                        EqReport{3} = char(parts{3});
                        pass = pass & true;
                    else
                        modcheck = true;
                        %% If not operator then parse as station
                        if mod(sumi,2) == modcheck
                            % Block completes if station found
                            try
                                STATION = INI.mapCompSelected(char(parts{sumi}));
                                tsize = size(STATION.TIMEVECTOR);
                                daily = true;
                                % Pulls time values and checks 
                                % if series is daily values
                                for ti = 2:tsize(1)
                                    if STATION.TIMEVECTOR(ti,1) - STATION.TIMEVECTOR(ti - 1,1) == 1
                                        daily = daily & true;
                                    else
                                        daily = daily & false;
                                    end
                                end
                                EqReport{3} = char(parts{3});
                                stationsdaily{stationi} = daily; % boolean if daily
                                stationsexist{stationi} = true; % boolean if found
                                stationsaddsub{stationi} = 1; % scalar for multiplying values
                                stations{stationi} = STATION; % stores station for later reference
                                UsableAggregate = UsableAggregate | (stationsdaily{stationi} & stationsexist{stationi});
                                DateMin = min(DateMin, STATION.TIMEVECTOR(1,1));
                                DateMax = max(DateMax, STATION.TIMEVECTOR(end,1));
                                stationi = stationi + 1;
                            % station not found
                            catch
                                
                                EqReport{3} = strcat(char(parts{3}), ' (not found)');
                                stationsdaily{stationi} = false; % boolean if daily
                                stationsexist{stationi} = false; % boolean if found
                                stationsaddsub{stationi} = 0; % scalar for multiplying values
                                UsableAggregate = UsableAggregate | (stationsdaily{stationi} & stationsexist{stationi});
                                stationi = stationi + 1;
                            end
                        end
                    end
                % Alternate between parsing of stations and operators
                else
                    if mod(sumi,2) == modcheck
                        try
                            STATION = INI.mapCompSelected(char(parts{sumi}));
                            tsize = size(STATION.TIMEVECTOR);
                            daily = true;
                            % Pulls time values and checks 
                            % if series is daily values
                            for ti = 2:tsize(1)
                                if STATION.TIMEVECTOR(ti,1) - STATION.TIMEVECTOR(ti - 1,1) == 1
                                    daily = daily & true;
                                else
                                    daily = daily & false;
                                end
                            end
                            EqReport{EqRi} = char(parts{sumi});
                            stationsdaily{stationi} = daily; % boolean if daily
                            stationsexist{stationi} = true; % boolean if found
                            
                            % Parses which scalar to use
                            if strcmp('-',char(parts{sumi - 1}))
                                stationsaddsub{stationi} = -1;
                            else
                                stationsaddsub{stationi} = 1;
                            end
                            UsableAggregate = UsableAggregate | (stationsdaily{stationi} & stationsexist{stationi});
                            stations{stationi} = STATION;
                            
                            % Parse Start and End date to find latest and
                            % earliest dates in all station data
                            DateMin = min(DateMin, STATION.TIMEVECTOR(1,1));
                            DateMax = max(DateMax, STATION.TIMEVECTOR(end,1));
                            stationi = stationi + 1;
                        catch
                            EqReport{EqRi} = strcat(char(parts{sumi}), ' (not found)');
                            stationsdaily{stationi} = false; % boolean if daily
                            stationsexist{stationi} = false; % boolean if found
                            stationsaddsub{stationi} = 0; % Scalar multiplier for data
                            UsableAggregate = UsableAggregate | (stationsdaily{stationi} & stationsexist{stationi});
                            stationi = stationi + 1;
                        end
                    elseif mod(sumi,2) == ~modcheck
                        EqReport{EqRi} = char(parts{sumi});
                        % operator should be plus or minus
                        if strcmp('-',char(parts{sumi})) || strcmp('+',char(parts{sumi}))
                            pass = pass & true;
                        else
                            pass = pass & false;
                        end
                    end
                    EqRi = EqRi + 1;
                end
                sumi = sumi + 1;
            end
            EqStationsSize = size(stationsexist);
            if UsableAggregate % If daily data was found for at least of station within equation
                TIMEVECTOR(1:1:(DateMax - DateMin + 1), 1) = 0:1:(DateMax - DateMin);
                TIMEVECTOR = TIMEVECTOR + DateMin;
                AGGREGATE(1:1:(DateMax - DateMin + 1), 1) = NaN;
                First(1:1:(DateMax - DateMin + 1), 1) = true;
                for si = 1:EqStationsSize(2)
                    if(stationsexist{si} && stationsdaily{si})
                        STATION = stations{si};
                        sTS = size(STATION.TIMEVECTOR);
                        for tsi = 1:sTS(1)
                            timestep = STATION.TIMEVECTOR(tsi, 1) - DateMin + 1;
                            if First(timestep)
                                AGGREGATE(timestep) = stationsaddsub{si} * STATION.DCOMPUTED(tsi);
                                First(timestep) = false;
                            else
                                AGGREGATE(timestep) = AGGREGATE(timestep) + (stationsaddsub{si} * STATION.DCOMPUTED(tsi));
                            end
                        end
                    end
                end
                AGGSTATION.STATION_NAME = char(parts{1});
                AGGSTATION.DATATYPE = char('Discharge');
                AGGSTATION.UNIT = char('feet^3/sec');
                AGGSTATION.X_UTM = NaN;
                AGGSTATION.Y_UTM = NaN;
                AGGSTATION.Z = NaN;
                AGGSTATION.I = NaN;
                AGGSTATION.J = NaN;
                AGGSTATION.M11CHAIN = char(' ');
                AGGSTATION.N_AREA = char(' ');
                AGGSTATION.I_AREA = 0;
                AGGSTATION.SZLAYER = 0;
                AGGSTATION.OLLAYER = NaN;
                AGGSTATION.MODEL = char(' ');
                AGGSTATION.NOTE = char(' ');
                AGGSTATION.MSHEM11 = char(' ');
                AGGSTATION.TIMEVECTOR = TIMEVECTOR;
                AGGSTATION.DCOMPUTED = AGGREGATE;
                INI.mapCompSelected(char(parts{1})) = AGGSTATION;
            else % If no daily stations found to aggregate data, not calculated
                EqReport{1} = strcat(EqReport{1}, ' (not calculated)');
            end
            reportmsg = '';
            sR = size(EqReport);
            % Outputs post aggregate equation summary
            for emi = 1:sR(2)
                if emi == 1
                    reportmsg = strcat(reportmsg, char(EqReport{emi}));
                else
                    reportmsg = strcat(reportmsg, " ", char(EqReport{emi}));
                end
            end
            fprintf('%s \n',reportmsg);
        end
    end
    tline = fgetl(fid);
end
fclose(fid);
end
