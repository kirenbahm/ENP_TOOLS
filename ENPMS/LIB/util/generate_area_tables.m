function [output_args] = generate_area_tables(AREA,MAP_STATION_STAT,LIST_STATIONS,INI,fidTEX)
%generate_area_tables(M, MS, STATION_LIST,INI,fidTEX) FFF
%rjf; from generate_latex_areasV0

fprintf ('...Stat tables for area %s\n',char(AREA));

i = 1;
for L = LIST_STATIONS
    try
        M = MAP_STATION_STAT(char(L));
        sz = length(M.PE(:,1));
        C(i:i+sz-1) = M.MODELRUN(1:sz);
        N(i:i+sz-1) = L;
        NDATA(i:i+sz-1,1:9) = M.STAT;
        PE(i:i+sz-1,1:9) = M.PE(1:sz,1:9);
        i = i+sz;
    catch
        %disp(L);
        try
            M = MAP_STATION_STAT(char(L));
            sz = length(M.PE(:,1));
            NDATA(i:i+sz-1,1:9) = 0;
            PE(i:i+sz-1,1:9) = 0;
        catch
            fprintf ('...skipping MAP_STATION_STAT(%s), not in container\n',char(L));
        end
    end
end


for i = 1:length(INI.MODEL_ALL_RUNS)
    MAP_KEY(i) = INI.MODEL_ALL_RUNS(i);
    MAP_VALUE(i) = INI.MODEL_RUN_DESC(i);
end
MAP_DESCR = containers.Map(MAP_KEY, MAP_VALUE);



print_table_stat_header(fidTEX,AREA);
STEND = '\\';
N_TMP = '';

for i = 1:length(C)
    if NDATA(i,1)
        D = (C(i)); %MAP_DESCR(char(C(i)));
        if ~strcmp(N(i),N_TMP)
            RN = strrep(N(i), '_', '\_');
            NTEX=['\textbf{' char(RN) '}'];
            N_TMP = N(i);
            if i > 1
                STEND =  '\\\\ \pagebreak[3] ';
            end
        else
            NTEX = '';
            STEND =  '\\\nopagebreak';
        end
        fprintf(fidTEX,'%s\n',STEND);
        fprintf(fidTEX,'%10s & %20s & %8d & %8.2f & %8.2f & %8.2f & %8.2f & %8.2f & %8.2f & %8.2f & %8.2f',NTEX,char(D),NDATA(i,:));
    end
end
fprintf(fidTEX,'%s\n','\\')';

ROW0 = ['\end{longtable}'];
fprintf(fidTEX,'%s\n',ROW0);
ROW1 = ['\end{center}'];
fprintf(fidTEX,'%s\n',ROW1);
ROW2 = ['\normalsize'];
fprintf(fidTEX,'%s\n',ROW2);
ROW3 = ['\renewcommand{\thefootnote}{\arabic{footnote}}'];
fprintf(fidTEX,'%s\n',ROW3);


print_table_PE_header(fidTEX,AREA);
STEND = '\\';
N_TMP = '';
for i = 1:length(C)
    if ~isnan(PE(i,:))
        D = C(i);% %MAP_DESCR(char(C(i)));
        if ~strcmp(N(i),N_TMP)
            RN = strrep(N(i), '_', '\_');
            NTEX=['\textbf{' char(RN) '}'];
            N_TMP = N(i);
            if i > 1
                STEND =  '\\\\ \pagebreak[3] '; %STEND =  '\\\\'
            end
        else
            NTEX = '';
            STEND =  '\\\nopagebreak'; %STEND =  '\\'
        end
        %D = MAP_DESCR(char(C(i)));
        fprintf(fidTEX,'%s\n',STEND);
        fprintf(fidTEX,'%10s & %20s & %8.2f & %8.2f & %8.2f & %8.2f & %8.2f & %8.2f & %8.2f & %8.2f & %8.2f',NTEX,char(D),PE(i,:));
    end
end
fprintf(fidTEX,'%s\n','\\');



ROW0 = ['\end{longtable}'];
fprintf(fidTEX,'%s\n',ROW0);
ROW1 = ['\end{center}'];
fprintf(fidTEX,'%s\n',ROW1);
ROW2 = ['\normalsize'];
fprintf(fidTEX,'%s\n',ROW2);
ROW3 = ['\renewcommand{\thefootnote}{\arabic{footnote}}'];
fprintf(fidTEX,'%s\n',ROW3);

%fprintf(fidTEX,'%s\n','\clearpage');

end

