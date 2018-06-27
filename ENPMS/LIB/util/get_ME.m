function [V] = get_ME (TS)
if isempty(TS), V = NaN; return, end;

V = sum(TS(:,4))/length(TS(:,1)); %ok

end
