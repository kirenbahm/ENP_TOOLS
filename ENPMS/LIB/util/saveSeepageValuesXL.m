function saveSeepageValuesXL(VU_DFS3,INI,TV_STR)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%waterBalanceXLHeader(H,FILE_XL,DESC)
%H = [H, 'TOTAL'];
i = 0;

if ~exist(INI.fileXL, 'file')
    fprintf('%s does not exist - will create new file...', INI.fileXL);
end
for D = INI.MODEL_ALL_RUNS
    i = i+1;
    %RUN = INI.RUN
    H = VU_DFS3(:,:,i);
    xlswrite(char(INI.fileXL),cellstr(TV_STR),char(D),'A3'); % gives warning if xls doesn't already exist
    xlswrite(char(INI.fileXL),H,char(D),'B3');
end
% A=size(ARRAY_XL);
% D(:,:)=reshape(ARRAY_XL(:,A(2),:),A(1),A(3)); % write observed, last A(2) index
% TOTAL = sum(D,2);
% DOBS = [D TOTAL];
% SH = [char(DESC) '_OBS']
% xlswrite(char(FILE_XL),H,SH,'A1');
% xlswrite(char(FILE_XL),DOBS,SH,'A2');
% for i = 1:A(2)-1
%     R = RUNS(i);
%     SH = [char(DESC) '_' char(R)];
%     D(:,:)=reshape(ARRAY_XL(:,i,:),A(1),A(3)); %write computed
%     TOTAL = sum(D,2);
%     D = [D TOTAL];
%     xlswrite(char(FILE_XL),H,SH,'A1');
%     xlswrite(char(FILE_XL),D,SH,'A2');
% end

end

