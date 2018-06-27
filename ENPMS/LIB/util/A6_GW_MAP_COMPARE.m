function [INI] = A6_GW_MAP_COMPARE(INI)
fprintf('\n\n Beginning A6_GW_MAP_COMPARE(): %s \n\n',datestr(now));

% this function will read the dates from an excel file and will provide
% differences in a excel file which can be imported in ARC MAP and used fro
% plot in GIS
i = 0;

for D = INI.MODEL_ALL_RUNS % iterate over selected model runs
    i = i + 1;
    MODEL_RESULT_DIR = INI.MODEL_FULLPATH{i};
    FILE_3DSZQ  = [MODEL_RESULT_DIR '/' char(D) '_3DSZflow.dfs3'];
    FILE_3DSZ  = [MODEL_RESULT_DIR '/' char(D) '_3DSZ.dfs3'];
    if exist(FILE_3DSZ, 'file') == 2
        DFS3(i) = inputDFS3(FILE_3DSZ);
    end
end

if ~exist('DFS3')
    fprintf('\n Warning: Check for existing _3DSZ.dfs3 files: %s \n',datestr(now))
    fprintf('\n Warning: Maps for groundwater differences not computed \n')
    return
end
% this needs to be converted to use excel file, either a default file or a
% file which is provided in the main matlab script
a = datenum([1999 1 5 0 0 0]);%a_str = datestr(a,'yyyy-mm-dd');
b = datenum([1999 1 10 0 0 0]);
c = datenum([1999 1 15 0 0 0]);
d = datenum([1999 1 20 0 0 0]);
%e = datenum([2009 12 1 0 0 0]);

create_GW_DIFF(INI,a,DFS3);
create_GW_DIFF(INI,b,DFS3);
create_GW_DIFF(INI,c,DFS3);
create_GW_DIFF(INI,d,DFS3);
%create_GW_DIFF(INI,e,DFS3);

end

function create_GW_DIFF(INI,t,DFS3);

DATA0 = DFS3(1).MAPDATA(t);
LR = {'L1','L2','L3'};

for i = 2:length(DFS3)
    DATA = DFS3(i).MAPDATA(t);
    for k = 1:length(DATA0(1,1,:))
        DATA_DIFF = DATA0(:,:,k) - DATA(:,:,k);
        DT = DATA_DIFF';
        DT(DT==0)=-1e-035;
        FDT = flipdim(DT,1);
        LAYER = LR(k);
        F = [INI.ANALYSIS_DIR_TAG '/DIFF_' char(datestr(t,'yyyy-mm-dd')) '_' char(LAYER) '_' char(INI.MODEL_ALL_RUNS(i)) '.xlsx'];
        xlswrite(F,FDT);
    end
end

end

