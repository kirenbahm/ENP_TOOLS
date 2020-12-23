function D07_make_kml_OBSERVED_DFE_BC2D_OUT()

%  This function creates kml files for viewing in GOOGLE_EARTH
%
%  Function creates a kml file of stations with links to png files.
%  It lists all pngs in specified directories, and uses the filenames to lookup
%  location info in a station metatdata file. It then creates a kml file and plots
%  the stations on a map, with clickable links to the png files.

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
DIR_STAGE_DFS0_IN = '../../Obs_Processed_BC2D/out/Julian/';
FILE_FILTER = [DIR_STAGE_DFS0_IN 'FIGURES/*.png']; % list only files with extension *.png
KML_FILE = [DIR_STAGE_DFS0_IN char('BC2D_outfiles.kml')];

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

% Load station names and coordinates
MAP_STATIONS = S00_load_DFE_STNLOC(DFE_STATION_DATA_FILE);

fprintf('\n');

% open kml file and write header info
fid = fopen(char(KML_FILE),'w');
fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">');
fprintf(fid,'\n<Folder><name>BC2D outfiles</name><open>1</open>');

%PROCESS the *.png files based on known and listed DATATYPES
IMAGE_FILES = containers.Map();
LISTING  = dir(char(FILE_FILTER));
NLISTING = length(LISTING);
KEYS = cell(1,NLISTING);

FILE_INFO = struct(...
    'name',cell(1,NLISTING),...
    'station',cell(1,NLISTING),...
    'lat',cell(1,NLISTING),...
    'long',cell(1,NLISTING));

for jj = 1:length(LISTING)
    try
        temp = strsplit(LISTING(jj).name,'.');
        fileNAME_parts = [strsplit(temp{1},'_DD') temp{2}];
        KEYS{jj} = LISTING(jj).name;
        
        FILE_INFO(jj).name = LISTING(jj).name;
        FILE_INFO(jj).station = fileNAME_parts{1};
        FILE_INFO(jj).lat = MAP_STATIONS(fileNAME_parts{1}).LAT;
        FILE_INFO(jj).long = MAP_STATIONS(fileNAME_parts{1}).LONG;
        
        IMAGE_FILES(char(KEYS(jj))) = FILE_INFO(jj);
    catch
        fprintf('\n -->ERROR LOADING: %s', LISTING(jj).name)
    end
end

fprintf('\n Image info LOADED')

% Write the kml file data section
for kk = 1: length(KEYS)
    try
        S = IMAGE_FILES(KEYS{kk});
        PNG_FILENAME = ['FIGURES/' S.name];
        
        fprintf(fid,'\n<Placemark>	<name>%s</name>	<description>	<![CDATA[<img src="%s" width="876">]]>	</description>	<Style>	<IconStyle>	<color>ff33ff00</color>	<scale>0.5</scale>	<Icon>	<href>H:/icon2.png</href>	</Icon>	</IconStyle>	</Style>	<Point>	<extrude>1</extrude>	<altitudeMode>relativeToGround</altitudeMode>	<coordinates>%10.6f,	%10.6f,	0</coordinates>	</Point>	</Placemark>', ...
            S.station, PNG_FILENAME, S.long, S.lat);
    catch
        fprintf('\n -->ERROR writing to kml: %s', KEYS{kk})
    end
end

% Write the kml file footer
fprintf(fid,'\n</Folder>');
fprintf(fid,'\n</kml>');

fclose(fid);

fprintf('\nKML created: %s', KML_FILE);
fprintf('\n\nKML file creation completed.\n\n');

end

