function  mapM11chain = getMapM11Chainages(INI)

 % create a map of chainages with Station Names as values
KEYS = INI.mapCompSelected.keys;
mapM11chain = containers.Map;
i = 0;
for K = KEYS
    STATION = INI.mapCompSelected(char(K));
    if isempty(STATION.M11CHAIN), continue, end
    i = i + 1;
    M11CHAIN = STATION.M11CHAIN;
    M11CHAIN = strrep(M11CHAIN,' ','');
    STR_TEMP = strsplit(M11CHAIN,';');
    N = str2num(STR_TEMP{2});
    NSTR = sprintf('%.0f',N);
    M11CHAIN = [STR_TEMP{1} ';' NSTR ';' STR_TEMP{3}];
    mapM11chain(char(M11CHAIN)) = K;
    XSEL{i} = M11CHAIN;
end


 end

