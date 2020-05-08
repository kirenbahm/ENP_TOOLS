function TS = get_TS_GRID(FILE_DFS)

%fprintf('%s Reading file: %s\n',datestr(now), char(FILE_DFS));
[DIR,FNAME,EXT] = fileparts(FILE_DFS);

try
    if strcmp(EXT,'.dfs2')
        TS = InputDFS2(FILE_DFS);
    end
    
    if strcmp(EXT,'.dfs3')
        TS = InputDFS3v1(FILE_DFS);
    end
    
    if isempty(TS)
        fprintf('\nWARNING - file extension not .dfs2, or .dfs3: %s\n', char(FILE_DFS));
        fprintf('read_and_group_computed_timeseries cannot handle this type of file yet: %s\n', char(FILE_DFS));
        return;
    end
    
catch
    fprintf('\nException in get_TS_GRID reading .dfs2, or .dfs3: %s\n', char(FILE_DFS));
    
end
end

