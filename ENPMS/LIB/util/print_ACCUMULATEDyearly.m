function [ output_args ] = print_ACCUMULATEDyearly(INI,P)
%print_ACCUMULATEDyearly prints annual discharges in kaf
%   Detailed explanation goes here

FN = [INI.ANALYSIS_DIR_TAG '/DS_YEARLY_AVE.txt']
FID = fopen(FN,'w');

%print header
fprintf(FID,'Average yearly discharges in kilo acre feet (kaf)\n');

B = all(P.VEC_YYY_AVE);
M = P.VEC_YYY_AVE(:,B==1);
S = P.SRC(B==1);

%print column header
fprintf(FID,'%20s','Station');
n = length(S);

for i = 1:n
    fprintf(FID,'\t%s', char(S(i)));
end

fprintf(FID,'\n');

[ni nj] = size(M);

for i = 1:ni
    fprintf(FID,'%20s', char(P.NAME(i)));
    for j = 1:nj
        fprintf(FID,'\t%8.2f', M(i,j));
    end
    fprintf(FID,'\n');
end

fclose(FID);

end

%printf(fidTXT,'%10s %20s %8d %8.2f %8.2f 
% %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f\n',char(N(i)),char(D),NDATA(i,:));