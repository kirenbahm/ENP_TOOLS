function [DS] = get_ave_HR_NONEQDIST(date_v,x)
%get_ave_discharges() Computes yearly and monthly averages and totals 
%   Takes arguments: date_v - DATE vector, x - DATA vector
%   Returns a DS structure with wighted averages and cumlatives YY,MM,DD,HH
%   NaN are returned for averages and totals if x has only NaN's

[y,m,d,h,mi,s] = datevec(date_v);
DATE_VEC = [y,m,d,h,mi,s];

%average annual takes  y
%average monthly takes y,m
%average daily takes y,m,d
%average hourly takes y,m,d,h

YY_ARRAY = [y];YY_ARRAY = unique(YY_ARRAY,'rows','stable');
MM_ARRAY = [y,m];MM_ARRAY = unique(MM_ARRAY,'rows','stable');
DD_ARRAY = [y,m,d];DD_ARRAY = unique(DD_ARRAY,'rows','stable');
HR_ARRAY = [y, m, d, h];HR_ARRAY = unique(HR_ARRAY,'rows','stable');

%compute average annual:
n = length(YY_ARRAY);
DS.YY_WAVE(1:n) = NaN; % annual weighted average
DS.YY_AVE(1:n) = NaN; % annual  average
DS.YY_WSUM(1:n) = NaN; % annual weighted sumation
DS.YY_SUM(1:n) = NaN; % annual  sumation

for i = 1:n
    yy = YY_ARRAY(i);
    I1 = find(DATE_VEC(:,1)==yy); % select year
    t1 = date_v(I1); % selected time vector
    DT = diff(t1)*86400; % difference in seconds
    X = x(I1); % determine number of seconds per period
    % weighted average
    if isempty(DT)
        DS.HR_WAVE(i) = DS.HR_AVE(i);
        DS.HR_WSUM(i) = yeardays(yy)*86400*X;
    else
        DS.HR_WAVE(i) = dot(X(1:end-1),DT)/sum(DT); % weighted average
        DS.HR_WSUM(i) = sum(times(X(1:end-1),DT)); %X*DT sumation for Flow
    end
end

%compute average monthly:
n = length(MM_ARRAY);
DS.MM_WAVE(1:n) = NaN; % annual weighted average
DS.MM_AVE(1:n) = NaN; % annual  average
DS.MM_WSUM(1:n) = NaN; % annual weighted sumation
DS.MM_SUM(1:n) = NaN; % annual  sumation

for i = 1:n
    yy = MM_ARRAY(i,1);
    mm = MM_ARRAY(i,2);
    I1 = find(DATE_VEC(:,1)==yy & DATE_VEC(:,2)==mm ); % select year
    t1 = date_v(I1); % selected time vector
    DT = diff(t1)*86400; % difference in seconds
    X = x(I1); % determine number of seconds per period
    % weighted average
    if isempty(DT)
        DS.HR_WAVE(i) = DS.HR_AVE(i);
        DS.HR_WSUM(i) = eomday(yy,mm)*86400*X; 
    else
        DS.HR_WAVE(i) = dot(X(1:end-1),DT)/sum(DT); % weighted average
        DS.HR_WSUM(i) = sum(times(X(1:end-1),DT)); %X*DT sumation for Flow
    end
end
 
%compute average daily:
n = length(DD_ARRAY);
DS.DD_WAVE(1:n) = NaN; % annual weighted average
DS.DD_AVE(1:n) = NaN; % annual  average
DS.DD_WSUM(1:n) = NaN; % annual weighted sumation
DS.DD_SUM(1:n) = NaN; % annual  sumation

for i = 1:n
    yy = DD_ARRAY(i,1);
    mm = DD_ARRAY(i,2);
    dd = DD_ARRAY(i,3);
    I1 = find(DATE_VEC(:,1)==yy & DATE_VEC(:,2)==mm &DATE_VEC(:,3)==dd ); % select year
    t1 = date_v(I1); % selected time vector
    DT = diff(t1)*86400; % difference in seconds
    X = x(I1); % determine number of seconds per period
    % weighted average
    if isempty(DT)
        DS.HR_WAVE(i) = DS.HR_AVE(i);
        DS.HR_WSUM(i) = 86400*X;
    else
        DS.HR_WAVE(i) = dot(X(1:end-1),DT)/sum(DT); % weighted average
        DS.HR_WSUM(i) = sum(times(X(1:end-1),DT)); %X*DT sumation for Flow
    end
end

%compute  hourly:
n = length(HR_ARRAY);
DS.HR_WAVE(1:n) = NaN; % annual weighted average
DS.HR_AVE(1:n) = NaN; % annual  average
DS.HR_WSUM(1:n) = NaN; % annual weighted sumation
DS.HR_SUM(1:n) = NaN; % annual  sumation

for i = 1:n
    yy = HR_ARRAY(i,1);
    mm = HR_ARRAY(i,2);
    dd = HR_ARRAY(i,3);
    hh = HR_ARRAY(i,4);
    I1 = find(DATE_VEC(:,1)==yy & ...
        DATE_VEC(:,2)==mm & ...
        DATE_VEC(:,3)==dd & ...
        DATE_VEC(:,4)==hh); % select year
    t1 = date_v(I1); % selected time vector
    DT = diff(t1)*86400; % difference in seconds
    X = x(I1); % determine number of seconds per period
    % weighted average
    DS.HR_AVE(i) = mean(X); % simple average
    DS.HR_SUM(i) = sum(X); % sumation for rainfall, ET, PET
    if isempty(DT)
        DS.HR_WAVE(i) = DS.HR_AVE(i);
        DS.HR_WSUM(i) = 60*X;
    else
        DS.HR_WAVE(i) = dot(X(1:end-1),DT)/sum(DT); % weighted average
        DS.HR_WSUM(i) = sum(times(X(1:end-1),DT)); %X*DT sumation for Flow
    end
end


V = x;


end

