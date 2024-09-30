function INI = extractComputedData(INI)

% extractComputedData(INI) reads simulation data and saves all extracted
% data in .MATLAB files

%---------------------------------------------------------------------
% Additional set up of default files (user should not modify aything below)
%---------------------------------------------------------------------

% Create an excel log file for stations requested and matched to chainages
INI.LOG_XLSX = [INI.DATA_COMPUTED 'LOG.xlsx'];

%---------------------------------------------------------------------
% Iteration over all simulations
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

    %% Set model output files for extracting computed data
    INI.simRESULT         = [INI.MODEL_SIMULATION_SET{i} '.she - Result Files\'];
    
    INI.fileOL            = [INI.simRESULT INI.simMODEL, '_overland.dfs2'];
    INI.fileSZ            = [INI.simRESULT INI.simMODEL, '_3DSZ.dfs3'];
    INI.filePhreatic      = [INI.simRESULT INI.simMODEL, '_2DSZ.dfs2'];
    INI.fileBottomLevels  = [INI.simRESULT INI.simMODEL, '_PreProcessed_3DSZ.dfs3'];
    INI.fileM11Dfs0       = [INI.simRESULT 'MSHE_WM.dfs0'];
    INI.fileM11Res11      = [INI.simRESULT 'MSHE_WM.res11'];
    INI.fileM11Res1d      = [INI.simRESULT 'MSHE_WM.res1d'];
    INI.filePP = char(strcat(INI.simRESULT, INI.simMODEL, '_PreProcessed.DFS2'));
	
    %% determine existence of 1D channel flow output files (res1d, res11, or dfs0)

    if exist(INI.fileM11Dfs0,'file') % If the dfs0 file exists...
       if dir(INI.fileM11Dfs0).bytes ~= 0 % ...and isn't empty
           dfs0Exists  = true;
       else % dfs0 file is size 0, don't read
           dfs0Exists  =  false;
       end
    else % dfs0 file doesn't exist, don't read
        dfs0Exists  = false;
    end

    if exist(INI.fileM11Res11, 'file') % If the res11 file exists...
        if dir(INI.fileM11Res11).bytes ~= 0 % ...and isn't empty
            res11Exists =  true;
        else % res11 file is size 0, don't read
            res11Exists =  false;
        end
    else % res11 file doesn't exist, don't read
        res11Exists =  false;
    end

    if exist(INI.fileM11Res1d, 'file')% If the res1d file exists
        if dir(INI.fileM11Res1d).bytes ~= 0 % ...and isn't empty
            res1dExists =  true;
        else % res1d file is size 0, don't read
            res1dExists =  false;
        end
    else % res1d file doesn't exist, don't read
        res1dExists =  false;
    end
    
    %% set up stats variable and directory
    INI.MODEL_STATS = [INI.STAT_OUTPUTS INI.simMODEL];
    if ~exist(INI.MODEL_STATS, 'dir')
        mkdir(INI.MODEL_STATS)
    end

    %% determine existence of gridded depth output file. 
    % If file doesn't
    % exist, read the gridded stage output file and the gridded topo
    % preprocessed file and generate a gridded depth file which will be
    % used in the depth and hydroperiod maps generated later
    % If '_2DSZ.dfs2' does not exist, then generate the depth values based
    % on head values, topography and, if file exists, the bottom elevations.
    % Note: it would be better to move this section to a different script
    % and execute only if map files are generated. Check if this is
    % feasable and doesn't mess up anything else in the scripts

%     %%%%% this process can take a while, so I frequently comment it out
%
    if ~exist(INI.filePhreatic, 'file')
        ComputeDepthOfPhreaticSurface(INI);
    end
    if exist(INI.filePhreatic, 'file')
        %Compute Monthly Stage
        INI.fileMonthlyStats = [INI.MODEL_STATS, '\' INI.simMODEL '_MonthlyStats.dfs2'];
        ComputeMonthlyStatistics(INI);
        if exist(INI.fileMonthlyStats, 'file')
            %Compute Wet/Dry Season
            INI.fileWetDrySeasonStats = [INI.MODEL_STATS,'\' INI.simMODEL '_WetDryStats.dfs2'];
            ComputeWetDrySeasonStatistics(INI);
        end
        %Compute Calendar Years
        INI.fileCalendarYearStats = [INI.MODEL_STATS,'\' INI.simMODEL '_CalYearStats.dfs2'];
        ComputeCalendarYearStatistics(INI);
        %Computer Water Years
        INI.fileWaterYearStats = [INI.MODEL_STATS,'\' INI.simMODEL '_WaterYearStats.dfs2'];
        ComputeWaterYearStatistics(INI);
        %Compute Total Period
        INI.fileTotalSimulationPeriodStats = [INI.MODEL_STATS, '\' INI.simMODEL '_TotalSimulationPeriodStats.dfs2'];
        ComputeTotalSimulationPeriodStatistics(INI);
    else
        fprintf('ERROR %s Not found. Cannot generate Statistics.\n', INI.filePhreatic);
    end
    
    %% Determine which column in the Excel spreadsheet to read chainages from, and read
    %   Col 24 is for reading res11 and res1d files, q points are reported at q-point locations
    %   Col 17 is for reading dfso files, q-points are reported at h-point locations
    if (INI.USE_RES1D)
        INI.M11_CHAINAGES_COLUMN = int16(24);
    elseif (INI.USE_RES11)
        INI.M11_CHAINAGES_COLUMN = int16(24);
    elseif (INI.USE_DFS0)
        INI.M11_CHAINAGES_COLUMN = int16(17);
    else
        fprintf('\nException in extractComputedData - Could not determine M11_CHAINAGES_COLUMN');
        msgException = getReport(ME,'extended','hyperlinks','on')
    end
    
    % read excel file with coordinates
    INI = readFileCompCoord(INI);

    %% do something
    INI.DATABASE_COMP = char(strcat(INI.DATA_COMPUTED,'COMPUTED_',INI.simMODEL,'.MATLAB'));

    %% create output directory if needed
    if ~exist(INI.DATA_COMPUTED, 'dir'), mkdir(char(INI.DATA_COMPUTED)),end

    %% get data from model output files or pre-saved matlab file
    if INI.SAVE_IN_MATLAB

        %% Read 1-D data
        try
            INI = readM11_WM(INI,res11Exists,dfs0Exists,res1dExists);
        catch ME
            fprintf('\nException in readM11_WM(INI), i=%d\n', i);
            msgException = getReport(ME,'extended','hyperlinks','on')
        end

        %% Read MSHE stage data from dfs3 file
        try
            INI = readMSHE_WM(INI);
        catch ME
            fprintf('\nException in readMSHE_WM(INI), i=%d\n', i);
            msgException = getReport(ME,'extended','hyperlinks','on')
        end

        %% Read TRANSECTS flow data from dfs2 and dfs3 files
        if INI.READ_TRANSECTS_MLAB
            try
                INI.MAPXLS = INI.TRANSECT_DEFS_FILE;
                % how to save
                INI = extractTRANSECTS_MLAB(INI);
            catch ME
                fprintf('\nException in extractTRANSECTS_MLAB(INI), i=%d\n', i);
                msgException = getReport(ME,'extended','hyperlinks','on')
            end
        end

        %% Move data to the INI variable
        mapCompSelected = INI.mapCompSelected;

        %% Perform aggregation operations on data and save to INI
        INI = Aggregate_Station_Data(INI);

        %% Save complete INI dataset to file
        save(char(INI.DATABASE_COMP),'mapCompSelected','-v7.3');

    %% If you didn't read data from model output files directly, load a pre-saved version here
    % (this is not really used anymore - could delete this 'if-else' section)
    else
        load(char(INI.DATABASE_COMP), '-mat');
        INI.mapCompSelected = mapCompSelected;
    end
    
    %% Plot all the timeseries if requested (usually not used - plotting performed later in scripts)
    if INI.PLOT_COMPUTED
        try
            ME = plot_all(INI);
        catch ME
            msgException = getReport(ME,'extended','hyperlinks','on')
        end
    end
end

% % include computing seepage (not implemented)
% % map of requested seepage, note the scripts are MAPF specfic because they
% % accumulate X and Y seepage values in specific way
% U.MAPF = [INI.DATA_COMMON 'SEEPAGE_MAP.dfs2'];;

end
