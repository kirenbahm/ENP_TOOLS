function XLARRAY = load_XL_GRID(FILE_DFS, INI)

% Note: hardcode below requires Excel arrays to have at least 6 columns,
% otherwise the program will not append arrays and store data (usually
% this means that the SZunderRIV and OL2RIV will be missing)

% determine whether to use dfs2 sheets or dfs3 sheets
[~,~,FEXT] = fileparts(FILE_DFS);
if strcmp(FEXT,'.dfs2')
    FILE_SHEETNAMES = [INI.TRANSECT_DEFS_SHEETNAMES_OL];
end
if strcmp(FEXT,'.dfs3')
    FILE_SHEETNAMES = [INI.TRANSECT_DEFS_SHEETNAMES_3DSZQ];
end

% Load group definition data from Excel file
fprintf('%s Reading file: %s\n',datestr(now), char(INI.TRANSECT_DEFS_FILE));

% stn_counter_begin = 0;
% stn_counter_end = 0;
num_sheets = length(FILE_SHEETNAMES);

XLARRAY=[];
try
    for sheetnum = 1:num_sheets  % iterate through sheet names given in A0 setup script
        xlsheet = FILE_SHEETNAMES{sheetnum};
        [~,~,xldata] = xlsread(INI.TRANSECT_DEFS_FILE,xlsheet);
        [numrows,~] = size(xldata);
        
        % append array of numrows and 6 columns <== HARDCODED TO 6 COLUMNS
        % (hardcoded to make sure array sizes match and can be appended)
        XLARRAY = [XLARRAY;xldata(2:numrows,1:6)];
        
        %     stn_counter_begin = stn_counter_end + 1;
        %     stn_counter_end = stn_counter_end + (numrows - 1); % subtract 1 for header row
        %     MyRequestedStnNames(stn_counter_begin:stn_counter_end) = xldata(2:numrows,1);
        %     rows0(stn_counter_begin:stn_counter_end) = xldata(2:numrows,2);
        %     cols0(stn_counter_begin:stn_counter_end) = xldata(2:numrows,3);
        %     lyrs1(stn_counter_begin:stn_counter_end) = xldata(2:numrows,4);
        %     multip(stn_counter_begin:stn_counter_end) = xldata(2:numrows,5);
        %     itms1(stn_counter_begin:stn_counter_end) = xldata(2:numrows,6);
    end


catch
    fprintf('... Exception in load_XL_GRID\n');
end

end

