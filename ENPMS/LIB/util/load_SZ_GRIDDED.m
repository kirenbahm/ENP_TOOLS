function MAP_COMPUTED_3DSZQ = load_SZ_GRIDDED(L,INI,FILE_3DSZQ)

MAP_COMPUTED_3DSZQ = containers.Map();

ML_FILE = [INI.simRESULTmatlab '/MAP_COMPUTED_3DSZQ.MATLAB'];
if ~exist(INI.simRESULTmatlab,'file')
    L = 0; % if directory doesnt exist, regenerate the matlab TRANSECT data
    mkdir(char(INI.simRESULTmatlab));
end

if ~L
    MAP_COMPUTED_3DSZQ = get_GRIDDED_DATA(FILE_3DSZQ,INI);
    save(char(ML_FILE), 'MAP_COMPUTED_3DSZQ', '-v7.3');
else
    try
        load(char(ML_FILE),'-mat');
    catch
        fprintf('\n... Exception in load_SZ_GRIDDED() \n');
        fprintf('\n... -> MAP_COMPUTED_3DSZQ.MATLAB not loaded, continuing with MAP_COMPUTED_3DSZQ = 0 \n');
    end
end

end

