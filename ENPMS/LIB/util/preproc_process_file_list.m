function preproc_process_file_list(INI,MAP_STATIONS,LISTING,DType_Flag)
% This script takes data that was read and flagged from DFE .dat files 
% and prepares to write to a dfs0 file. 
%
% Inputs:
% INI stores global parameters like directories and flag checks.
%
% MAP_STATIONS holds data on all stations in database.
%
% LISTING array of file information for dat files
%
% DType_Flag is used to determine which DHI specific variables and settings
% are to be used in the creation of the DFS0 files. If additional datatypes
% are added (i.e. salinity, PET, ET, and/or etc...) accompanying elseif
% statements for U, itemDHI, and unitDHI must be included here.

n = length(LISTING);
for i = 1:n
    try
       % iterate through each item in LISTING struc array (created by 'dir' matlab function)
        s = LISTING(i);
        
        % pull out path and filename
        NAME = s.name; % get filename
        fprintf('... processing %d/%d: ', i, n);
        FOLDER = s.folder; % get folder name
        FILE_NAME = [FOLDER '\' NAME];
        myFILE = char(FILE_NAME);
        
        % read DFE data file into DATA structure
        fprintf('reading %s... ', char(NAME));
        
        [DATA] = preproc_read_DFE_file(myFILE);

        % extract filename parts, convert station part of name to upper case
        [~,B,~] = fileparts(FILE_NAME);
        splitFilename=split(B,'.');
        %uppercaseName=upper(splitFilename(1));
        uppercaseFileName=[upper(char(splitFilename(1))) '.' char(splitFilename(2))]; 

        %create dfs0 file
        fprintf('writing %s.dfs0... ', uppercaseFileName);
        DFS0name = [INI.DIR_DFS0_FILES uppercaseFileName];        
        preproc_create_DFS0(INI,MAP_STATIONS,DATA,DFS0name,DType_Flag);
        
        % save dataset in MATLAB format (if desired)
        %FNDB = strcat(DFS0N,'.MATLAB');
        %if INI.SAVE_IN_MATLAB, save(char(FNDB),'S1','-v7.3'), end 

        fprintf(' success \n');
    catch
        fprintf('  *** FAILED ***\n');
    end
fclose('all');
end
