function INI = extractComputedData(INI)

% extractComputedData(INI) reads simulation data and saves all extracted
% data in .MATLAB files

%---------------------------------------------------------------------
%Additional set up of default files user should not modify aything below
%---------------------------------------------------------------------

%Create an excel log file for stations requested and matched to chainages
INI.LOG_XLSX = [INI.DATA_COMPUTED 'LOG.xlsx'];

%---------------------------------------------------------------------
%Iteration over all simulations
%---------------------------------------------------------------------

nn = length(INI.MODEL_SIMULATION_SET);

for i = 1:nn % This loop iterates over each simulation to extract data 
    INI.i_sim = i; % This is a counter which is used to specify the simulation from the list of simulations.     
    S = filesep; % file separator platform specific
    C = strsplit(INI.MODEL_SIMULATION_SET{i},S); % get path names
    INI.simMODEL =  char(C(end)); % use the last one for model name
    INI.MODEL = char(INI.simMODEL(1:3)); %( M01 M06 ) - this string should provide the model
    %INI.XLSCOMP = [INI.MODEL '_MODEL_COMP'];
    INI.XLSCOMP = ['M06_MODEL_COMP']; % M01_V10 uses the same grid as M06, so we hardcode all grids to M06 here
    INI.LOG_XLSX_SH = char(INI.simMODEL);
    INI.ALTERNATIVE = INI.simMODEL;

    INI.simRESULT = [INI.MODEL_SIMULATION_SET{i} '.she - Result Files\'];
    INI.DATABASE_COMP = char(strcat(INI.DATA_COMPUTED,'COMPUTED_',INI.simMODEL,'.MATLAB'));

    %INI.simRESULTmatlab = [INI.simRESULT 'matlab\'];

    % files for extracting computed data
    if INI.USE_RES11
        INI.fileM11WM      = [INI.simRESULT 'MSHE_WM.res11'];
        INI.fileM11WMHDAdd = [INI.simRESULT 'MSHE_WMHDAdd.res11'];
    else
        INI.fileM11WM      = [INI.simRESULT 'MSHE_WM.dfs0'];
    end
    
    INI.fileOL = char(strcat(INI.simRESULT, INI.simMODEL, '_overland.dfs2'));
    INI.fileSZ = char(strcat(INI.simRESULT, INI.simMODEL, '_3DSZ.dfs3'));

    INI.filePP = char(strcat(INI.simRESULT, INI.simMODEL, '_PreProcessed.DFS2'));

    % read excel file with coordinates
    INI = readFileCompCoord(INI);

    if ~exist(INI.DATA_COMPUTED, 'dir'), mkdir(char(INI.DATA_COMPUTED)),end

    if INI.SAVE_IN_MATLAB

        try
            INI = readM11_WM(INI);
        catch INI
            fprintf('\nException in readM11_WM(INI), i=%d\n', i);
            msgException = getReport(INI,'extended','hyperlinks','on')
        end

        try
            INI = readMSHE_WM(INI);
        catch INI
            fprintf('\nException in readMSHE_WM(INI), i=%d\n', i);
            msgException = getReport(INI,'extended','hyperlinks','on')
        end

        % TRANSECTS_MLAB
        if INI.READ_TRANSECTS_MLAB
            try
                INI.MAPXLS = INI.TRANSECT_DEFS_FILE;
                % how to save
                INI = extractTRANSECTS_MLAB(INI);
            catch INI
                fprintf('\nException in extractTRANSECTS_MLAB(INI), i=%d\n', i);
                msgException = getReport(INI,'extended','hyperlinks','on')
            end
        end

        mapCompSelected = INI.mapCompSelected;
        save(char(INI.DATABASE_COMP),'mapCompSelected','-v7.3');

    else
        load(char(INI.DATABASE_COMP), '-mat');
        INI.mapCompSelected = mapCompSelected;
    end

    if INI.PLOT_COMPUTED
        try
            ME = plot_all(INI);
        catch ME
            msgException = getReport(ME,'extended','hyperlinks','on')
        end
    end
end

% %include computing seepage
% % map of requested seepage, note the scripts are MAPF specfic because they
% % accumulate X and Y seepage values in specific way
% U.MAPF = [INI.DATA_COMMON 'SEEPAGE_MAP.dfs2'];;

%     INI.MAPXLS = INI.mapCompSelected; % needed for transect calculations

end
