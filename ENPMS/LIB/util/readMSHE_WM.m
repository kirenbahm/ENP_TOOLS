function INI = readMSHE_WM(INI)

% read file  INI.fileSZ for head in saturated zone
infile = INI.fileSZ;

fprintf('\n--- Reading MSHE data file: %s',char(infile));

% get all MSHE stations
mapMSHESEL = getMSHEmap(INI);

% initialize grid dfs3 file reading
TS.S = get_TS_GRIDini(infile);

TV = (TS.S.TSTART:TS.S.TSTART+TS.S.nsteps);

DATA(1:TS.S.XCount,1:TS.S.YCount) = NaN;

a = size(mapMSHESEL); % size of the vector of evaluated stations

i1 = TS.S.TSTART; % length of time vector
i2 = a(1); % length of extracted cells
i3 = 1; % codes of extracted cells

nsteps = TS.S.nsteps;

T = TS.S.TSTART - 1;

for i=0:nsteps-1
    %ds = datestr(TIME(i,:),2);
    %fprintf('%s %s %i %s %i\n', ds, ' Step: ', i+1, '/', TS.S.nsteps);
    T = T + TS.S.TIMESTEPD;
    ds = datestr(T);

    % print progress bar to screen for file reading
    if ~mod(i+1,10) % print only every 10 days
       fprintf('.');
       %fprintf('... Reading SZ Values: %s: %s %i %s %i\n', ds, ' Step: ', i, '/', TS.S.nsteps);
    end
    if ~mod(i,366)
       fprintf('\n      reading step %i%s%i and counting',i+1, '/', nsteps-1);
    end
    
    SZ_ELEV = double(TS.S.DFS.ReadItemTimeStep(1,i).To3DArray());
%     OL_DEPTH = double(TS.S.dfs2.ReadItemTimeStep(1,i).To2DArray());
    j = 0;
    for K = mapMSHESEL.keys
        STATION = mapMSHESEL(char(K));
        j; K;
        j = j + 1;
        x_i = min(TS.S.XCount,STATION.i + 1);
        y_j = min(TS.S.YCount,STATION.j + 1);
        x_i = max(0,x_i);
        y_j = max(0,y_j);
        SZ_ELEV_ijz = SZ_ELEV(x_i,y_j,STATION.Z);
%         OL_DEPTH_ij = OL_DEPTH(x_i,y_j);
        ST(j).NAME = STATION.NAME;
        ST(j).UNIT = TS.S.item(1).itemunit;
        ST(j).DATE(i+1) = T;
        ST(j).SZ_ELEV(i+1) = SZ_ELEV_ijz;
%         ST(j).OL_DEPTH(i+1) = OL_DEPTH_ij;
        ST(j).COMP_DATE(i+1) = T;
    end
end


for i = 1:length(ST)
    NAME = ST(i).NAME;
    STATION = INI.mapCompSelected(char(NAME));
%     STATION.COMP_DATE = ST(i).DATE;
    STATION.MSHE_SZ_ELEV = ST(i).SZ_ELEV;
%     STATION.MSHE_OL_DEPTH = ST(i).OL_DEPTH;
    STATION.MSHE_DATE = ST(i).COMP_DATE;
    STATION.TIMEVECTOR = ST(i).COMP_DATE';
    STATION.MSHE_UNIT_SZ_ELEV = char(TS.S.DFS.ItemInfo.Item(0).Quantity.UnitAbbreviation);
%     STATION.MSHE_UNIT_OL_DEPTH = char(TS.S.dfs2.ItemInfo.Item(0).Quantity.UnitAbbreviation) ;
    STATION.MSHE_TYPE_SZ_ELEV = char(TS.S.DFS.ItemInfo.Item(0).Quantity.ItemDescription);
%     STATION.MSHE_TYPE_OL_DEPTH = char(TS.S.dfs2.ItemInfo.Item(0).Quantity.ItemDescription);
    DN = ST(i).SZ_ELEV;
    DN(DN==TS.S.DELETE) = NaN;
    STATION.DCOMPUTED = DN';
    STATION.DATATYPE = STATION.MSHE_TYPE_SZ_ELEV;
    UNIT = STATION.MSHE_UNIT_SZ_ELEV;

    if strcmp(UNIT,'m')
        STATION.DCOMPUTED = STATION.DCOMPUTED/0.3048;
        STATION.UNIT = 'ft';
    end
    INI.mapCompSelected(char(NAME)) = STATION;
end

TS.S.DFS.Close
fprintf('\n      done' );

end

