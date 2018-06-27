function [output_arg] = generate_latex_tail(fidTEX)


row0 = ['\input{tail.sty}'];
fprintf(fidTEX,'\n%s',row0);

%fprintf ('Closing latex file\n');
fclose(fidTEX);


end

