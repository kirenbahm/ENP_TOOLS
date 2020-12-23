function ST = BC2D_create_raw_data_vector(ST)

% observed time vectors
obsTimeVec    = ST.T;

% create observed data vectors
obsDataVec    = ST.V; % this one will not be edited

% eliminate H values before initial and after the final date
obsDataVec = obsDataVec(obsTimeVec>=ST.t_i & obsTimeVec<=ST.t_e);

% find observed values are in the same vectors : extrapolated and obs
v = ismember(ST.dT,obsTimeVec);

%apply the observed data where avaialbe
ST.dHr((v>0)) = obsDataVec;

end
