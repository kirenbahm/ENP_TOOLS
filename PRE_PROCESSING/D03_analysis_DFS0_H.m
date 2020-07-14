function D03_analysis_DFS0_H()
% Script reads dfs0 files and provides analysis and figures along with CDF
% PE, monthly and annual summaries

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% BEGIN USER INPUT
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Location of dfs0 STAGE files 
% -------------------------------------------------------------------------
% use these for unit testing
% INI.DIR_INFILES          = '../../ENP_FILES/ENP_TOOLS_Sample_Input/Obs_Data_Processed/STAGE/';
% INI.DIR_OUTFILES         = '../../ENP_TOOLS_Output/D03_analysis_DFS0_H_output/Obs_Data_Processed/STAGE/';

% use these for sequential testing
INI.DIR_INFILES         = '../../ENP_TOOLS_Output_Sequential/Obs_Data_Processed/Stage/';
INI.DIR_OUTFILES        = '../../ENP_TOOLS_Output_Sequential/Obs_Data_Processed/Stage/';

% -------------------------------------------------------------------------
% Set up directory structure (this shouldn't need changing)
% -------------------------------------------------------------------------
INI.DIR_STAGE_DFS0       = [INI.DIR_INFILES 'DFS0/'];
INI.DIR_STAGE_PNGS       = [INI.DIR_OUTFILES 'DFS0_pngs/'];
INI.STAGE_LATEX_FILENAME = [INI.DIR_OUTFILES 'STAGE.tex'];
INI.STAGE_LATEX_HEADER   = 'Water Level Statistics';    % header printed in LaTeX document
INI.STAGE_LATEX_RELATIVE_PNG_PATH = './DFS0_pngs/'; % RELATIVE path from location of .tex file to location of .png files

INI.DIR_STAGE_DFS0DD       = [INI.DIR_OUTFILES 'DFS0DD/'];
INI.DIR_STAGE_PNGSDD       = [INI.DIR_OUTFILES 'DFS0DD_pngs/'];
INI.STAGEDD_LATEX_FILENAME = [INI.DIR_OUTFILES 'STAGE_DD.tex'];
INI.STAGEDD_LATEX_HEADER   = 'Daily Water Level Statistics';
INI.STAGEDD_LATEX_RELATIVE_PNG_PATH = './DFS0DD_pngs/';

INI.DIR_STAGE_DFS0HR       = [INI.DIR_OUTFILES 'DFS0HR/'];
INI.DIR_STAGE_PNGSHR       = [INI.DIR_OUTFILES 'DFS0HR_pngs/'];
INI.STAGEHR_LATEX_FILENAME = [INI.DIR_OUTFILES 'STAGE_HR.tex'];
INI.STAGEHR_LATEX_HEADER   = 'Hourly Water Level Statistics';
INI.STAGEHR_LATEX_RELATIVE_PNG_PATH = './DFS0HR_pngs/';


% -------------------------------------------------------------------------
% Location of ENPMS library
% -------------------------------------------------------------------------
INI.MATLAB_SCRIPTS = '../ENPMS/';

% -------------------------------------------------------------------------
% Other options (0 = NO, 1 = YES)
% -------------------------------------------------------------------------
INI.DELETE_EXISTING_DFS0 = 1;

% -------------------------------------------------------------------------
% Location of blank figure
% -------------------------------------------------------------------------
INI.BLANK_PNG = '../../ENP_FILES/ENP_TOOLS_Sample_Input/Data_Common/blank.png';

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% END USER INPUT
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------


% this should get deleted when automatic directory creation is added
      mkdir(char(INI.DIR_STAGE_PNGS));
      mkdir(char(INI.DIR_STAGE_DFS0DD));
      mkdir(char(INI.DIR_STAGE_PNGSDD));
      mkdir(char(INI.DIR_STAGE_DFS0HR));
      mkdir(char(INI.DIR_STAGE_PNGSHR));
% this should get deleted when automatic directory creation is added

try
    addpath(genpath(INI.MATLAB_SCRIPTS));
catch
    addpath(genpath(INI.MATLAB_SCRIPTS,0));
end

%Initialize .NET libraries
INI = initializeLIB(INI);

% iterate over all DFS0 files
DFS0_process_H_file_list(INI);

DFS0_process_H_file_list_DD(INI);
 
DFS0_process_H_file_list_HR(INI);

fprintf('\n DONE \n\n');

end
% -------------------------------------------------------------------------
