function tail_figure(fidTEX,RFIGURE,RLABEL,FIGURE)

% add caption
% ROW5 =[' \caption[Station ' char(RFIGURE) ']{Station: ' char(RFIGURE)];
ROW5 =[' \caption[ ' char(RFIGURE) ']{' char(RFIGURE) '}'];
fprintf(fidTEX,'%s\n',ROW5);

ROW6 =['\label{fig:' char(FIGURE) 'all}'];
fprintf(fidTEX,'%s\n',ROW6);

ROW7 =[' \end{center}'];
ROW8 =[' \end{figure}'];
fprintf(fidTEX,'%s\n',ROW7);
fprintf(fidTEX,'%s\n\n',ROW8);

fprintf(fidTEX,'%s\n','\clearpage');

end
