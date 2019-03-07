function [IMAGE_FILES,KEYS] = S01_load_PREPROCESS_IMAGERY(DType_Flag,FILE_FILTER,MAP_STATIONS)
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

end
