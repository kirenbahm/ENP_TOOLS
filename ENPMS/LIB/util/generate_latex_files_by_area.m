function [] = generate_latex_files(MO,MS,INI)
%021812 - changed to only using INI
% added (currently unused) INI to input args in prepaation of future changes rjf 12/19/2011

fprintf('... Generating the LATEX file\n');
fidTEX = generate_latex_head(INI);

FILEDATA = INI.FILESAVE_TS;
%fprintf('... Loading Computed and observed data:\n\t %s\n', char(FILEDATA));
load(FILEDATA, '-mat');


mapAreas = getMapAreas(MAP_ALL_DATA,MS); % use this map to print by areas

% for M = keys(MO)
for M = mapAreas.keys   
% % % try
%     STATION_LIST = MO(char(M));
    STATION_LIST = mapAreas(char(M));
%     FFIG = 'obsolete';
		%group subsection
        
 	fprintf(fidTEX,'%s\n','\clearpage');
    
 	row2 =['\section{Area ' char(M) ': Timeseries, Stage Duration or Cumulative Flows}'];
 	fprintf(fidTEX,'%s\n\n',row2);

		% add subsubsection timeseries

    generate_page_figures(M, STATION_LIST,MAP_ALL_DATA,INI,fidTEX);
% %     if (strcmp(INI.MAKE_EXCEEDANCE_PLOTS,'YES') == 1 )
% %             % add subsubsection exceedance
% %         fprintf('... Including exceedance plots in the LATEX file\n');
% %         generate_area_figures_exceedanceV2(M, STATION_LIST,INI,fidTEX);
% %     end
    
    if (strcmp(INI.MAKE_STATISTICS_TABLE,'YES') == 1 )
		% add subsubsection statistics
        fprintf('... Including statistics in the LATEX file\n');
    	fprintf(fidTEX,'%s\n','\clearpage');
    	row2 =['\subsection{Statistics Tables for Area ' char(M) '}'];
    	fprintf(fidTEX,'%s\n\n',row2);
    	generate_area_tables(M, MS, STATION_LIST,INI,fidTEX);
    end
% % % catch
% % %   fprintf ('...skipping in latex  %s\n',char(M));
% % % end

end
generate_latex_tail(fidTEX);


end

function mapAreas = getMapAreas(MAP_ALL_DATA,MS)
% this function creates a map of subdomain areas : N_AREAS and lists 
% all stations within each subdomain area
mapAreas = containers.Map;

for K = MS.keys
    I_AREA = MAP_ALL_DATA(char(K)).I_AREA;
    N_AREA = MAP_ALL_DATA(char(K)).N_AREA;
    if isKey(mapAreas,N_AREA)
        V_STATIONS = mapAreas(char(N_AREA));
        V_STATIONS = [V_STATIONS K];
    else 
        V_STATIONS = K;
    end
        mapAreas(char(N_AREA)) = V_STATIONS;
end

end 