function generate_latex_blocks_maps( FileName, Type, SectionName, figure )

if Type == 0
    fidTEX = fopen(FileName,'w');
    row0 = '\input{head.sty}';
    fprintf(fidTEX,'%s\n\n',row0);
elseif Type == 1
    fidTEX = fopen(FileName,'a');
    row0 = '\input{tail.sty}';
    fprintf(fidTEX,'\n%s',row0);
elseif Type == 2
    fidTEX = fopen(FileName,'a');
    row0 = '\clearpage';
    row1 = ['\section{' SectionName '}'];
    fprintf(fidTEX,'%s\n',row0);
    fprintf(fidTEX,'%s\n\n',row1);
else
    fidTEX = fopen(FileName,'a');
    row0 = '\clearpage';
    row1 = '\begin{figure} \begin{center}';
    row2 = ['\currentpdfbookmark{' SectionName '}{' SectionName '}'];
    row3 = ['\includegraphics[width=7.0in]{../figures/maps/' figure '}'];
    row4 = ['\caption[' SectionName ']{' SectionName '}'];
    row5 = ['\label{fig:' SectionName '}'];
    row6 = '\end{center}';
    row7 = '\end{figure}';
    fprintf(fidTEX,'%s\n',row0);
    fprintf(fidTEX,'%s\n',row1);
    fprintf(fidTEX,'%s\n\n',row2);
    fprintf(fidTEX,'%s\n\n',row3);
    fprintf(fidTEX,'%s\n',row4);
    fprintf(fidTEX,'%s\n',row5);
    fprintf(fidTEX,'%s\n',row6);
    fprintf(fidTEX,'%s\n\n',row7);
end
fclose(fidTEX);
