function [IMAGE_FILES,KEYS] = S01_load_PREPROCESS_IMAGERY(INI,DType_Flag,DFS0_TYPE,FILE_FILTER,MAP_STATIONS)
%Function uses *.PNG image files of observed DFE data used in DFS0 file
%  creation. The script searches all KNOWN and LISTED datatype (DType_Flag) 
%  directories separating the images by CHART TYPE building a *.kml file
%  for usage with GOOGLE EARTH.

% Location of ENPMS library
INI.MATLAB_SCRIPTS = '../ENPMS/';
IMAGE_FILES = containers.Map();
LISTING  = dir(char(FILE_FILTER));
NLISTING = length(LISTING);
KEYS = cell(1,NLISTING);
FILE = struct('layer',cell(1,NLISTING),'folder',cell(1,NLISTING),'name',...
    cell(1,NLISTING),'station',cell(1,NLISTING),'datatype',cell(1,NLISTING),...
    'chart',cell(1,NLISTING),'lat',cell(1,NLISTING),'long',cell(1,NLISTING));
for jj = 1:length(LISTING)
    try
        temp = strsplit(LISTING(jj).name,'.');
        fileNAME_parts = [temp{1} strsplit(temp{2},'-') temp{3}];
        KEYS{jj} = LISTING(jj).name;
        FILE(jj).layer = char(DType_Flag);
        FILE(jj).folder = fileNAME_parts{3};
        FILE(jj).name = LISTING(jj).name;
        FILE(jj).station = fileNAME_parts{1};
        FILE(jj).datatype = fileNAME_parts{2};
        FILE(jj).chart = fileNAME_parts{3};
        FILE(jj).lat = MAP_STATIONS(fileNAME_parts{1}).LAT;
        FILE(jj).long = MAP_STATIONS(fileNAME_parts{1}).LONG;
        IMAGE_FILES(char(KEYS(jj))) = FILE(jj);
    catch
        fprintf('\n ERROR LOADING: %s\n', LISTING(jj).name)
    end
end

fprintf('\n Images LOADED: %s - %s \n\n', char(DType_Flag), char(DFS0_TYPE))
end
