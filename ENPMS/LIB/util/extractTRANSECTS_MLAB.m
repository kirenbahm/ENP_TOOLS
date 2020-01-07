function INI = extractTRANSECTS_MLAB(INI)

INI.OVERWRITE_GRID_XL = 1; % this regenerates the gridded points from
%                             the corresponding EXCEL file. If this is 0
%                            monitoring points come from a matlab data file
%                            the same as the excel file but ext .MATLAB

i = INI.i_sim; % this counter is used to set up simulation variablles
for D = INI.MODEL_SIMULATION_SET(i)

    TRANSECT_FILE = [INI.MODEL_SIMULATION_SET{i} '_TRANSECT.MATLAB'];
    MODEL_RESULT_DIR = INI.MODEL_SIMULATION_SET{i};
    [D1 D2 D3] = fileparts(char(D));
    P1 = [char(D) '.she - Result Files/' char(D2)];
    FILE_OL  = [P1 '_overland.dfs2'];
    FILE_3DSZ = [P1 '_3DSZ.dfs3'];
    FILE_3DSZQ = [P1 '_3DSZflow.dfs3'];
    % Suggested changes: Assertians and file patsh should be moved to the
    % very begining of the code along with the other assertions
    assert(exist(FILE_OL,'file') == 2, 'File not found.' );
    assert(exist(FILE_3DSZQ,'file') == 2, 'File not found.' );

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load model output data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Load and group OL gridded data
    L = INI.LOAD_OL;
    MAP_TRANSECT.OL = load_OL_GRIDDED(L,INI,MODEL_RESULT_DIR,FILE_OL);
    if INI.DEBUG
        DDA = MAP_TRANSECT.OL; %get the map
        K = keys(DDA); % list all keys
        S = DDA('T18-OL'); % print one of the keys
    end
    % Load and group 3DSZQ gridded data
    L = INI.LOAD_3DSZQ;
    MAP_TRANSECT.SZ = load_SZ_GRIDDED(L,INI,MODEL_RESULT_DIR,FILE_3DSZQ);

    if INI.DEBUG
        DDA = MAP_TRANSECT.SZ; %get the map
        K = keys(DDA); % list all keys
        S = DDA('T19'); % print one of the keys
    end
    INI.TRANSECTS_MLAB = MAP_TRANSECT;
    INI = convert_TRANSECT(INI, i);
    save(char(TRANSECT_FILE),'MAP_TRANSECT','-v7.3');

end
end

