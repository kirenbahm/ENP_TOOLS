function [V] = get_RMSE(TS)
if isempty(TS), V = NaN; return, end;

%V =     (sum(TS(:,4).^2)^0.5)/length(TS(:,1)); %revised
 V = sqrt(sum(TS(:,4).^2)/length(TS(:,1))); %rjf 121911 revised

end
