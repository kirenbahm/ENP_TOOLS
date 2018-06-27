function head_figure(fidTEX,RFIGURE,rfig)
ROW1 =['\begin{figure} \begin{center}'];
fprintf(fidTEX,'%s\n',ROW1);

% provide a bookmark
ROW9=['\currentpdfbookmark{' char(RFIGURE) '}{' char(rfig) 'name}'];
fprintf(fidTEX,'%s\n',ROW9);
end
