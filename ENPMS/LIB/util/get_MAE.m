function [V] = get_MAE(TS)
if isempty(TS), V = NaN; return, end;

V = sum(abs(TS(:,4)))/length(TS(:,1)); %ok

end
