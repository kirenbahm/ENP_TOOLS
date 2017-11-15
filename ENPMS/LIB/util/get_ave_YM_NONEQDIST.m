function [DS] = get_ave_YM_NONEQDIST(date_v,x)
%get_ave_discharges() Computes yearly and monthly averages and totals 
%   Takes arguments: d - DATE vector, x - DATA vector
%   Returns a DS structure with averages and totals
%   NaN are returned for averages and totals if x has only NaN's
% DS.VEC_M_AVE -> size = 12 months in cfs average
% DS.VEC_M_TOT -> size = 12 months average in acft for each month 
% DS.ACCUMULATED -> size = 1 value
% DS.VEC_Y_AVE -> size = number of years in cfs average
% DS.VEC_Y_TOT -> size = number of years flow in acft for the entire year
% DS.VEC_YM_AVE -> size = colxrow = number of years x 12 months
% DS.VEC_YM_TOT -> size = colxrow = number of years x 12 monhts

% determine number of seconds per period
V = x;
IND = isnan(V);
V(IND) = [];
T = date_v;
T(IND) = [];
T_NAN = T; 
DS.T_NAN = T_NAN;
TV_SEC = T * 86400;
TV_SEC_DIFF = diff(TV_SEC);
TV_SEC_DIFF = [TV_SEC_DIFF; TV_SEC_DIFF(end)] ;
DS.Q_PERIOD = times(V,TV_SEC_DIFF); % in cubic feet, store in structure
DS.Q_SUM = cumsum(DS.Q_PERIOD)/(43560000); % in 1000 ac-ft, store

[y,m] = datevec(date_v);
DS.VEC_M_AVE = NaN(12,1); % Monthly average
DS.VEC_M_TOT = NaN(12,1); % Monthly totals

DS.MEAN = nanmean(x);

DS.ACCUMULATED = NaN;
if (~isnan(DS.MEAN)); 
    DS.ACCUMULATED = nansum(x);
end % Acumulated total for the entire period

if (~isnan(DS.MEAN)); 
    DS.ACCUMULATED = nansum(DS.Q_PERIOD)/(43560000);
end % Acumulated total for the entire period

% note that if matlab data does not have a full 12 months, this will fail
% and boot you out of the script. should fix this ... (keb 2016-03-15)
for i = 1:12
    DS.VEC_M_AVE(i) = nanmean(x(m == i));
    if (~isnan(DS.MEAN)); 
        %DS.VEC_M_TOT(i) = nansum(x(m == i));
        DS.VEC_M_TOT(i) = nanmean(DS.Q_PERIOD(m == i))/(43560000);
    end %otherwise it's 0
end

yy = unique(y); % Years
ny = length(yy); % number of years
mm = unique(m);
DS.YEARS = yy;
DS.MONTHS = mm;

DS.VEC_Y_AVE = NaN(ny,1); % Annual average array
DS.VEC_Y_TOT = NaN(ny,1); % Annual totals array

for i = 1:ny
    DS.VEC_Y_AVE(i) = nanmean(x(y == yy(i)));
    if (~isnan(DS.MEAN)); 
        DS.VEC_Y_TOT(i) = nansum(DS.Q_PERIOD(y == yy(i)))/(43560000);
    end % otherwise it's 0
end

DS.VEC_YM_AVE = NaN(ny,12); % Annual and monthly average array
DS.VEC_YM_TOT = NaN(ny,12); % Annual and monthly totals array
for i = 1:ny
    for j = 1:12
        DS.VEC_YM_AVE(i,j) = nanmean(x((y == yy(i)) & (m == j))); %Y and M ave
        if (~isnan(DS.MEAN)); 
            DS.VEC_YM_TOT(i,j) = nansum(DS.Q_PERIOD((y == yy(i)) & (m == j)))/(43560000); 
        end %otherwise it's 0
    end
end

end

