function [PE] =get_PE(p,M);
PE = NaN;
I = find(M(:,8)>p,1);
if ~isempty(I), PE = M(I,7); end;

end

