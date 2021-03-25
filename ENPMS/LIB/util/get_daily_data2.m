function DATA_DAILY = get_daily_data(DINST,TINST,TIMEVECTOR)

%use only specified vector timeserie

DINST = DINST(TINST>=TIMEVECTOR(1));
TINST = TINST(TINST>=TIMEVECTOR(1));
DINST = DINST(TINST<=TIMEVECTOR(end));
TINST = TINST(TINST<=TIMEVECTOR(end));
DATA_DAILY = TIMEVECTOR;
DATA_DAILY(:) = NaN;

[y,m,d,h,mi,s] = datevec(TINST);
DATE_VEC = [y,m,d,h,mi,s];

DD_ARRAY = [y,m,d];DD_ARRAY = unique(DD_ARRAY,'rows','stable');

%extract values for the specified vector
n = size(DD_ARRAY, 1);
DRED.DD_WAVE(1:n) = NaN; % daily weighted average
% DRED.DD_AVE(1:n) = NaN; % daily  average
% DRED.DD_WSUM(1:n) = NaN; % daily weighted sumation
% DRED.DD_SUM(1:n) = NaN; % dailly  sumation

for i = 1:n
    yy = DD_ARRAY(i,1);
    mm = DD_ARRAY(i,2);
    dd = DD_ARRAY(i,3);
    I1 = find(DATE_VEC(:,1)==yy & DATE_VEC(:,2)==mm &DATE_VEC(:,3)==dd ); % select year
    t1 = TINST(I1); % selected time vector
    DT = diff(t1)*86400; % difference in seconds
    X = DINST(I1); % determine number of seconds per period
    % weighted average
%     DRED.DD_AVE(i) = mean(X); % simple average
%     DRED.DD_SUM(i) = sum(X); % sumation for rainfall, ET, PET
    if isempty(DT)
        DRED.DD_WAVE(i) = X;
%         DRED.DD_WSUM(i) = 86400*X;
    else
        DRED.DD_WAVE(i) = dot(X(1:end-1),DT)/sum(DT); % weighted average
%         DRED.DD_WSUM(i) = sum(times(X(1:end-1),DT)); %X*DT sumation for Flow
    end
end

IND = ismember(TIMEVECTOR,datenum(DD_ARRAY));

DATA_DAILY(IND) = DRED.DD_WAVE';
% check size of arrays
end
