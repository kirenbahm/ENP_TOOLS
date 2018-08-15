function [output_args] = latex_print_pages_figures(m,n,fidTEX,PATHSTR,NAME,EXT,NoFIG)

ROW111 = ['\subfloat['];
ROW112 = strrep(NAME,'_','\_');
ROW113 = [']'];

if NoFIG == 2                                                               %% if statement to adjust the spacing between windows on 
    ROW114 = ['{\includegraphics[width=0.75\textwidth]{'];                 %% a single page of either 2x2 or 2x3 plots
elseif NoFIG == 3
    ROW114 = ['{\includegraphics[width=0.65\textwidth]{'];
else
    fprint('Error, NoFIG value must equal 2 or 3.')
    return
end

ROW115 = PATHSTR; 
ROW116 = NAME; 
ROW117 = EXT; 
ROW118 = ['}}'];
fprintf(fidTEX,'%s',ROW111);
fprintf(fidTEX,'%s',ROW112);
fprintf(fidTEX,'%s',ROW113);
fprintf(fidTEX,'%s',ROW114);
fprintf(fidTEX,'%s',ROW115);
fprintf(fidTEX,'%s',ROW116);
fprintf(fidTEX,'%s',ROW117);
fprintf(fidTEX,'%s',ROW118);

if n == 0, fprintf(fidTEX,'%s\n','\\');
else fprintf(fidTEX,'\n'); end 

end

