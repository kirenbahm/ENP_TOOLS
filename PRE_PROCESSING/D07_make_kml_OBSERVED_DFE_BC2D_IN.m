function D07_make_kml_OBSERVED_DFE_BC2D_IN()
%  This function creates kml files for viewing in GOOGLE_EARTH
%
%  Function creates a kml file of stations with links to png files.
%  It lists all pngs in specified directories, and uses the filenames to lookup
%  location info in a station metatdata file. It then creates a kml file and plots
%  the stations on a map, with clickable links to the png files.
%


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
DFE_STATION_DATA_FILE = '../../Obs_Processed_BC2D/DFE_station_table-20201106-fake_stns_added.txt';

% -------------------------------------------------------------------------
% Directory containing input png folder, and output kml location:
% -------------------------------------------------------------------------
DIR_STAGE_DFS0_IN = '../../Obs_Processed_BC2D/in/';
FILE_FILTER = [DIR_STAGE_DFS0_IN 'DFS0_pngs/*.png']; % list only files with extension *.png
KML_FILE = [DIR_STAGE_DFS0_IN char('BC2D_infiles.kml')];

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% END USER INPUT
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------


% Add MATLAB_SCRIPTS to path
try
    addpath(genpath(INI.MATLAB_SCRIPTS));
catch
    addpath(genpath(INI.MATLAB_SCRIPTS,0));
end

%Initialize .NET libraries
INI = initializeLIB(INI);

% Declare kml file and folder types
%KML_FOLDER_TYPES = {'CDF', 'CPE', 'CU', 'MM', 'TS','YY'};
KML_FOLDER_TYPES = {'TS','YY'};

% Load station names and coordinates
MAP_STATIONS = S00_load_DFE_STNLOC(DFE_STATION_DATA_FILE);

%PROCESS the *.png files based on known and listed DATATYPES
fprintf('\n');

% open kml file and write header info
fid = fopen(char(KML_FILE),'w');
fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">');
fprintf(fid,'\n<Folder><name>BC2D Infiles</name><open>1</open>');

try
    [IMAGE_FILES,KEYS] = S01_load_PREPROCESS_IMAGERY('WaterLevel',FILE_FILTER,MAP_STATIONS);
    fprintf('\n Image info LOADED\n')
    
    for jj = 1: length(KML_FOLDER_TYPES)
        fprintf(fid,'\n<Folder><name>%s</name><open>0</open>', KML_FOLDER_TYPES{jj});
        TF = contains(KEYS,KML_FOLDER_TYPES{jj});
        UNLOCK = KEYS(TF);
        
        for kk = 1: length(UNLOCK)
            S = IMAGE_FILES(UNLOCK{kk});
            IMAGE_LOCATION = ['DFS0' '_pngs/' S.name];
            
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

fprintf('\n\n KML file creation completed.\n\n');
end

