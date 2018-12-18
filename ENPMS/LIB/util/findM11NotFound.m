function [STATIONS_NOT_FOUND CHAINAGES_NOT_FOUND] = findM11NotFound(NAME_FOUND,SELECTED, mapM11chain)
%---------------------------------------------------------------------
% function INI = findM11NotFound(INI)
% The function extracts a list of M11 stations that were not mapped
%---------------------------------------------------------------------

L_NOT_FOUND = ismember(SELECTED,NAME_FOUND);
STATIONS_NOT_FOUND = SELECTED(~L_NOT_FOUND);

i = 0;
for K = STATIONS_NOT_FOUND
    i = i+1;
    if isKey(mapM11chain,char(K))
        CHAINAGES_NOT_FOUND(i) = mapM11chain(char(M11CHAIN));
    end 
end


end

