function [] = generate_page_figures(AREA,LIST_STATIONS,MAP_ALL_DATA,INI,fidTEX)
% function to generate figures for each station

fprintf(fidTEX,'%s\n','\clearpage');
row2 =['\section{Area ' char(AREA) ': Timeseries, Stage Duration or Cumulative Flows}'];
fprintf(fidTEX,'%s\n\n',row2);

fprintf ('...Timeseries for area %s\n',char(AREA));
page3 = 0;
done =0;	%check if the page
%has no more figures (if there is only 1 or2)

RLABEL = sprintf('%s ',char(AREA));

% Provide Latex script for the folowing:
% timeseries/STATION.png
% timeseries/STATION-acc.png
% exceedance/STATION.png
% boxplots/STATION-MO.png
% boxplots/STATION-YR.png

for FIGURE = LIST_STATIONS
    try
        STATION = MAP_ALL_DATA(char(FIGURE));  %get a tmp structure, modify values
        STATION.DFSTYPE = STATION.DATATYPE;
    catch
        % if exception occurs if STATION is not in MAP_ALL_DATA continue with
        % next station modify to use iskey
        continue;
    end
    
    RFIGURE = strrep(FIGURE, '_', '\_');
    rfig = strrep(RFIGURE, '\_', '');
 
% additional plots can be listed below using the same pattern 
    FF{1} = ['/timeseries/' char(FIGURE) '.png'];
    FF{2} = ['/timeseries/' char(FIGURE) '-acc.png'];
    FF{3} = ['/exceedance/' char(FIGURE) '.png'];
    FF{4} = ['/boxplots/' char(FIGURE) '-MO.png'];
    FF{5} = ['/boxplots/' char(FIGURE) '-YR.png'];
    
    % begining of figure
    
    % iterate over figures
    i = 0;
    ii = 0;
    figure_per_page = 3;
    
    for LATEXFIG = FF
        ii = ii + 1;
        FILE_FIGURE = [INI.FIGURES_DIR char(LATEXFIG)];
        
        if ~exist(FILE_FIGURE,'file')
            continue
        end
        
        i = i + 1;        
        
        if ~mod(i+figure_per_page-1,figure_per_page)
            head_figure(fidTEX,RFIGURE,rfig);
        end
        
        FILE_RELATIVE_TS = [INI.FIGURES_RELATIVE_DIR char(LATEXFIG)];
        
        % start a subfigure
        ROW2 =['\subfigure{'];
        fprintf(fidTEX,'%s\n',ROW2);
        ROW3 =[' \includegraphics[width=7.0in]{' FILE_RELATIVE_TS '}'];
        ROW4 =['}'];
        fprintf(fidTEX,'%s\n',ROW3);
        fprintf(fidTEX,'%s\n\n',ROW4);
        
        if ~mod(i+figure_per_page,figure_per_page) | ii == length(FF) 
            % this is needed to print tail for max fig per page or end of
            % FF
            tail_figure(fidTEX,RFIGURE,RLABEL,FIGURE);
        end
        
    end
    
end

fprintf(fidTEX,'%s\n','\clearpage');

end

function head_figure(fidTEX,RFIGURE,rfig)
ROW1 =['\begin{figure} \begin{center}'];
fprintf(fidTEX,'%s\n',ROW1);

% provide a bookmark
ROW9=['\currentpdfbookmark{' char(RFIGURE) '}{' char(rfig) 'name}'];
fprintf(fidTEX,'%s\n',ROW9);
end

function tail_figure(fidTEX,RFIGURE,RLABEL,FIGURE)

% add caption
ROW5 =[' \caption[Station ' char(RFIGURE) ']{Station: ' char(RFIGURE) ', AREA: ' char(RLABEL) '}'];
%   ROW5 =[' \caption[ ' char(RFIGURE) ']{' char(RFIGURE) '}'];
fprintf(fidTEX,'%s\n',ROW5);

ROW6 =['\label{fig:' char(FIGURE) 'all}'];
fprintf(fidTEX,'%s\n',ROW6);

ROW7 =[' \end{center}'];
ROW8 =[' \end{figure}'];
fprintf(fidTEX,'%s\n',ROW7);
fprintf(fidTEX,'%s\n\n',ROW8);

fprintf(fidTEX,'%s\n','\clearpage');

end