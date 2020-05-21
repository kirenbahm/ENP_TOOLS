function TS = get_TS_GRIDini(FILE_DFS)

%fprintf('%s Reading file: %s\n',datestr(now), char(FILE_DFS));
[~,~,EXT] = fileparts(FILE_DFS);

try
    if strcmp(EXT,'.dfs2')
        TS = iniDFS2(FILE_DFS);
    end

    if strcmp(EXT,'.dfs3')
        TS = iniDFS3(FILE_DFS);
    end

catch
    fprintf('\nException in get_TS_GRIDini reading .dfs2, or .dfs3: %s\n', char(FILE_DFS));
end

end

