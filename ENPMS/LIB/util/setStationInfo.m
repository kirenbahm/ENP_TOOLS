function STATION = setStationInfo(i, K, mapS, STATION)

% For a given station the functions iterates over station information and
% sets one information

if isKey(mapS,char(K))
    S = mapS(char(K));
    %STATION.STATION_NAME = S.STATION_NAME;
    
    if strcmp(STATION.UNIT,'')
        if isfield(S,'UNIT')
            STATION.UNIT = S.UNIT;
        end
    end
    
    if strcmp(STATION.DATATYPE,'')
        if isfield(S,'DATATYPE')
            STATION.DATATYPE = S.DATATYPE;
        end
    end
    
    if isnan(STATION.X_UTM)
        if isfield(S,'X_UTM')
            STATION.X_UTM = S.X_UTM;
        end
    end
    
    if isnan(STATION.Y_UTM)
        if isfield(S,'Y_UTM')
            STATION.Y_UTM = S.Y_UTM;
        end
    end
    
    if isnan(STATION.I)
        if isfield(S,'I')
            STATION.I = S.I;
        end
    end
    
    if isnan(STATION.J)
        if isfield(S,'J')
            STATION.J = S.J;
        end
    end
    
    if isnan(STATION.Z)
        if isfield(S,'Z')
            STATION.Z = S.Z;
        end
    end
    
    if isnan(STATION.Z_GRID)
        if isfield(S,'Z_GRID')
            STATION.Z_GRID = NaN;
        end
    end
    
    if isnan(STATION.Z_SURVEY)
        if isfield(S,'Z_SURVEY')
            STATION.Z_SURVEY = NaN;
        end
    end
    
    if strcmp(STATION.N_AREA,'')
        if isfield(S,'N_AREA')
            STATION.N_AREA = S.N_AREA;
        end
    end
    
    if isnan(STATION.I_AREA)
        if isfield(S,'I_AREA')
            STATION.I_AREA = S.I_AREA;
        end
    end
    
    if isnan(STATION.SZLAYER(i))
        if isfield(S,'SZLAYER')
            STATION.SZLAYER(i) = S.SZLAYER;
        end
    end
    
    if isnan(STATION.OLLAYER(i))
        if isfield(S,'OLLAYER')
            STATION.OLLAYER(i) = S.OLLAYER;
        end
    end
    
    if strcmp(STATION.MODEL(i),'')
        if isfield(S,'MODEL')
            STATION.MODEL{i} = S.MODEL;
        end
    end
    
    if strcmp(STATION.NOTE(i),'')
        if isfield(S,'NOTE')
            STATION.NOTE{i} = S.NOTE;
        end
    end
    
    if strcmp(STATION.ALTERNATIVE(i),'')
        if isfield(S,'ALTERNATIVE')
            STATION.ALTERNATIVE{i} = S.ALTERNATIVE;
        end
    end
    
end
end

