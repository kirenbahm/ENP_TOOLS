function A1_load_computed_timeseries(INI)

%---------------------------------------------
% FUNCTION DESCRIPTION:
%
% This function reads MIKESHE and MIKE11 raw output files and saves
%   selected items into a .MATLAB file.
% The data is saved as 1-dimensional daily timeseries, and currently only
%   saves the last timestep of each day.
% Currently it can read all dfs0 files, and some dfs2 file.
% Can read dfs3 files but is HARDCODED to read only the FIRST LAYER.
% The data saved into the .MATLAB file is in  the form of a container,
%   called MAP_ALL_DATA, that uses the station names as keys.
% Data saved into the container for each station can be found in the
%   function called read_computed_timeseries.
% This function also will load the observed data (previously stored in amother
%   .MATLAB file) and save it with the modeled data.
%
% BUGS:
% COMMENTS:
%
%----------------------------------------
% REVISION HISTORY:
%
%----------------------------------------

fprintf('\n\n Beginning A1_load_computed_timeseries(): %s \n\n',datestr(now));
format compact

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load the file with elevation data
% MAP_ELEVATIONS are stored in the .matlab file
% % fprintf('... Loading elevations:\n %s\n', char(INI.FILE_ELEVATION));
% % load(INI.FILE_ELEVATION,'-mat');

%load the file with observed data

FILE_OBSERVED = INI.FILE_OBSERVED;
fprintf('... Loading observed data from file:\n\t %s\n', char(INI.FILE_OBSERVED));
DATA_OBSERVED = load(FILE_OBSERVED, '-mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Read all files as specified in MODEL_ALL_RUNS and make a structure
%for each station. The structures are stored in a map with station name as
%MAP KEY and computed+observed data as MAP VALUE. The structure is accessed
%by providing the key as a character string e.g. D = MAP_ALL_DATA('NP205')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Iterate over selected model runs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i = 0; % Initialize model run counter

for D = INI.MODEL_ALL_RUNS
    
    i = i + 1; % Increment model run counter
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set model output directory and filenames
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    MODEL_RESULT_DIR = INI.MODEL_FULLPATH{i};
    FILE_MOLUZ         = [MODEL_RESULT_DIR '/' char(D) 'DetailedTS_OL.dfs0']; %MIKE 2014 filename
    if ~exist(FILE_MOLUZ,'file')
        FILE_MOLUZ       = [MODEL_RESULT_DIR '/' char(D) 'DetailedTS.dfs0']; %MIKE 2011 filename
    end
    FILE_M11           = [MODEL_RESULT_DIR '/' char(D) 'DetailedTS_M11.dfs0'];
    FILE_MSHE          = [MODEL_RESULT_DIR '/' char(D) 'DetailedTS_SZ.dfs0'];
    FILE_OL            = [MODEL_RESULT_DIR '/' char(D) '_overland.dfs2'];
    FILE_3DSZ          = [MODEL_RESULT_DIR '/' char(D) '_3DSZ.dfs3'];
    FILE_3DSZQ         = [MODEL_RESULT_DIR '/' char(D) '_3DSZflow.dfs3'];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load model output data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Load DetailedTS_OL data
    L = INI.LOAD_MOLUZ;
    MAP_COMPUTED_MOLUZ_DATA(i) = load_TS_OL (L,MODEL_RESULT_DIR,FILE_MOLUZ);
        
    % Load DetailedTS_M11 data
    L = INI.LOAD_M11;
    MAP_COMPUTED_M11_DATA(i) = load_TS_M11(L,MODEL_RESULT_DIR,FILE_M11);
    
    % Load DetailedTS_SZ data
    L = INI.LOAD_MSHE;
    MAP_COMPUTED_MSHE_DATA(i) = load_TS_MSHE(L,MODEL_RESULT_DIR,FILE_MSHE);
        
    % Load and group OL gridded data
    L = INI.LOAD_OL;
    MAP_COMPUTED_OL_DATA(i) = load_OL_GRIDDED(L,INI,MODEL_RESULT_DIR,FILE_OL);
    
    % Load and group 3DSZQ gridded data
    L = INI.LOAD_3DSZQ;
    MAP_COMPUTED_3DSZQ_DATA(i) = load_SZ_GRIDDED(L,INI,MODEL_RESULT_DIR,FILE_3DSZQ);
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% combine all above data arrays into one container, and trim or expand 
% dates to requested start-end times

MAP_COMPUTED = combine_computed(...
    MAP_COMPUTED_MOLUZ_DATA, ...
    MAP_COMPUTED_M11_DATA, ...
    MAP_COMPUTED_MSHE_DATA, ...
    MAP_COMPUTED_OL_DATA, ...
    MAP_COMPUTED_3DSZQ_DATA, ...
    INI);
%   INI.ANALYZE_DATE_I, INI.ANALYZE_DATE_F); 
%for new - CHANGE TO DFS BEGINDAY AND DFS END DAY%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add observed data and elevations to container if we extracted them
MAP_ALL_DATA = add_observed(INI,MAP_COMPUTED,DATA_OBSERVED.DATA);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save the structures which are subsequently used in other postprocessing
%scripts. The data are accessed using load(INI.FILESAVE_TS);

fprintf('\n... Completed A1_load_computed_timeseries() \n')
fprintf('... Creating and saving data file:\n\t %s\n', char(INI.FILESAVE_TS));
save(INI.FILESAVE_TS,'MAP_ALL_DATA', '-v7.3');

fclose('all');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MAP_COMPUTED_3DSZQ_DATA = load_SZ_GRIDDED(L,INI,MODEL_RESULT_DIR,FILE_3DSZQ)

MAP_COMPUTED_3DSZQ = 0;
if L
    MAP_COMPUTED_3DSZQ = {get_GRIDDED_DATA(FILE_3DSZQ,INI)};
%     MAP_COMPUTED_3DSZQ = {read_and_group_computed_timeseries(FILE_3DSZQ,...
%         INI.CELL_DEF_FILE_DIR_3DSZQ,INI.CELL_DEF_FILE_NAME_3DSZQ,...
%         INI.CELL_DEF_FILE_SHEETNAME_3DSZQ)};
    if ~exist([MODEL_RESULT_DIR '/matlab'],'file'),  ...
            mkdir([MODEL_RESULT_DIR '/matlab']), end
    save([MODEL_RESULT_DIR '/matlab/MAP_COMPUTED_3DSZQ.MATLAB'],...
        'MAP_COMPUTED_3DSZQ', '-v7.3');
    MAP_COMPUTED_3DSZQ_DATA = MAP_COMPUTED_3DSZQ;
else
    try
        load([MODEL_RESULT_DIR '/matlab/MAP_COMPUTED_3DSZQ.MATLAB'],'-mat');
        MAP_COMPUTED_3DSZQ_DATA=MAP_COMPUTED_3DSZQ;
    catch
        MAP_COMPUTED_3DSZQ_DATA = 0;
        fprintf('\n... Exception in load_SZ_GRIDDED() \n')
        fprintf('\n... -> MAP_COMPUTED_3DSZQ.MATLAB not loaded, continuing with MAP_COMPUTED_3DSZQ_DATA = 0 \n')
    end;
end


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MAP_COMPUTED_OL_DATA = load_OL_GRIDDED(L,INI,MODEL_RESULT_DIR,FILE_OL)

MAP_COMPUTED_OL_DATA = 0;
if L
    MAP_COMPUTED_OL = {get_GRIDDED_DATA(FILE_OL,INI)};
    if ~exist([MODEL_RESULT_DIR '/matlab'],'file'),  ...
            mkdir([MODEL_RESULT_DIR '/matlab']), end
%         MAP_COMPUTED_OL = {read_and_group_computed_timeseries...
%             (FILE_OL,INI.CELL_DEF_FILE_DIR_OL,INI.CELL_DEF_FILE_NAME_OL,...
%             INI.CELL_DEF_FILE_SHEETNAME_OL)};
    save([MODEL_RESULT_DIR '/matlab/MAP_COMPUTED_OL.MATLAB'],...
        'MAP_COMPUTED_OL', '-v7.3');
    MAP_COMPUTED_OL_DATA = MAP_COMPUTED_OL;
else
    try
        load([MODEL_RESULT_DIR '/matlab/MAP_COMPUTED_OL.MATLAB'],'-mat');
        MAP_COMPUTED_OL_DATA=MAP_COMPUTED_OL;
    catch
        fprintf('\n... Exception in load_OL_GRIDDED()')
        fprintf('\n... -> MAP_COMPUTED_OL.MATLAB not loaded, continuing with MAP_COMPUTED_OL_DATA = 0 \n')
    end;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MAP_COMPUTED_MOLUZ_DATA = load_TS_OL (L,MODEL_RESULT_DIR,FILE_MOLUZ)

MAP_COMPUTED_MOLUZ = 0;
% reads computed overland timeseries
if L
    MAP_COMPUTED_MOLUZ = {read_computed_timeseries(FILE_MOLUZ)};
    if ~exist([MODEL_RESULT_DIR '/matlab'],'file')
        mkdir([MODEL_RESULT_DIR '/matlab'])
    end
    save([MODEL_RESULT_DIR '/matlab/MAP_COMPUTED_MOLUZ.MATLAB'],...
        'MAP_COMPUTED_MOLUZ', '-v7.3');
    MAP_COMPUTED_MOLUZ_DATA = MAP_COMPUTED_MOLUZ;
else
    try
        load([MODEL_RESULT_DIR '/matlab/MAP_COMPUTED_MOLUZ.MATLAB'],'-mat');
        MAP_COMPUTED_MOLUZ_DATA = MAP_COMPUTED_MOLUZ;
    catch
        MAP_COMPUTED_MOLUZ_DATA = 0;
        fprintf('\n... Exception in load_TS_OL() \n')
    end;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MAP_COMPUTED_M11_DATA = load_TS_M11 (L,MODEL_RESULT_DIR,FILE_M11)

MAP_COMPUTED_M11_DATA = 0;
% reads computed M11 timeseries
if L
    MAP_COMPUTED_M11 = {read_computed_timeseries(FILE_M11)};
    if ~exist([MODEL_RESULT_DIR '/matlab'],'file'),  mkdir([MODEL_RESULT_DIR '/matlab']), end
    save([MODEL_RESULT_DIR '/matlab/MAP_COMPUTED_M11.MATLAB'],'MAP_COMPUTED_M11', '-v7.3');
    MAP_COMPUTED_M11_DATA = MAP_COMPUTED_M11;
else
    try
        load([MODEL_RESULT_DIR '/matlab/MAP_COMPUTED_M11.MATLAB'],'-mat');
        MAP_COMPUTED_M11_DATA=MAP_COMPUTED_M11;
    catch
        MAP_COMPUTED_M11_DATA = 0;
        fprintf('\n... Exception in load_TS_OL() \n')
    end;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MAP_COMPUTED_MSHE_DATA = load_TS_MSHE (L,MODEL_RESULT_DIR,FILE_MSHE)

MAP_COMPUTED_MSHE_DATA = 0;
% reads computed MSHE timeseries

if L
    MAP_COMPUTED_MSHE = {read_computed_timeseries(FILE_MSHE)};
    if ~exist([MODEL_RESULT_DIR '/matlab'],'file'),  mkdir([MODEL_RESULT_DIR '/matlab']), end
    save([MODEL_RESULT_DIR '/matlab/MAP_COMPUTED_MSHE.MATLAB'],'MAP_COMPUTED_MSHE', '-v7.3');
    MAP_COMPUTED_MSHE_DATA = MAP_COMPUTED_MSHE;
else
    try
        load([MODEL_RESULT_DIR '/matlab/MAP_COMPUTED_MSHE.MATLAB'],'-mat');
        MAP_COMPUTED_MSHE_DATA=MAP_COMPUTED_MSHE;
    catch
        MAP_COMPUTED_MSHE_DATA = 0;
        fprintf('\n... Exception in load_TS_OL() \n')
    end;
end
end
