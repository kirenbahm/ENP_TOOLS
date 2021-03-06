function [] = generate_page_figures(AREA,LIST_STATIONS,MAP_ALL_DATA,INI,fidTEX)
% function to generate figures for each station

AREALABEL = strrep(char(AREA), '_', '\_');
fprintf(fidTEX,'%s\n','\clearpage');

if INI.LATEX_REPORT_BY_AREA
    row2 =['\section{Area ' char(AREALABEL) ': Timeseries, Stage Duration or Cumulative Flows}'];
    fprintf(fidTEX,'%s\n\n',row2);
end

fprintf ('\n\t Timeseries for area %s',char(AREA));
page3 = 0;
done =0;	%check if the page
%has no more figures (if there is only 1 or2)


RLABEL = sprintf('%s ',char(AREALABEL));

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
    
%     head_figure(fidTEX,RFIGURE,rfig);

    ik = 0;

    print_tail = 0;
    for LATEXFIG = FF
        ii = ii + 1;
        FILE_FIGURE = [INI.FIGURES_DIR char(LATEXFIG)];
        
        if ~exist(FILE_FIGURE,'file')
            continue
        end
        
        print_tail = 1;
        i = i + 1;
        
        %         if ~mod(i+figure_per_page-1,figure_per_page)
        %             head_figure(fidTEX,RFIGURE,rfig);
        %         end
        
        if ~mod(ik,figure_per_page)
            head_figure(fidTEX,RFIGURE,rfig);
        end
        ik = ik + 1;
        
        FILE_RELATIVE_TS = [INI.FIGURES_RELATIVE_DIR char(LATEXFIG)];
        
        % start a subfigure
        ROW2 =['\subfigure{'];
        fprintf(fidTEX,'%s\n',ROW2);
        ROW3 =[' \includegraphics[width=7.0in]{' FILE_RELATIVE_TS '}'];
        ROW4 =['}'];
        fprintf(fidTEX,'%s\n',ROW3);
        fprintf(fidTEX,'%s\n\n',ROW4);
        
        %         if ~mod(i+figure_per_page,figure_per_page) | ii == length(FF);
        %             % this is needed to print tail for max fig per page or end of FF
        %             tail_figure(fidTEX,RFIGURE,RLABEL,FIGURE);
        %         end
        if ~mod(ik,figure_per_page)
            tail_figure(fidTEX,RFIGURE,RLABEL,FIGURE);
            print_tail = 0;
        end
        
    end
    if print_tail
        tail_figure(fidTEX,RFIGURE,RLABEL,FIGURE);
        print_tail = 0;
    end
end

fprintf(fidTEX,'%s\n\n','\clearpage');

end
