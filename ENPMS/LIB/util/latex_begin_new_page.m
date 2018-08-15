function [output_args] = latex_begin_new_page(fidTEX)
ROW111 =['\begin{figure}'];
ROW112 =['\centering'];
fprintf(fidTEX,'%s\n',ROW111);
fprintf(fidTEX,'%s\n',ROW112);

end