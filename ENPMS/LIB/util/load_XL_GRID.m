function XLARRAY = load_XL_GRID(FILE_DFS, INI)

FILE_DIR =  INI.CELL_DEF_FILE_DIR_3DSZQ;
FILE_NAME_GROUP_DEFS = INI.CELL_DEF_FILE_NAME_3DSZQ;

FILE_XL_GRID = [ FILE_DIR FILE_NAME_GROUP_DEFS '.xlsx'];
MATFILE = [ FILE_DIR FILE_NAME_GROUP_DEFS '.MATLAB'];

[DIR,FNAME,FEXT] = fileparts(FILE_DFS);
if strcmp(FEXT,'.dfs2')
    FILE_SHEETNAME = [INI.CELL_DEF_FILE_SHEETNAME_OL];
end
if strcmp(FEXT,'.dfs3')
    FILE_SHEETNAME = [INI.CELL_DEF_FILE_SHEETNAME_3DSZQ];
end

try
    % if there there is an existing MATLAB file read read XL file
    % if the user specifies this file to be regenerated read XL file
    % else load the MATLAB for faster
    
    if INI.OVERWRITE_GRID_XL | ~exist(MATFILE,'file')
        % read monitoring points from excel file, slower process
        XLARRAY = read_XL_GRID(FILE_XL_GRID,FILE_SHEETNAME);
        %save the file in a structure for reading
        fprintf('\n--- Saving Gridded XL data in: %s\n', char(MATFILE))
        MAPXLS = INI.MAPXLS
        save(MATFILE,'XLARRAY','-v7.3');
    else
        % load Monitoring point data from MATLAB for faster processing
        fprintf('\n--- Loading Gridded XL data from: %s\n', char(MATFILE))
        load(MATFILE, '-mat');
    end
catch
    fprintf('... Exception in load_XL_GRIDDED(), %s .xlsx and .MATLAB files missing \n', ...
        char(FILE_NAME_GROUP_DEFS));
end

end

