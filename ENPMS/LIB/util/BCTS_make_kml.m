function BCTS_make_kml()
%  This function creates kml files for viewing in GOOGLE_EARTH
%
%  Function creates a kml file of stations with links to png files.
%  It lists all pngs in specified directories, and uses the filenames to lookup
%  location info in a station metatdata file. It then creates a kml file and plots
%  the stations on a map, with clickable links to the png files.

% Location of station metadata file (this is the DFE station table)
DFE_STATION_DATA_FILE = '../../ENP_TOOLS_Sample_Input/Data_Common/dfe_station_table.txt';

%LOAD directory locations and list PNG directory options
INI.DIR_STAGE_DFS0 = '../../ENP_TOOLS_Sample_Input/Obs_Data_Processed/STAGE/';

%LIST all directories with *.PNG files
DFS0_TYPE = {'DFS0','DFS0DD','DFS0HR'};
CHART_TYPE = {'CDF', 'CPE', 'CU', 'MM', 'TS','YY'}; 

MAP_STATIONS = S00_load_DFE_STNLOC(DFE_STATION_DATA_FILE);

%PROCESS the *.png files based on known and listed DATATYPES
for DType_Flag = {'Discharge','WaterLevel'}
    if strcmpi(DType_Flag,'Discharge')
        fprintf('\n\n\n...skipping discharge datatype...');
           
    elseif strcmpi(DType_Flag,'WaterLevel')
        fprintf('\n');
        for ii = 1: length(DFS0_TYPE)
            FILE_FILTER = [INI.DIR_STAGE_DFS0 DFS0_TYPE{ii} '_pngs/*.png']; % list only files with extension *.dat
            KML_FILE = [INI.DIR_STAGE_DFS0 char(DType_Flag) '.' DFS0_TYPE{ii} '.kml'];
            fid = fopen(char(KML_FILE),'w');
            fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">');
            fprintf(fid,'\n<Folder><name>PreProcessing Analysis: %s-%s</name><open>1</open>', char(DType_Flag), DFS0_TYPE{ii});
            try
					%Function uses *.PNG image files of observed DFE data used in DFS0 file
					%  creation. The script searches all KNOWN and LISTED datatype (DType_Flag) 
					%  directories separating the images by CHART TYPE building a *.kml file
					%  for usage with GOOGLE EARTH.
					%
					% Expected filename format is: station.dataype-plottype.png
					
					IMAGE_FILES = containers.Map();
					LISTING  = dir(char(FILE_FILTER));
					NLISTING = length(LISTING);
					KEYS = cell(1,NLISTING);
					FILE_INFO = struct('layer',cell(1,NLISTING),'folder',cell(1,NLISTING),'name',...
					    cell(1,NLISTING),'station',cell(1,NLISTING),'datatype',cell(1,NLISTING),...
					    'chart',cell(1,NLISTING),'lat',cell(1,NLISTING),'long',cell(1,NLISTING));
					for jj = 1:length(LISTING)
					    try
					        temp = strsplit(LISTING(jj).name,'.');
					        fileNAME_parts = [temp{1} strsplit(temp{2},'-') temp{3}];
					        KEYS{jj} = LISTING(jj).name;
					        FILE_INFO(jj).layer = char(DType_Flag);
					        FILE_INFO(jj).folder = fileNAME_parts{3};
					        FILE_INFO(jj).name = LISTING(jj).name;
					        FILE_INFO(jj).station = fileNAME_parts{1};
					        FILE_INFO(jj).datatype = fileNAME_parts{2};
					        FILE_INFO(jj).chart = fileNAME_parts{3};
					        FILE_INFO(jj).lat = MAP_STATIONS(fileNAME_parts{1}).LAT;
					        FILE_INFO(jj).long = MAP_STATIONS(fileNAME_parts{1}).LONG;
					        IMAGE_FILES(char(KEYS(jj))) = FILE_INFO(jj);
					    catch
					        fprintf('\n ERROR LOADING: %s\n', LISTING(jj).name)
					    end
					end


                fprintf('\n Image info LOADED: %s - %s... ', char(DType_Flag), char(DFS0_TYPE{ii}))
                for jj = 1: length(CHART_TYPE)
                    fprintf(fid,'\n<Folder><name>%s</name><open>0</open>', CHART_TYPE{jj});
                    TF = contains(KEYS,CHART_TYPE{jj});
                    UNLOCK = KEYS(TF);
                    for kk = 1: length(UNLOCK)
                        S = IMAGE_FILES(UNLOCK{kk});
                        IMAGE_LOCATION = [DFS0_TYPE{ii} '_pngs/' S.name];
                        fprintf(fid,'\n<Placemark>	<name>%s</name>	<description>	<![CDATA[<img src="%s" width="876">]]>	</description>	<Style>	<IconStyle>	<color>ff33ff00</color>	<scale>0.5</scale>	<Icon>	<href>H:/icon2.png</href>	</Icon>	</IconStyle>	</Style>	<Point>	<extrude>1</extrude>	<altitudeMode>relativeToGround</altitudeMode>	<coordinates>%10.6f,	%10.6f,	0</coordinates>	</Point>	</Placemark>', S.station, IMAGE_LOCATION, S.long, S.lat);
                    end
                    fprintf(fid,'\n</Folder>');
                end
                fprintf(fid,'\n</Folder>');            
            catch
            end
            fprintf(fid,'\n</kml>');
            fclose(fid);
            fprintf('KML created: %s', KML_FILE);
       end
    end

end

fprintf('\n\n KML file creation completed.\n\n');
end

