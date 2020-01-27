function MAP_COMPUTED_OL = load_OL_GRIDDED(L,INI,FILE_OL)

MAP_COMPUTED_OL = containers.Map();

ML_FILE = [INI.simRESULTmatlab '/MAP_COMPUTED_OL.MATLAB'];
if ~exist(INI.simRESULTmatlab,'file')
    L = 0; % if directory doesnt exist, regenerate the matlab TRANSECT data
    mkdir(char(INI.simRESULTmatlab));
end

if ~L
    MAP_COMPUTED_OL = get_GRIDDED_DATA(FILE_OL,INI);
    save(char(ML_FILE), 'MAP_COMPUTED_OL', '-v7.3');
else
    try
        load(char(ML_FILE),'-mat');
    catch
        fprintf('\n... Exception in load_OL_GRIDDED()');
        fprintf('\n... -> MAP_COMPUTED_OL.MATLAB not loaded, continuing with MAP_COMPUTED_OL = 0 \n');
    end
end

end

