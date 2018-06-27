function [] = A7_SEEPAGE_MAP(INI)


%this function can be used as a template of reading seepage values using
%codes from dfs2 file.
% open seepage codes

SEEPAGEMAP = readSEEPAGEMAP(INI.MAPF);
VUNIQUE = unique(SEEPAGEMAP)';
v = size(VUNIQUE);
VUNIQUE_V = v(2);
VUNIQUE_T = INI.NumPostProcDays;
VUNIQUE_N = INI.NSIMULATIONS;
VU_DFS3(1:VUNIQUE_T,1:VUNIQUE_V-1,1:VUNIQUE_N) = NaN;

i = 0;

% the seepage map will not work if there the data are less than the
% specified time period
for D = INI.MODEL_ALL_RUNS % iterate over selected model runs
    i = i + 1;
    MODEL_RESULT_DIR = INI.MODEL_FULLPATH{i};
    FILE_3DSZQ  = [MODEL_RESULT_DIR '/' char(D) '_3DSZflow.dfs3'];
    FILE_3DSZ  = [MODEL_RESULT_DIR '/' char(D) '_3DSZ.dfs3'];
    A=readSelectedCellsDFS3(D,FILE_3DSZQ,SEEPAGEMAP,INI);
    VU_DFS3(:,:,i) = A;
end

TV_STR = getTimeVectorStr(INI);

saveSeepageValuesXL(VU_DFS3,INI,INI.fileXL,TV_STR);

end

function [DS] = getTimeVectorStr(INI)
i1 = datenum(INI.ANALYZE_DATE_I);
i2 = datenum(INI.ANALYZE_DATE_F);
DV = [i1:i2];
DS = datestr(DV);

end


function extract_DATA(INI,DFS3);

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
        F = ['DIFF_' char(datestr(t,'yyyy-mm-dd')) '_' char(LAYER) '_' char(INI.MODEL_ALL_RUNS(i)) '.xlsx']
        xlswrite(F,FDT);
    end
end

fclose('all');

end

