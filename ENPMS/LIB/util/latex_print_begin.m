function [output_args] = latex_print_begin(fidTEX,HEADER)

ROW111 =['\documentclass[12pt,twoside]{article}'];
ROW112 =['\usepackage{floatflt}'];
ROW113 =['\usepackage{flafter}'];
ROW114 =['\usepackage[top=1in, bottom=0.5in, left=1in, right=1in]{geometry}'];
ROW115 =['\usepackage{setspace}'];
ROW116 =['\usepackage[usenames,dvipsnames]{color}'];
ROW117 =['\usepackage{natbib}'];
ROW118 =['\usepackage[figuresright]{rotating}'];
ROW119 =['\usepackage{sidecap}     % for side captions'];
ROW120 =['\usepackage{fancyhdr}    % fancy headers and footers'];
ROW121 =['\usepackage{wrapfig}'];
ROW122 =['\usepackage{varioref}    % this is for vref'];
ROW123 =['\usepackage{graphicx,grffile}  % this is needed to eliminate runaway args from hyperref, grffile translates the filenames'];
ROW124 =['\usepackage{hyperref}'];
ROW125 =['\usepackage{booktabs}'];
ROW126 =['\usepackage {verbatim}  %for comment'];
ROW127 =['\usepackage{wasysym} % for symbols \smiley'];
ROW128 =['\usepackage{watermark}'];
ROW129 =['\usepackage[center,small,belowskip=20pt,aboveskip=20pt]{caption}'];
ROW130 =['\usepackage{caption}'];
ROW131 =['\usepackage{appendix}'];
ROW132 =['\usepackage{longtable}'];
ROW133 =['\usepackage{pdflscape}'];
ROW134 =['\usepackage{subfig}'];
ROW135 =[' '];
ROW136 = ['\pagestyle{fancy}'];
ROW137 = ['\fancyhf{}'];
ROW138 = ['\lhead{\today}'];
ROW139 = ['\rhead{'];
ROW140 = HEADER;
ROW141 = ['}'];
ROW142 = ['\captionsetup[subfigure]{labelformat=empty}'];

ROW143 =['\begin{document}'];
ROW144 =['\begin{landscape}'];

fprintf(fidTEX,'\n\n');
fprintf(fidTEX,'%s\n',ROW111);
fprintf(fidTEX,'%s\n',ROW112);
fprintf(fidTEX,'%s\n',ROW113);
fprintf(fidTEX,'%s\n',ROW114);
fprintf(fidTEX,'%s\n',ROW115);
fprintf(fidTEX,'%s\n',ROW116);
fprintf(fidTEX,'%s\n',ROW117);
fprintf(fidTEX,'%s\n',ROW118);
fprintf(fidTEX,'%s\n',ROW119);
fprintf(fidTEX,'%s\n',ROW120);
fprintf(fidTEX,'%s\n',ROW121);
fprintf(fidTEX,'%s\n',ROW122);
fprintf(fidTEX,'%s\n',ROW123);
fprintf(fidTEX,'%s\n',ROW124);
fprintf(fidTEX,'%s\n',ROW125);
fprintf(fidTEX,'%s\n',ROW126);
fprintf(fidTEX,'%s\n',ROW127);
fprintf(fidTEX,'%s\n',ROW128);
fprintf(fidTEX,'%s\n',ROW129);
fprintf(fidTEX,'%s\n',ROW130);
fprintf(fidTEX,'%s\n',ROW131);
fprintf(fidTEX,'%s\n',ROW132);
fprintf(fidTEX,'%s\n',ROW133);
fprintf(fidTEX,'%s\n',ROW134);
fprintf(fidTEX,'%s\n',ROW135);
fprintf(fidTEX,'%s\n',ROW136);
fprintf(fidTEX,'%s\n',ROW137);
fprintf(fidTEX,'%s',ROW138);
fprintf(fidTEX,'%s',ROW139);
fprintf(fidTEX,'%s',ROW140);
fprintf(fidTEX,'%s\n\n',ROW141);
fprintf(fidTEX,'%s\n\n',ROW142);
fprintf(fidTEX,'%s\n\n',ROW143);
fprintf(fidTEX,'%s\n\n',ROW144);

end

