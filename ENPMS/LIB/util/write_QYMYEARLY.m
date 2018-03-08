function [ output_args ] = write_QYMYEARLY(MAP_ALL_DATA,INI,STATIONS_LIST)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% DS.VEC_M_AVE -> size = 12 months
% DS.VEC_M_TOT -> size = 12 months
% DS.ACCUMULATED -> size = 1 value
% DS.VEC_Y_AVE -> size = number of years
% DS.VEC_Y_TOT -> size = number of years
% DS.VEC_YM_AVE -> size = colxrow = number of years x 12 months
% DS.VEC_YM_TOT -> size = colxrow = number of years x 12 monhts

fprintf('\n\n--Writing QYM yearly:');

%extract only discharges into arrays for printing (instead of printing one
%line per iteration
CFS_KAFDY = 0.001982;

sz = length(INI.MODEL_ALL_RUNS);
P.SRC(1:sz) = INI.MODEL_RUN_DESC(1:sz);
P.SRC(sz+1) = {'Observed'}; % this is in the last column

% extract accumulated
i = 0;
for M = STATIONS_LIST
    try
        STATION = MAP_ALL_DATA(char(M));  %get a tmp structure, modify values
        % summarize discharges
        if strcmp(STATION.DFSTYPE,'Discharge')
            i = i + 1;
            P.NAME{i} = STATION.NAME;
            if INI.INCLUDE_OBSERVED & INI.INCLUDE_COMPUTED
                m = [1:sz+1]; % observed is in column sz+1
            end 
            if INI.INCLUDE_OBSERVED & ~INI.INCLUDE_COMPUTED 
                m = [sz+1]; 
            end 
            if ~INI.INCLUDE_OBSERVED & INI.INCLUDE_COMPUTED
                m = [1:sz];
            end            
            for k = m % observed is in column sz+1
                P.VEC_YYY_AVE(i,k) = STATION.QYM(k).VEC_YYY_AVE*CFS_KAFDY;
            end
        end
    catch
        fprintf('\n\t Warning: Cannot find %s in MAP_ALL_DATA container', char(M));
    end
end

try
    print_ACCUMULATEDyearly(INI,P);
catch
    fprintf('\n\t Calculation of P.VEC_YY_AVE failed');
end


end

