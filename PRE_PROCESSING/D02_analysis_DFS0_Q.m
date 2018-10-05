function D02_analysis_DFS0_Q()
% Script reads dfs0 files and provides analysis and figures along with CDF
% PE, monthly and annual summaries

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% BEGIN USER INPUT
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% Location of dfs0 FLOW files 
INI.DIR_FILES           = '../../ENP_TOOLS_Sample_Input/Obs_Data_Processed/D01_FLOW/';

INI.DIR_FLOW_DFS0       = [INI.DIR_FILES 'DFS0/'];
INI.DIR_FLOW_PNGS       = [INI.DIR_FILES 'DFS0_pngs/'];
INI.FLOW_LATEX_FILENAME = [INI.DIR_FILES 'FLOW.tex'];
INI.FLOW_LATEX_HEADER   = 'FLOW Analysis *New';    % header printed in LaTeX document
INI.FLOW_LATEX_RELATIVE_PNG_PATH = './DFS0_pngs/'; % RELATIVE path from location of .tex file to location of .png files

INI.DIR_FLOW_DFS0DD       = [INI.DIR_FILES 'DFS0DD/'];
INI.DIR_FLOW_PNGSDD       = [INI.DIR_FILES 'DFS0DD_pngs/'];
INI.FLOWDD_LATEX_FILENAME = [INI.DIR_FILES 'FLOW_DD.tex'];
INI.FLOWDD_LATEX_HEADER   = 'FLOW Analysis Daily *New';
INI.FLOWDD_LATEX_RELATIVE_PNG_PATH = './DFS0DD_pngs/';

INI.DIR_FLOW_DFS0HR       = [INI.DIR_FILES 'DFS0HR/'];
INI.DIR_FLOW_PNGSHR       = [INI.DIR_FILES 'DFS0HR_pngs/'];
INI.FLOWHR_LATEX_FILENAME = [INI.DIR_FILES 'FLOW_HR.tex'];
INI.FLOWHR_LATEX_HEADER   = 'FLOW Analysis Hourly *New';
INI.FLOWHR_LATEX_RELATIVE_PNG_PATH = './DFS0HR_pngs/';

% Location of ENPMS library
INI.MATLAB_SCRIPTS = '../ENPMS/';

% Other options (0 = NO, 1 = YES)
INI.DELETE_EXISTING_DFS0 = 1; 

% Location of blank figure
INI.BLANK_PNG = '../../ENP_TOOLS_Sample_Input/Data_Common/blank.png';

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% END USER INPUT
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------


% this should get deleted when automatic directory creation is added
      mkdir(char(INI.DIR_FLOW_PNGS));
      mkdir(char(INI.DIR_FLOW_DFS0DD));
      mkdir(char(INI.DIR_FLOW_PNGSDD));
      mkdir(char(INI.DIR_FLOW_DFS0HR));
      mkdir(char(INI.DIR_FLOW_PNGSHR));
% this should get deleted when automatic directory creation is added

try
    addpath(genpath(INI.MATLAB_SCRIPTS));
catch
    addpath(genpath(INI.MATLAB_SCRIPTS,0));
end

% iterate over all DFS0 files
DFS0_process_file_list(INI);

DFS0_process_file_list_DD(INI);
 
DFS0_process_file_list_HR(INI);

fprintf('\n DONE \n\n');

end
% -------------------------------------------------------------------------
