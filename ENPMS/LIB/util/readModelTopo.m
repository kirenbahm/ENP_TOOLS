function [modelTopo, dfs2TopoFile] = readModelTopo(INI)
% This function reads the _PreProcessed.dfs2 file to extract the Model Topography and File Metadata 

% Import Statements
NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfs123.*;
if ~exist(INI.filePP,'file')
    fprintf('ERROR: INI.filePP file was not found at %s.\n',char(INI.filePP));
    return;
end

% Open topography file and save metadata
dfs2TopoFile  = Dfs2File(DfsFileFactory.DfsGenericOpen(INI.filePP));
search = '';
itemTopo = -1;
% Find surface topography item
field = System.String('Surface topography');
while ~strcmp(char(search), char(field))  && itemTopo < dfs2TopoFile.ItemInfo.Count - 1
    itemTopo = (itemTopo + 1);
    search = dfs2TopoFile.ItemInfo.Item(itemTopo).Name;
end
modelTopo = dfs2TopoFile.ReadItemTimeStep(itemTopo + 1, 0);
dfs2TopoFile.Close();
end