function INI = BC2D_import_dfs0(INI)

% Select Hourly or Daily dfs0 files
if strcmpi(INI.OLorSZ,'OL') 
    FILE_FILTER = 'DFS0HR/*.dfs0'; % list only files with extension .out
elseif strcmpi(INI.OLorSZ,'SZ')
    FILE_FILTER = 'DFS0DD/*.dfs0'; % list only files with extension .out
end

%INI.DIR_DFS0_FILES = [INI.CURRENT_PATH DIR];
%LIST_DFS0_F = [INI.DIR_DFS0_FILES FILE_FILTER];
LIST_DFS0_F = [INI.STAGE_DIR FILE_FILTER];
INI.LISTING = dir(char(LIST_DFS0_F));
% iterate over all files
INI = BC2D_process_dfs0file_list(INI);
% set a map with all files
end