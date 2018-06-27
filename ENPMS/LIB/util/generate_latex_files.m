function [] = generate_latex_files(MO,MS,INI)
%021812 - changed to only using INI
% added (currently unused) INI to input args in prepaation of future changes rjf 12/19/2011

fprintf('\n\n--Generating the LATEX file:');
fidTEX = generate_latex_head(INI);

FILEDATA = INI.FILESAVE_TS;
fprintf('\n\n--Loading Computed and observed data from file:\n\t%s', char(FILEDATA));
load(FILEDATA, '-mat');

fprintf('\n\n--Generating figures and tables:');
for M = keys(MO)
% % % try
    STATION_LIST = MO(char(M));
    if ~isKey(MAP_ALL_DATA,M)
        continue
    end
    
    generate_page_figures(M, STATION_LIST,MAP_ALL_DATA,INI,fidTEX);
    
% %     if INI.MAKE_STATISTICS_TABLE
% 		% add subsubsection statistics
%         fprintf('... Including statistics in the LATEX file\n');
%     	fprintf(fidTEX,'%s\n','\clearpage');
%     	row2 =['\section{Statistics Tables}'];
%     	fprintf(fidTEX,'%s\n\n',row2);
%     	generate_area_tables(M, MS, STATION_LIST,INI,fidTEX);
% %     end

end
generate_latex_tail(fidTEX);


end
