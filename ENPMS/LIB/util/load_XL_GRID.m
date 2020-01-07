function XLARRAY = load_XL_GRID(FILE_DFS, INI)

% determine whether to use dfs2 sheets or dfs3 sheets
[~,~,FEXT] = fileparts(FILE_DFS);
if strcmp(FEXT,'.dfs2')
    FILE_SHEETNAMES = [INI.CELL_DEF_FILE_SHEETNAME_OL];
end
if strcmp(FEXT,'.dfs3')
    FILE_SHEETNAMES = [INI.CELL_DEF_FILE_SHEETNAME_3DSZQ];
end

% read monitoring points from excel file
try
    XLARRAY = read_XL_GRID(INI.TRANSECT,FILE_SHEETNAMES);
catch
    fprintf('... Exception in load_XL_GRID\n');
end

end

