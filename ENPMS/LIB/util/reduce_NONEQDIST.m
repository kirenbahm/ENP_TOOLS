function [DRED] = reduce_NONEQDIST(date_v,x,R)
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

DRED.YY_ARRAY = [YY_ARRAY zeros([length(YY_ARRAY) 5])];
DRED.MM_ARRAY = [MM_ARRAY zeros([length(MM_ARRAY) 4])]; 
DRED.DD_ARRAY = [DD_ARRAY zeros([length(DD_ARRAY) 3])];
DRED.HR_ARRAY = [HR_ARRAY zeros([length(HR_ARRAY) 2])];

%compute average annual:
n = length(YY_ARRAY);
DRED.YY_WAVE(1:n) = NaN; % annual weighted average
DRED.YY_AVE(1:n) = NaN; % annual  average
DRED.YY_WSUM(1:n) = NaN; % annual weighted sumation
DRED.YY_SUM(1:n) = NaN; % annual  sumation

for i = 1:n
    yy = YY_ARRAY(i);
    I1 = find(DATE_VEC(:,1)==yy); % select year
    if(I1(end) ~= size(date_v, 1)) % index inserted due to last time step missing
        I1(end + 1, 1) = I1(end) + 1; 
    end
    t1 = date_v(I1); % selected time vector
    DT = diff(t1)*86400; % difference in seconds
    numdays = calc_DaysInYear(yy);
    if sum(DT) > numdays * 86400 % Limit to 1 year in case missing data between last timestep in year and next available timestep
       DT(end) =  DT(end) - (sum(DT) - (numdays * 86400));
    end
    X = x(I1); % determine number of seconds per period
    DRED.YY_AVE(i) = mean(X); % simple average
    DRED.YY_SUM(i) = sum(X); % sumation for rainfall, ET, PET
    % weighted average
    if isempty(DT)
        DRED.YY_WAVE(i) = X;
        days = calc_DaysInYear(yy);
        DRED.YY_WSUM(i) = days*86400*X;
        clear days
%        DRED.YY_WSUM(i) = yeardays(yy)*86400*X;
    else
        DRED.YY_WAVE(i) = dot(X(1:end-1),DT)/sum(DT); % weighted average
        DRED.YY_WSUM(i) = sum(times(X(1:end-1),DT)); %X*DT sumation for Flow
    end
end

%compute average monthly:
n = length(MM_ARRAY);
DRED.MM_WAVE(1:n) = NaN; % annual weighted average
DRED.MM_AVE(1:n) = NaN; % annual  average
DRED.MM_WSUM(1:n) = NaN; % annual weighted sumation
DRED.MM_SUM(1:n) = NaN; % annual  sumation

for i = 1:n
    yy = MM_ARRAY(i,1);
    mm = MM_ARRAY(i,2);
    numdays = 0;
    if mm == 1 || mm == 3 || mm == 5 || mm == 7 || mm == 8 || mm == 10 || mm == 12
        numdays = 31;
    elseif mm == 4 || mm == 6 || mm == 9 || mm == 11
        numdays = 30;
    elseif mm ==2 && calc_LeapYear(yy)
        numdays = 29;
    elseif mm == 2 && ~calc_LeapYear(yy)
        numdays = 28;
    end
    I1 = find(DATE_VEC(:,1)==yy & DATE_VEC(:,2)==mm ); % select year
    if(I1(end) ~= size(date_v, 1)) % index inserted due to last time step missing
        I1(end + 1, 1) = I1(end) + 1; 
    end
    t1 = date_v(I1); % selected time vector
    DT = diff(t1)*86400; % difference in seconds
    if sum(DT) > numdays * 86400 % Limit to 1 month in case missing data between last timestep in month and next available timestep
       DT(end) =  DT(end) - (sum(DT) - (numdays * 86400));
    end
    X = x(I1); % determine number of seconds per period
    % weighted average
    DRED.MM_AVE(i) = mean(X); % simple average
    DRED.MM_SUM(i) = sum(X); % sumation for rainfall, ET, PET
    if isempty(DT)
        DRED.MM_WAVE(i) = X;
        DRED.MM_WSUM(i) = eomday(yy,mm)*86400*X; 
    else
        DRED.MM_WAVE(i) = dot(X(1:end-1),DT)/sum(DT); % weighted average
        DRED.MM_WSUM(i) = sum(times(X(1:end-1),DT)); %X*DT sumation for Flow
    end
end
 
%compute average daily:
n = length(DD_ARRAY);
DRED.DD_WAVE(1:n) = NaN; % daily weighted average
DRED.DD_AVE(1:n) = NaN; % daily  average
DRED.DD_WSUM(1:n) = NaN; % daily weighted sumation
DRED.DD_SUM(1:n) = NaN; % dailly  sumation

for i = 1:n
    yy = DD_ARRAY(i,1);
    mm = DD_ARRAY(i,2);
    dd = DD_ARRAY(i,3);
    I1 = find(DATE_VEC(:,1)==yy & DATE_VEC(:,2)==mm &DATE_VEC(:,3)==dd ); % select year
    if(I1(end) ~= size(date_v, 1)) % index inserted due to last time step missing
        I1(end + 1, 1) = I1(end) + 1; 
    end
    t1 = date_v(I1); % selected time vector
    DT = diff(t1)*86400; % difference in seconds
    if sum(DT) > 86400 % Limit to 1 day in case missing data between last timestep in day and next available timestep
       DT(end) =  DT(end) - (sum(DT) - 86400);
    end
    X = x(I1); % determine number of seconds per period
    % weighted average
    DRED.DD_AVE(i) = mean(X); % simple average
    DRED.DD_SUM(i) = sum(X); % sumation for rainfall, ET, PET
    if isempty(DT)
        DRED.DD_WAVE(i) = X;
        DRED.DD_WSUM(i) = 86400*X;
    else
        DRED.DD_WAVE(i) = dot(X(1:end-1),DT)/sum(DT); % weighted average
        DRED.DD_WSUM(i) = sum(times(X(1:end-1),DT)); %X*DT sumation for Flow
    end
end
if strcmp(R,'d')
    return % no need to compute hourly
end
%compute  hourly:
n = length(HR_ARRAY);
DRED.HR_WAVE(1:n) = NaN; % annual weighted average
DRED.HR_AVE(1:n) = NaN; % annual  average
DRED.HR_WSUM(1:n) = NaN; % annual weighted sumation
DRED.HR_SUM(1:n) = NaN; % annual  sumation

for i = 1:n
    yy = HR_ARRAY(i,1);
    mm = HR_ARRAY(i,2);
    dd = HR_ARRAY(i,3);
    hh = HR_ARRAY(i,4);
    I1 = find(DATE_VEC(:,1)==yy & ...
        DATE_VEC(:,2)==mm & ...
        DATE_VEC(:,3)==dd & ...
        DATE_VEC(:,4)==hh); % select year
    if(I1(end) ~= size(date_v, 1)) % index inserted due to last time step missing
        I1(end + 1, 1) = I1(end) + 1; 
    end
    t1 = date_v(I1); % selected time vector
    DT = diff(t1)*86400; % difference in seconds
    if sum(DT) > 3600 % Limit to 1 hour in case missing data between last timestep in hour and next available timestep
       DT(end) =  DT(end) - (sum(DT) - 3600);
    end
    X = x(I1); % determine number of seconds per period
    % weighted average
    DRED.HR_AVE(i) = mean(X); % simple average
    DRED.HR_SUM(i) = sum(X); % sumation for rainfall, ET, PET
    if isempty(DT)
        DRED.HR_WAVE(i) = X;
        DRED.HR_WSUM(i) = 60*X;
    else
        DRED.HR_WAVE(i) = dot(X(1:end-1),DT)/sum(DT); % weighted average
        DRED.HR_WSUM(i) = sum(times(X(1:end-1),DT)); %X*DT sumation for Flow
    end
end


%V = x;


end

