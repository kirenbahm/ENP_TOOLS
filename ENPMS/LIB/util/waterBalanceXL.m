function waterBalanceXL(RUNS,ARRAY_XL,FILE_XL,DESC,H)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%waterBalanceXLHeader(H,FILE_XL,DESC)
%H = [H, 'TOTAL'];
A=size(ARRAY_XL);
D(:,:)=reshape(ARRAY_XL(:,A(2),:),A(1),A(3)); % write observed, last A(2) index
TOTAL = sum(D,2);
DOBS = [D TOTAL];
SH = [char(DESC) '_OBS']
xlswrite(char(FILE_XL),H,SH,'A1');
xlswrite(char(FILE_XL),DOBS,SH,'A2');
for i = 1:A(2)-1
    R = RUNS(i);
    SH = [char(DESC) '_' char(R)];
    D(:,:)=reshape(ARRAY_XL(:,i,:),A(1),A(3)); %write computed
    TOTAL = sum(D,2);
    D = [D TOTAL];
    xlswrite(char(FILE_XL),H,SH,'A1');
    xlswrite(char(FILE_XL),D,SH,'A2');
end

end

