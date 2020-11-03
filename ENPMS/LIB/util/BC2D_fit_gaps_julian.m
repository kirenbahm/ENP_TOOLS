function ST = BC2D_fit_gaps_julian(ST)

% temporary vectors for data and time o is for observed
obsDataVec = ST.V;
obsTimeVec = ST.T; % observed time vector

% convert the obs time vector to a datetime vector to determine dayofyear
obsDateVec = datevec(obsTimeVec);
obsDateTimeVec = datetime(obsDateVec);
obsDayOfYearVec = day(obsDateTimeVec,'dayofyear');
uniqueDayOfYearVec = unique(obsDayOfYearVec);

% convert the extended timevector to a datetime vector to determine
% dayofyear
DI_T = day(datetime(datevec(ST.dT)),'dayofyear');

% iterate over each day of the year and determine the mean for that
% particular day
for uniqueDay = uniqueDayOfYearVec'
    iii = find(obsDayOfYearVec==uniqueDay);
    iv = find(DI_T==uniqueDay);
    ST.dHd(iv) = mean(obsDataVec(iii))';
end

% eliminate H values before initial and after the final date
obsDataVec = obsDataVec(obsTimeVec>=ST.t_i & obsTimeVec<=ST.t_e);

% find observed values are in the same vectors : extrapolated and obs
v = ismember(ST.dT,obsTimeVec);

%apply the observed data where avaialbe
ST.dHd((v>0)) = obsDataVec;


end
