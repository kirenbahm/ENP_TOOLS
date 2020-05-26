function INI = Aggregate_Station_Data (INI)

%---------------------------------------------------------------------
%---------------------------------------------------------------------
%  README for this function
%---------------------------------------------------------------------
%---------------------------------------------------------------------
%   This function reads a text file containing equation to create aggregate
%   stations, then creates a new station in the database for the aggrgate
%   station. It then reads the flow data from the station to sum based on
%   the equation and stores the new aggrgate timeseries data in the new
%   station.

% Function flows as follows.
% Read a line
% Check if line is comment or empty, if not attempt to parse equation.
% First check is if new Aggregate Station Name is taken, if not continue
% If operators are in correct positions the equation is valid and continues
% If Station is found, data is daily, and flow then staion is used, if not skipped
% If there is one valid station,
% Then the new Aggregate station will be calculated and added to database.
% Else if will not be calculated.

% Read Text file with equations
fid = fopen(INI.AGGREGATE_EQUATIONS);
fprintf('\n--Reading Aggregate Staions Equations from file....\n');
tline = fgetl(fid);
stations = {};
fprintf('--Creating Aggregate Staions based on file Equations....\n');
% while loop reads file line by line
while ischar(tline)
    % If line isn't empty and doesn't contain a comment then parse equation
    if ~contains(tline,'#') && ~isempty(tline)
        fprintf('\n----Parsing Equation\n');
        fprintf('----%s\n', tline);
        parts = strsplit(tline, ' '); % split line based on spaces Ex. A = B + C => [{A} {=} {B} {+} {C}]
        sizeparts = size(parts); % get size of split
        pass = true;
        try
            % Block will complete if desired Aggregate station name is
            % already taken
            EqReport = {}; % Stores parts of print line
            fprintf("----Assigning Aggregate Station ID: %s....", char(parts{1}));
            STATION = INI.mapCompSelected(char(parts{1}));
            % Reches here if new aggregate station name is already in
            % database
            fprintf('failed. ID already used.\n');
            EqReport{1} = strcat(char(parts{1}), ' (not calculated)');
            pass = false;
        catch
            % Aggregate Station name isn't taken
            fprintf('Success.\n');
            EqRi = 4;
            EqReport{1} = char(parts{1});
            sumi = 2;
            stationflow = {}; %stores if station is discharge
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
                        % If not operator then parse as station
                        if mod(sumi,2) == modcheck
                            % Block completes if station found
                            try
                                fprintf('----Checking Summand Station %s', char(parts{sumi}));
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
                                stationsflow{stationi} = strcmpi(STATION.DATATYPE, 'discharge');
                                if ~stationsflow{stationi}
                                    EqReport{3} = '';
                                    fprintf('...Not Flow\n');
                                elseif ~stationsdaily{stationi}
                                    EqReport{3} = '';
                                    fprintf('...Not Daily\n');
                                end
                                stations{stationi} = STATION; % stores station for later reference
                                UsableAggregate = UsableAggregate | (stationsdaily{stationi} & stationsexist{stationi} & stationsflow{stationi});
                                DateMin = min(DateMin, STATION.TIMEVECTOR(1,1)); % checks if first date in time series is minimum
                                DateMax = max(DateMax, STATION.TIMEVECTOR(end,1));% checks if last date in time series is maximum
                                if stationsdaily{stationi} && stationsexist{stationi} && stationsflow{stationi}
                                    fprintf('...OK\n');
                                end
                                stationi = stationi + 1;
                            % station not found
                            catch
                                fprintf('...Not found\n');
                                EqReport{3} = '';
                                stationsdaily{stationi} = false; % boolean if daily
                                stationsexist{stationi} = false; % boolean if found
                                stationsaddsub{stationi} = 0; % scalar for multiplying values
                                stationsflow{stationi} = false;
                                UsableAggregate = UsableAggregate | false;
                                stationi = stationi + 1;
                            end
                        end
                    end
                % Alternate between parsing of stations and operators
                else
                    if mod(sumi,2) == modcheck
                        try
                            fprintf('----Checking Summand Station %s', char(parts{sumi}));
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
                            stationsflow{stationi} = strcmpi(STATION.DATATYPE, 'discharge');
                            if ~stationsflow{stationi}
                                EqReport{3} = '';
                                fprintf('...Not Flow\n');
                            elseif ~stationsdaily{stationi}
                                EqReport{3} = '';
                                fprintf('...Not Daily\n');
                            end
                            % Parses which scalar to use
                            if strcmp('-',char(parts{sumi - 1}))
                                stationsaddsub{stationi} = -1;
                            else
                                stationsaddsub{stationi} = 1;
                            end
                            UsableAggregate = UsableAggregate | (stationsdaily{stationi} & stationsexist{stationi} & stationsflow{stationi});
                            stations{stationi} = STATION;
                            
                            % Parse Start and End date to find latest and
                            % earliest dates in all station data
                            DateMin = min(DateMin, STATION.TIMEVECTOR(1,1));
                            DateMax = max(DateMax, STATION.TIMEVECTOR(end,1));
                            if stationsdaily{stationi} && stationsexist{stationi} && stationsflow{stationi}
                                fprintf('...OK\n');
                            end
                            stationi = stationi + 1;
                        catch
                            fprintf('...Not found\n');
                            EqReport{sumi - 1} = '';
                            EqReport{sumi} = '';
                            stationsdaily{stationi} = false; % boolean if daily
                            stationsexist{stationi} = false; % boolean if found
                            stationsaddsub{stationi} = 0; % Scalar multiplier for data
                            stationsflow{stationi} = false;
                            UsableAggregate = UsableAggregate | false;
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
            if UsableAggregate & pass % If daily data was found for at least of station within equation
                TIMEVECTOR(1:1:(DateMax - DateMin + 1), 1) = 0:1:(DateMax - DateMin);
                TIMEVECTOR = TIMEVECTOR + DateMin;
                AGGREGATE(1:1:(DateMax - DateMin + 1), 1) = NaN;
                First(1:1:(DateMax - DateMin + 1), 1) = true;
                %debugtest = 'Debug Aggregate Test: ';
                for si = 1:EqStationsSize(2)
                    if(stationsexist{si} && stationsdaily{si})
                        STATION = stations{si};
                        sTS = size(STATION.TIMEVECTOR);
                        %debugtest = strcat(debugtest, " + ", num2str(stationsaddsub{si}), " * ", num2str(STATION.DCOMPUTED(1)));
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
                %fprintf('%s = %f\n', debugtest, AGGREGATE(1))
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
            elseif ~pass
                EqReport = {strcat(EqReport{1}, ' (not calculated)')};
            else % If no daily stations found to aggregate data, not calculated
                EqReport = {strcat(EqReport{1}, ' (not calculated)')};
            end
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
        fprintf('----Final Equation: %s \n',reportmsg);
    end
    tline = fgetl(fid);
end
fclose(fid);
end
