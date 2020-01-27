function INI = convert_TRANSECT(INI, i)

% This function converts the Transect Timeseries to a Station representation
% to enable plotting and computing of transect data

M_ALL = INI.mapCompSelected;

M_OL = INI.TRANSECTS_MLAB.OL;
M_ALL = convert_map(INI, M_ALL, M_OL, i);

M_SZ = INI.TRANSECTS_MLAB.SZ;
M_ALL = convert_map(INI, M_ALL, M_SZ, i);

INI.mapCompSelected = M_ALL;

%S = M_ALL('T19');

end


