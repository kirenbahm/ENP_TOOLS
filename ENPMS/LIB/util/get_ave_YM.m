function [DS] = get_ave_YM(d,x)
%get_ave_discharges() Computes yearly and monthly averages and totals 
%   Takes arguments: d - DATE vector, x - DATA vector
%   Returns a DS structure with averages and totals
%   NaN are returned for averages and totals if x has only NaN's
% DS.VEC_M_AVE -> size = 12 months
% DS.VEC_M_TOT -> size = 12 months
% DS.ACCUMULATED -> size = 1 value
% DS.VEC_Y_AVE -> size = number of years
% DS.VEC_YY_AVE -> size = 1 value (Average of all yearly averages)
% DS.VEC_Y_TOT -> size = number of years
% DS.VEC_YM_AVE -> size = colxrow = number of years x 12 months
% DS.VEC_YM_TOT -> size = colxrow = number of years x 12 monhts

[y,m] = datevec(d);
DS.VEC_M_AVE = NaN(12,1); % Monthly average
DS.VEC_M_TOT = NaN(12,1); % Monthly totals

DS.MEAN = nanmean(x);
DS.ACCUMULATED = NaN;
DS.VEC_YYY_AVE = NaN;
mycount = (sum(~isnan(x)))/365; % number of years
if (~isnan(DS.MEAN)); DS.ACCUMULATED = nansum(x);end % Acumulated total for the entire period
if (~isnan(DS.MEAN)); DS.VEC_YYY_AVE = DS.ACCUMULATED/mycount;end % Acumulated total for the entire period

% note that if matlab data does not have a full 12 months, this will fail
% and boot you out of the script. should fix this ... (keb 2016-03-15)
for i = 1:12
    DS.VEC_M_AVE(i) = nanmean(x(m == i));
    if (~isnan(DS.MEAN)); DS.VEC_M_TOT(i) = nansum(x(m == i));end %otherwise it's 0
end

yy = unique(y); % Years
ny = length(yy); % number of years
mm = unique(m);
DS.YEARS = yy;
DS.MONTHS = mm;

DS.VEC_Y_AVE = NaN(ny,1); % Annual average array
DS.VEC_Y_TOT = NaN(ny,1); % Annual totals array
DS.VEC_YY_AVE = NaN;

for i = 1:ny
    DS.VEC_Y_AVE(i) = nanmean(x(y == yy(i)));
    if (~isnan(DS.MEAN)); DS.VEC_Y_TOT(i) = nansum(x(y == yy(i)));end % otherwise it's 0
end

DS.VEC_YM_AVE = NaN(ny,12); % Annual and monthly average array
DS.VEC_YM_TOT = NaN(ny,12); % Annual and monthly totals array
DS.VEC_YY_AVE = mean(DS.VEC_Y_AVE(:));
for i = 1:ny
    for j = 1:12
        DS.VEC_YM_AVE(i,j) = nanmean(x((y == yy(i)) & (m == j))); %Y and M ave
        if (~isnan(DS.MEAN)); DS.VEC_YM_TOT(i,j) = nansum(x((y == yy(i)) & (m == j))); end %otherwise it's 0
    end
end

end

