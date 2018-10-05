function D07_map_OBSERVED_DFE()
%Function uses *.PNG image files of observed DFE data used in DFS0 file
%  creation. The script searches all KNOWN and LISTED datatype (DType_Flag) 
%  directories separating the images by CHART TYPE building a *.kml file
%  for usage with GOOGLE EARTH.
clc
clearvars

% Location of ENPMS library
INI.MATLAB_SCRIPTS = '../ENPMS/';

try
    addpath(genpath(INI.MATLAB_SCRIPTS));
catch
    addpath(genpath(INI.MATLAB_SCRIPTS,0));
end

%LOAD directory locations and list PNG directory options
INI.DIR_FLOW_DFS0 = '../../ENP_TOOLS_Sample_Input/Obs_Data_Processed/D01_FLOW/';
INI.DIR_STAGE_DFS0 = '../../ENP_TOOLS_Sample_Input/Obs_Data_Processed/D02_STAGE/';

%LIST all directories with *.PNG files
DFS0_TYPE = {'DFS0','DFS0DD','DFS0HR'};
CHART_TYPE = {'CDF', 'CPE', 'CU', 'MM', 'TS','YY'}; 

MAP_STATIONS = S00_load_DFE_STNLOC();

%PROCESS the *.png files based on known and listed DATATYPES
for DType_Flag = {'Discharge','WaterLevel'}
    if strcmpi(DType_Flag,'Discharge')
        for ii = 1: length(DFS0_TYPE)
            DIR_FILTER = [INI.DIR_FLOW_DFS0 DFS0_TYPE{ii} '_pngs/'];
            FILE_FILTER = [DIR_FILTER '*.png']; % list only files with extension *.dat
            KML_FILE = [INI.DIR_FLOW_DFS0 char(DType_Flag) '.' DFS0_TYPE{ii} '.kml'];
            fid = fopen(char(KML_FILE),'w');
            fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">');
            fprintf(fid,'\n<Folder><name>PreProcessing Analysis: %s-%s</name><open>1</open>', char(DType_Flag), DFS0_TYPE{ii});
            try
                [IMAGE_FILES,KEYS] = S01_load_PREPROCESS_IMAGERY(INI,DType_Flag,DFS0_TYPE{ii},FILE_FILTER,MAP_STATIONS);
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
        end
        
     elseif strcmpi(DType_Flag,'WaterLevel')
        for ii = 1: length(DFS0_TYPE)
            FILE_FILTER = [INI.DIR_STAGE_DFS0 DFS0_TYPE{ii} '_pngs/*.png']; % list only files with extension *.dat
            KML_FILE = [INI.DIR_STAGE_DFS0 char(DType_Flag) '.' DFS0_TYPE{ii} '.kml'];
            fid = fopen(char(KML_FILE),'w');
            fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">');
            fprintf(fid,'\n<Folder><name>PreProcessing Analysis: %s-%s</name><open>1</open>', char(DType_Flag), DFS0_TYPE{ii});
            try
                [IMAGE_FILES,KEYS] = S01_load_PREPROCESS_IMAGERY(INI,DType_Flag,DFS0_TYPE{ii},FILE_FILTER,MAP_STATIONS);
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
        end
    end

end

fprintf('KML file creation completed.\n');
end

