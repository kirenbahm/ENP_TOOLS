function DFS0 = DFS0_cumulative_flow(DFS0)

V = DFS0.V;
IND = isnan(V);
V(IND) = [];
T = DFS0.T;
T(IND) = [];

% T_NAN = T; % store in the structure
% TV_SEC = T * 86400;
% TV_SEC_DIFF = diff(TV_SEC);
% TV_SEC_DIFF = [TV_SEC_DIFF; TV_SEC_DIFF(end)] ;
% DFS0.Q_PERIOD = times(V,TV_SEC_DIFF); % in cubic feet, store in structure
% DFS0.Q_SUM = cumsum(DFS0.Q_PERIOD)/(43560000); % in 1000 ac-ft, store

DFS0.DS = get_ave_YM_NONEQDIST(T,V);

end

