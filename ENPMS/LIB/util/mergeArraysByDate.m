function STATION = mergeArraysByDate(i,STATION,T,D)
% this function is not used, but can be used to merge tieseries with
% diferent timevectors
T0 = STATION.TIMEVECTOR;
Tnew = unique([T0; T]); % concatenate the timevectors and find the unique
STATION.TIMEVECTOR = Tnew; % Assign the new timevector

% merge timeseries
if i == 1
    STATION.TIMESERIES = D;
    return
end

D0 = STATION.TIMESERIES;
n = length(Tnew);
Dnew = NaN(n,i);
A(1:n) = NaN;

for ii = 1:i
    ind = ismember(Tnew,T0);
    if ii < i
        DD = D0(:,ii);
        Dnew(ind,ii) = DD;
    else 
    ind = ismember(Tnew,T);
        Dnew(ind,ii) = D;        
    end
end

STATION.TIMESERIES = Dnew; % Assign the new timeseries

end

