function D07_make_kml_OBSERVED_DFE()
%  This function creates kml files for viewing in GOOGLE_EARTH
%
%  Function creates a kml file of stations with links to png files.
%  It lists all pngs in specified directories, and uses the filenames to lookup
%  location info in a station metatdata file. It then creates a kml file and plots
%  the stations on a map, with clickable links to the png files.
%
%  The script searches all KNOWN and LISTED datatypes (DType_Flag='Discharge','WaterLevel') 
%  It creates a separate kml for each datatype and temporal aggregation (DFSO_TYPE='DFS0','DFS0DD','DFS0HR');
%  It subdivides each kml file into categories by CHART_TYPE {'CDF', 'CPE', 'CU', 'MM', 'TS','YY'}; 


% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% BEGIN USER INPUT
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Location of ENPMS library
% -------------------------------------------------------------------------
INI.MATLAB_SCRIPTS = '../ENPMS/';

% -------------------------------------------------------------------------
% Location of input station metadata file (this is the DFE station table)
% -------------------------------------------------------------------------
DFE_STATION_DATA_FILE = '../../Obs_Data_Raw/DFE_station_table-20201106.txt';

% -------------------------------------------------------------------------
% LOAD directory locations and list PNG directory options
% -------------------------------------------------------------------------
DIR_FLOW_DFS0_IN  = '../../Obs_Data_Final_DFS0/Flow/';
DIR_STAGE_DFS0_IN = '../../Obs_Data_Final_DFS0/Stage/';
DIR_FLOW_KML_OUT  = '../../Obs_Data_Final_DFS0/Flow/';
DIR_STAGE_KML_OUT = '../../Obs_Data_Final_DFS0/Stage/';

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% END USER INPUT
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% Create output directories if they don't already exist
if ~exist(DIR_FLOW_KML_OUT,  'dir'); mkdir(DIR_FLOW_KML_OUT);  end
if ~exist(DIR_STAGE_KML_OUT, 'dir'); mkdir(DIR_STAGE_KML_OUT); end

% Add MATLAB_SCRIPTS to path
try
    addpath(genpath(INI.MATLAB_SCRIPTS));
catch
    addpath(genpath(INI.MATLAB_SCRIPTS,0));
end

%Initialize .NET libraries
INI = initializeLIB(INI);

% Declare kml file and folder types
KML_FILE_TYPES   = {'DFS0','DFS0DD','DFS0HR'};
KML_FOLDER_TYPES = {'CDF', 'CPE', 'CU', 'MM', 'TS','YY'}; 

% Load station names and coordinates
MAP_STATIONS = S00_load_DFE_STNLOC(DFE_STATION_DATA_FILE);

%PROCESS the *.png files based on known and listed DATATYPES
for DType_Flag = {'Discharge','WaterLevel'}
    if strcmpi(DType_Flag,'Discharge')
        for ii = 1: length(KML_FILE_TYPES)
            DIR_FILTER = [DIR_FLOW_DFS0_IN KML_FILE_TYPES{ii} '_pngs/'];
            FILE_FILTER = [DIR_FILTER '*.png']; % list only files with extension *.dat

            % open kml file and write header info
            KML_FILE = [DIR_FLOW_KML_OUT char(DType_Flag) '.' KML_FILE_TYPES{ii} '.kml'];
            fid = fopen(char(KML_FILE),'w');
            fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">');
            fprintf(fid,'\n<Folder><name>PreProcessing Analysis: %s-%s</name><open>1</open>', char(DType_Flag), KML_FILE_TYPES{ii});
            
            try
                [IMAGE_FILES,KEYS] = S01_load_PREPROCESS_IMAGERY(DType_Flag,FILE_FILTER,MAP_STATIONS);
                fprintf('\n Image info LOADED: %s - %s... ', char(DType_Flag), char(KML_FILE_TYPES{ii}))
                
                for jj = 1: length(KML_FOLDER_TYPES)
                    fprintf(fid,'\n<Folder><name>%s</name><open>0</open>', KML_FOLDER_TYPES{jj});
                    TF = contains(KEYS,KML_FOLDER_TYPES{jj});
                    UNLOCK = KEYS(TF);
                    
                    for kk = 1: length(UNLOCK)
                        S = IMAGE_FILES(UNLOCK{kk});
                        IMAGE_LOCATION = [KML_FILE_TYPES{ii} '_pngs/' S.name];
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
        
     elseif strcmpi(DType_Flag,'WaterLevel')
        fprintf('\n');
        for ii = 1: length(KML_FILE_TYPES)
            FILE_FILTER = [DIR_STAGE_DFS0_IN KML_FILE_TYPES{ii} '_pngs/*.png']; % list only files with extension *.dat

            % open kml file and write header info
            KML_FILE = [DIR_STAGE_KML_OUT char(DType_Flag) '.' KML_FILE_TYPES{ii} '.kml'];
            fid = fopen(char(KML_FILE),'w');
            fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">');
            fprintf(fid,'\n<Folder><name>PreProcessing Analysis: %s-%s</name><open>1</open>', char(DType_Flag), KML_FILE_TYPES{ii});
            
            try
                [IMAGE_FILES,KEYS] = S01_load_PREPROCESS_IMAGERY(DType_Flag,FILE_FILTER,MAP_STATIONS);
                fprintf('\n Image info LOADED: %s - %s... ', char(DType_Flag), char(KML_FILE_TYPES{ii}))
                
                for jj = 1: length(KML_FOLDER_TYPES)
                    fprintf(fid,'\n<Folder><name>%s</name><open>0</open>', KML_FOLDER_TYPES{jj});
                    TF = contains(KEYS,KML_FOLDER_TYPES{jj});
                    UNLOCK = KEYS(TF);
                    
                    for kk = 1: length(UNLOCK)
                        S = IMAGE_FILES(UNLOCK{kk});
                        IMAGE_LOCATION = [KML_FILE_TYPES{ii} '_pngs/' S.name];
                        
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

