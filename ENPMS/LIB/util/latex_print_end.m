function [output_args] = latex_print_end(fidTEX)

ROW111 =['\end{landscape} '];
ROW112 =['\end{document}'];
fprintf(fidTEX,'%s\n',ROW111);
fprintf(fidTEX,'%s\n',ROW112);

end
