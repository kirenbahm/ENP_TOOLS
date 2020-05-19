function INI = Aggregate_Station_Data (INI)
StationEqFile = [INI.DATA_COMMON 'aggregate_rules_file_example.txt'];
fid = fopen(StationEqFile);
tline = fgetl(fid);
Eq = {};
Stations = {};
Eqi = 1;
while ischar(tline)
    if ~contains(tline,'#') && ~isempty(tline)
        parts = strsplit(tline, ' ');
        sizeparts = size(parts);
        pass = true;
        try
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
            EqReport = {};
            EqRi = 4;
            EqReport{1} = char(parts{1});
            sumi = 2;
            stationsexist = {};
            stationsdaily = {};
            stationaddsub = {};
            stationi = 1;
            modcheck = false;
            DateMin = 999999999;
            DateMax = 0;
            UsableAggregate = false;
            while sumi <= sizeparts(2)
                if sumi == 2
                    EqReport{2} = char(parts{2});
                    if strcmp('=',char(parts{sumi})) == true
                        pass = pass & true;
                    else
                        pass = pass & false;
                    end
                elseif sumi == 3
                    if strcmp('-',char(parts{sumi})) || strcmp('+',char(parts{sumi}))
                        modcheck = false;
                        EqReport{3} = char(parts{3});
                    else
                        modcheck = true;
                        if mod(sumi,2) == modcheck
                            try
                                STATION = INI.mapCompSelected(char(parts{sumi}));
                                tsize = size(STATION.TIMEVECTOR);
                                daily = true;
                                for ti = 2:tsize(1)
                                    if STATION.TIMEVECTOR(ti,1) - STATION.TIMEVECTOR(ti - 1,1) == 1
                                        daily = daily & true;
                                    else
                                        daily = daily & false;
                                    end
                                end
                                EqReport{3} = char(parts{3});
                                stationsdaily{stationi} = daily;
                                stationsexist{stationi} = true;
                                stationsaddsub{stationi} = 1;
                                stations{stationi} = STATION;
                                UsableAggregate = UsableAggregate | (stationsdaily{stationi} & stationsexist{stationi});
                                DateMin = min(DateMin, STATION.TIMEVECTOR(1,1));
                                DateMax = max(DateMax, STATION.TIMEVECTOR(end,1));
                                stationi = stationi + 1;
                            catch
                                EqReport{3} = strcat(char(parts{3}), ' (not found)');
                                stationsdaily{stationi} = false;
                                stationsexist{stationi} = false;
                                stationsaddsub{stationi} = 0;
                                UsableAggregate = UsableAggregate | (stationsdaily{stationi} & stationsexist{stationi});
                                stationi = stationi + 1;
                            end
                        elseif mod(sumi,2) == ~modcheck
                            EqReport{3} = char(parts{3});
                            if strcmp('-',char(parts{sumi})) || strcmp('+',char(parts{sumi}))
                                pass = pass & false;
                            else
                                pass = pass & true;
                            end
                        end
                    end
                else
                    if mod(sumi,2) == modcheck
                        try
                            STATION = INI.mapCompSelected(char(parts{sumi}));
                            tsize = size(STATION.TIMEVECTOR);
                            daily = true;
                            for ti = 2:tsize(1)
                                if STATION.TIMEVECTOR(ti,1) - STATION.TIMEVECTOR(ti - 1,1) == 1
                                    daily = daily & true;
                                else
                                    daily = daily & false;
                                end
                            end
                            EqReport{EqRi} = char(parts{sumi});
                            stationsdaily{stationi} = daily;
                            stationsexist{stationi} = true;
                            if strcmp('-',char(parts{sumi - 1}))
                                stationsaddsub{stationi} = -1;
                            else
                                stationsaddsub{stationi} = 1;
                            end
                            UsableAggregate = UsableAggregate | (stationsdaily{stationi} & stationsexist{stationi});
                            stations{stationi} = STATION;
                            DateMin = min(DateMin, STATION.TIMEVECTOR(1,1));
                            DateMax = max(DateMax, STATION.TIMEVECTOR(end,1));
                            stationi = stationi + 1;
                        catch
                            EqReport{EqRi} = strcat(char(parts{sumi}), ' (not found)');
                            stationsdaily{stationi} = false;
                            stationsexist{stationi} = false;
                            stationsaddsub{stationi} = 0;
                            UsableAggregate = UsableAggregate | (stationsdaily{stationi} & stationsexist{stationi});
                            stationi = stationi + 1;
                        end
                    elseif mod(sumi,2) == ~modcheck
                        EqReport{EqRi} = char(parts{sumi});
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
            if UsableAggregate
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
            end
            reportmsg = '';
            sR = size(EqReport);
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
