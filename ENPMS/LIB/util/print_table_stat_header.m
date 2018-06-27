function [TABLE_STAT_HEADER] = print_table_stat_header(fidTEX,AREA)

AREAr = strrep(AREA,'_','\_');
ROW1 = ['\renewcommand{\thefootnote}{\alph{footnote}}'];
fprintf(fidTEX,'%s\n',ROW1);
ROW2 = ['\scriptsize'];
fprintf(fidTEX,'%s\n',ROW2);
ROW3 = ['\begin{center}'];
fprintf(fidTEX,'%s\n',ROW3);
ROW4 = ['\begin{longtable}{llrrrrrrrrr}'];
fprintf(fidTEX,'%s\n',ROW4);
ROW5 = ['\caption[Statistical parameters for stations in the vicinity of ' char(AREAr) ']{Statistical parameters for stations in the vicinity of ' char(AREAr) '} \label{tab:' char(AREA) '-STAT} \\'];
fprintf(fidTEX,'%s\n',ROW5);
ROW6 = ['\hline'];
fprintf(fidTEX,'%s\n',ROW6);
ROW7 = ['\textbf{Station}   &   \textbf{Model Run}  &   \textbf{N}  &   \textbf{MA}  &   \textbf{MAE}  &   \textbf{RMSE}  &   \textbf{STD}  &   \textbf{NS}  &   \textbf{COVAR}  &   \textbf{COR}  &   \textbf{PEV}  \\'];
fprintf(fidTEX,'%s\n',ROW7);

ROW8 = ['\hline'];
fprintf(fidTEX,'%s\n',ROW8);

ROW9 = ['\endfirsthead'];
fprintf(fidTEX,'%s\n',ROW9);

ROW10 = ['\multicolumn{10}{c}{{\tablename} \thetable{} -- Continued} \\ \hline '];
fprintf(fidTEX,'%s\n',ROW10);
ROW11 = ['\hline'];
fprintf(fidTEX,'%s\n',ROW11);
ROW12 = ['\textbf{Station}   &   \textbf{Model Run}  &   \textbf{N}  &   \textbf{MA}  &   \textbf{MAE}  &   \textbf{RMSE}  &   \textbf{STD}  &   \textbf{NS}  &   \textbf{COVAR}  &   \textbf{COR}  &   \textbf{PEV}  \\'];
fprintf(fidTEX,'%s\n',ROW12);
ROW14 = ['\hline'];
fprintf(fidTEX,'%s\n',ROW14);
ROW15 = ['\endhead'];
fprintf(fidTEX,'%s\n',ROW15);

ROW16 = ['\hline'];
fprintf(fidTEX,'%s\n',ROW16);

ROW17 = ['\multicolumn{11}{c}{{Continued on Next Page\ldots}} \\'];
fprintf(fidTEX,'%s\n',ROW17);

ROW18 = ['\hline'];
fprintf(fidTEX,'%s\n',ROW18);

ROW19 = ['\endfoot'];
fprintf(fidTEX,'%s\n',ROW19);

ROW20 = ['\hline'];
fprintf(fidTEX,'%s\n',ROW20);
ROW21 = ['\endlastfoot'];
fprintf(fidTEX,'%s\n',ROW21);
end
