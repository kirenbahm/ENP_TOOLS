function D09_printCoordsObservedMatlab()

% This function creates MATLAB data file with observed data
%   and creates a database of all observed based on the sheet
%   M06_MODEL_COMP. The function does not include files which are not in
%   the sheet and does not include stations without data. The idea is to
%   generate observed data which is within the domain and will be used for
%   comparison

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% BEGIN USER INPUT
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% Input directory and names of subdirectories containing dfs0 files
INI.DIR_H_DFS0_FILES = '../../Obs_Processed_MATLAB/in/Stage/DFS0DD/';
INI.DIR_Q_DFS0_FILES = '../../Obs_Processed_MATLAB/in/Flow/DFS0DD/';

FILE_FILTER = '*.dfs0';   % File extension filter for input files

% Location of database file to be created
DATABASE_OBS_FOLDER = '../../Obs_Processed_MATLAB/out/';

% Location of ENPMS Scripts and Initialize
INI.MATLAB_SCRIPTS = '../ENPMS/';

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% END USER INPUT
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% add tools to path
%Initialize .NET libraries
try
    addpath(genpath(INI.MATLAB_SCRIPTS));
catch
    addpath(genpath(INI.MATLAB_SCRIPTS,0));
end

try 
    % needed for 2019 version
    dmi = NET.addAssembly('DHI.Mike.Install');
    if (~isempty(dmi))
        DHI.Mike.Install.MikeImport.SetupLatest({DHI.Mike.Install.MikeProducts.MikeCore});
    end
    %NET.addAssembly('C:\Users\georg\Desktop\01M06CAL\ENP_TOOLS\ENPMS\LIB\DHI\mbin\DHI.Mike.Install.dll');
catch ex
    %ex.ExceptionObject.LoaderExceptions.Get(0).Message
end

NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfs0.*;

% read all stations
LIST_DFS0 = [INI.DIR_H_DFS0_FILES FILE_FILTER];
LISTING_H  = dir(char(LIST_DFS0));

LIST_DFS0 = [INI.DIR_Q_DFS0_FILES FILE_FILTER];
LISTING_Q  = dir(char(LIST_DFS0));

% concatenate all structures and save into DATA variable
LISTINGS = [LISTING_H; LISTING_Q];

num_stations = size(LISTINGS, 1);

fprintf('\n\n');

for i = 1:num_stations
    myStation = LISTINGS(i);
    FILENAME = myStation.name;
    FOLDER   = myStation.folder;
    FILEPATH = [FOLDER '\' FILENAME];
    
    dfs0File  = DfsFileFactory.DfsGenericOpen(FILEPATH);
    
    for i = 0:dfs0File.ItemInfo.Count - 1
        DFS0.NAME(i+1)           = {char(dfs0File.ItemInfo.Item(i).Name)};
        DFS0.TYPE(i+1)           = {char(dfs0File.ItemInfo.Item(i).Quantity.ItemDescription)};
        DFS0.UNIT(i+1)           = {char(dfs0File.ItemInfo.Item(i).Quantity.UnitAbbreviation)};
        DFS0.utmXmeters(i+1)     = dfs0File.ItemInfo.Item(i).ReferenceCoordinateX;
        DFS0.utmYmeters(i+1)     = dfs0File.ItemInfo.Item(i).ReferenceCoordinateY;
        DFS0.elev_ngvd29_ft(i+1) = dfs0File.ItemInfo.Item(i).ReferenceCoordinateZ;
    end
    
    dfs0File.Close();
    
    fprintf('%s,%.0f,%.0f,%.2f\n', char(DFS0.NAME), DFS0.utmXmeters, DFS0.utmYmeters, DFS0.elev_ngvd29_ft);
    
end
fprintf('\n\n');


end

