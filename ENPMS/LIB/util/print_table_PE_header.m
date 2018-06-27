function [TABLE_PE_HEADER] = print_table_PE_header(fidTEX,AREA)

AREAr = strrep(AREA,'_','\_');
ROW1 = ['\renewcommand{\thefootnote}{\alph{footnote}}'];
fprintf(fidTEX,'%s\n',ROW1);
ROW2 = ['\scriptsize'];
fprintf(fidTEX,'%s\n',ROW2);
ROW3 = ['\begin{center}'];
fprintf(fidTEX,'%s\n',ROW3);
ROW4 = ['\begin{longtable}{llrrrrrrrrr}'];
fprintf(fidTEX,'%s\n',ROW4);
ROW5 = ['\caption[Vicinity of ' char(AREAr) ']{Probability Exceedance for stations in the vicinity of ' char(AREAr) '} \label{tab:'  char(AREA) '-PE} \\'];
fprintf(fidTEX,'%s\n',ROW5);
ROW6 = ['\hline'];
fprintf(fidTEX,'%s\n',ROW6);
ROW7 = ['        &  & \multicolumn{9}{c}{\textbf{Probability Exceedance (Observed $-$ Computed)}} \\'];
fprintf(fidTEX,'%s\n',ROW7);
ROW8 = [' \textbf{Station}   &   \textbf{Model Run}  & \textbf{0.01}  & \textbf{0.05}    &   \textbf{0.10}  & \textbf{0.20}    &   \textbf{0.50}    & \textbf{0.80}  &   \textbf{0.90}   &   \textbf{0.95} &  \textbf{0.99}\\'];
fprintf(fidTEX,'%s\n',ROW8);

ROW9 = ['\hline'];
fprintf(fidTEX,'%s\n',ROW9);

ROW10 = ['\endfirsthead'];
fprintf(fidTEX,'%s\n',ROW10);
ROW12 = ['\multicolumn{10}{c}{{\tablename} \thetable{} -- Continued} \\ \hline '];
fprintf(fidTEX,'%s\n',ROW12);
ROW10 = ['\hline'];
fprintf(fidTEX,'%s\n',ROW10);
ROW13 = ['  \textbf{Station}   &   \textbf{Model Run}  & \textbf{0.01}  & \textbf{0.05}    &   \textbf{0.10}  & \textbf{0.20}    &   \textbf{0.50}    & \textbf{0.80}  &   \textbf{0.90}   &   \textbf{0.95} &  \textbf{0.99}\\'];
fprintf(fidTEX,'%s\n',ROW13);
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
