function [output_args] = latex_end_page(fidTEX)
ROW111 =['\end{figure}'];
ROW112 =['\clearpage'];
fprintf(fidTEX,'%s\n',ROW111);
fprintf(fidTEX,'%s\n\n',ROW112);

end