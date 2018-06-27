function [fidTEX] = generate_latex_head( SIM)
% 2011-10-07 keb - path for readme.txt file updated to current location in new directory structure using RELATIVE reference. a bit hacky.
% 2011-10-12 keb - changed readme.txt include to verbatim style
% 2011-10-12 keb - changed row1 section header to generic title and moved description from station file below it
% 2011-10-13 keb - added try statement for readme so wouldn't crash if none found

FFF_TEX = [SIM.LATEX_DIR '/' SIM.ANALYSIS_TAG '.tex'];
fidTEX = fopen(FFF_TEX,'w');

row0 = ['\input{head.sty}'];
row1 =['\section{Simulation Information}']; % added 2011-10-12 keb
% row2 =[ SIM.SELECTED_STATIONS.header ]; % added 2011-10-12 keb

fprintf(fidTEX,'%s\n\n',row0);
fprintf(fidTEX,'%s\n\n',row1);
% fprintf(fidTEX,'%s\n\n',row2); % added 2011-10-12 keb

row3 =['Plots of monitoring points (surface water stages and/or groundwater heads) and canal structures (headwater, discharge and tailwater). Statistics include the Nash-Sutcliffe, Bias and Root Mean Square Error values. No.~Points are number of points in the data set and No.~NaN are number of no-data points in the observed data timeseries. Suffix of ol means the station surface water timeseries is used. L1 means the upper aquifer layer timeseries is used. The lower aquifer layer timeseries is used for all other values.   '];
fprintf(fidTEX,'%s\n\n',row3);

% 
% % include the readme file
% for i = 1:SIM.NSIMULATIONS
%    try % added 2011-10-13 keb so doesn't boot out if no readme exists
%        TEXT = strrep(SIM.MODEL_SIMULATION_SET{i}{3}, '_', '\_');
%       rowt = ['\paragraph{Simulation run readme: ' TEXT '}']; % added 2011-10-12 keb
%       fprintf(fidTEX,'%s\n',rowt);
%       rdme = [SIM.readme SIM.MODEL_SIMULATION_SET{i}{4} '/' SIM.MODEL_SIMULATION_SET{i}{3} '/readme.txt'];
%       copyfile( rdme, SIM.LATEX_DIR )
% 
%       movefile ([SIM.LATEX_DIR  '/readme.txt'],[SIM.LATEX_DIR '/' SIM.MODEL_SIMULATION_SET{i}{3} '-readme.txt']);
%       readmefile = [SIM.MODEL_SIMULATION_SET{i}{3} '-readme.txt'];
%       rowi = ['\vskip 0.1in \verbatiminput{' readmefile '}'];
%       fprintf(fidTEX,'%s\n\n',rowi);
%    catch
%       rowi = ['\vskip 0.1in \emph{readme file not found.}'];
%       fprintf(fidTEX,'%s\n\n',rowi);
%    end


end

