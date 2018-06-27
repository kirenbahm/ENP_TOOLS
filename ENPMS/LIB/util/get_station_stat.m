function [STATION] = get_station_stat(STATION)

%{
FUNCTION DESCRIPTION:
BUGS:
COMMENTS:
----------------------------------------
REVISION HISTORY:

v0 revisions (rjf 12/2011):
-call get_RMSEv1 (changed the formula)

%}

K = keys(STATION.TS_NAN);

for k = K
    TS = STATION.TS_NAN(char(k));
    COUNT = get_COUNT(TS.TS);
    TS.COUNT = COUNT;
    if (COUNT <= 3)
        ME = NaN;
        MAE = NaN;
        RMSE = NaN;
        STD = NaN;
        NS = NaN;
        COVAR = NaN;
        COR = NaN;
        PEV = NaN;
        TS_HEADER = '';
    else
        ME = get_ME(TS.TS);
        MAE = get_MAE(TS.TS);
        RMSE = get_RMSE(TS.TS);
        STD = get_STDres(TS.TS,ME);
        NS = get_NS(TS.TS);
        COVAR = get_COVAR(TS.TS,COUNT);
        COR = get_COR(TS.TS);
        PEV = get_PEV(TS.TS,COUNT);
        [TS.TS TS_HEADER] = calculate_exceedance(TS.TS);
    end
    
    TS.ME = ME;
    TS.MAE = MAE;
    TS.RMSE = RMSE;
    TS.STD = STD;
    TS.NS = NS;
    TS.COVAR = COVAR;
    TS.COR = COR;
    TS.PEV = PEV;
    TS.TS_HEADER = TS_HEADER;
    STATION.TS_NAN(char(k)) = TS;
end


end
