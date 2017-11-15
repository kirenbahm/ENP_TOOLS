function [ output_args ] = print_M_AVE(MAP_ALL_DATA,INI,STATIONS_LIST)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

FN = [INI.ANALYSIS_DIR_TAG '/DS_Y_AVE.txt']
FID = fopen(FN,'w');

%print header
fprintf(FID,'Average annual\n');

sz = length(INI.MODEL_ALL_RUNS);
P.SRC(1:sz) = INI.MODEL_RUN_DESC(1:sz);
P.SRC(sz+1) = {'Observed'}; % this is in the last column

%pring column header
% fprintf(FID,'%20s','Station');
% n = length(P.SRC);
% for i = 1:n
%     fprintf(FID,'\t%s', char(P.SRC(i)));
% end
% fprintf(FID,'\n');

i = 1;
for M = STATIONS_LIST
    try
        STATION = MAP_ALL_DATA(char(M));  %get a tmp structure, modify values
        % summarize discharges
        %         if strcmp(STATION.DFSTYPE,'Discharge')
        P.NAME{i} = STATION.NAME;
        fprintf(FID,'\n%s\n', char(STATION.NAME));
        for k = 1:sz+1 % observed is in column sz+1
            fprintf(FID,'%s\t', char(P.SRC(k)));
            MM = size(STATION.QYM(k).VEC_Y_AVE);
            for m = 1:MM(1)
                p = STATION.QYM(k).VEC_Y_AVE(m);
                fprintf(FID,'\t%8.2f', p);
            end
            fprintf(FID,'\n');
        end
        i = i + 1;
        %         end
    catch
        fprintf('...%d\t Exception for %s in print_M_AVE()\n', i, char(M));
    end
end


% [ni nj] = size(P.ACCUMULATED);
% for i = 1:ni
%     fprintf(FID,'%20s', char(P.NAME(i)));
%     for j = 1:nj
%         fprintf(FID,'\t%8.2f', P.ACCUMULATED(i,j));
%     end
%     fprintf(FID,'\n');
% end

fclose(FID);

end

%printf(fidTXT,'%10s %20s %8d %8.2f %8.2f 
% %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f\n',char(N(i)),char(D),NDATA(i,:));