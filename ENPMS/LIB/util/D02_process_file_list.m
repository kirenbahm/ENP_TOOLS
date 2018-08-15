function D02_process_file_list(INI,LISTING,DType_Flag)

% DType_Flag is used to determine which DHI specific variables and settings
% are to be used in the creation of the DFS0 files. If additional datatypes
% are added (i.e. salinity, PET, ET, and/or etc...) accompanying elseif
% statements for U, itemDHI, and unitDHI must be included here.

n = length(LISTING);
for i = 1:n
    try
        s = LISTING(i);
        NAME = s.name;
        FOLDER = s.folder;
        FILE_NAME = [FOLDER '\' NAME];
        FILE_ID = fopen(char(FILE_NAME));
        fprintf('... processing: %d/%d: %s \n', i, n, char(FILE_NAME));
        
        % read database file
        [DATA,~,~] = D03_read_DFE_file(FILE_ID);
        
        %create dfs0 file
        [~,B,~] = fileparts(FILE_NAME);
        DFS0N = [INI.DIR_DFS0_FILES B];        
        D04_create_DFS0(INI,DATA,DFS0N,DType_Flag);
        
%        FNDB = strcat(DFS0N,'.MATLAB');
%         if SAVE_IN_MATLAB, save(char(FNDB),'S1','-v7.3'), end 

    catch
        fprintf('... exception in: %d/%d: %s \n', i, n, char(FILE_NAME));
    end
fclose('all');
end
