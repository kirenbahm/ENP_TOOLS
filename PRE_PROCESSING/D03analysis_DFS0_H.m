function D03analysis_DFS0_H()
% Script reads dfs0 files and provides analysis and figures along with CDF
% PE, monthly and annual summaries

% It is critical that you ensure the pwd (path to working directory) is set
% properly (i.e. 'drive:\MIKE_MATLAB'). This can be verified by setting a 
% breakpoint at line: 64 and checking the value of "INI.CURRENT_PATH", and 
% "LISTING" variables. If there is an error verify pwd(*), addpath(*), and 
% "DIR =" lines are complete and with accurate syntax.

% -------------------------------------------------------------------------
% path string of ROOT Directory
% -------------------------------------------------------------------------
[INI.ROOT,MAIN,~] = fileparts(pwd());
INI.ROOT = [INI.ROOT MAIN '/'];

% -------------------------------------------------------------------------
% path(s) to PARENT directory ('DATA_ENP') and all input ('_input') and output ('FLOW', 'STAGE', 'BC2D') file directories
% -------------------------------------------------------------------------
INI.DATA_ENP_DIR = [INI.ROOT 'DATA_ENP/'];
    % Input directories:
INI.input = [INI.DATA_ENP_DIR '_input/'];
    % DFS0 file creation from DFE input file directories
INI.STATION_DIR = [INI.DATA_ENP_DIR 'D00_STATIONS/'];
INI.FLOW_DIR = [INI.DATA_ENP_DIR 'D01_FLOW/'];
INI.STAGE_DIR = [INI.DATA_ENP_DIR 'D02_STAGE/'];
    % BC2D generation directories:
INI.BC2D_DIR = [INI.DATA_ENP_DIR 'G01_BC2D/'];

% -------------------------------------------------------------------------
% SETUP Location of ENPMS Scripts and Initialize
% -------------------------------------------------------------------------
INI.MATLAB_SCRIPTS = '.\ENPMS\';
%INI.MATLAB_SCRIPTS = [INI.ROOT 'ENP_TOOLS\ENPMS\'];

try
    addpath(genpath(INI.MATLAB_SCRIPTS));
catch
    addpath(genpath(INI.MATLAB_SCRIPTS,0));
end

INI.DELETE_EXISTING_DFS0 = 1;

% directory with station_data.txt file:

% directory with *.out files:
INI.DIR_DFS0_FILES = [INI.STAGE_DIR 'DFS0/'];
FILE_FILTER = '*.dfs0'; % list only files with extension .out
STAGE_DFS0_FILES = [INI.DIR_DFS0_FILES FILE_FILTER];
LISTING  = dir(char(STAGE_DFS0_FILES));

% iterate over all files
stage_process_DFS0(INI,LISTING);

stage_process_DFS0DD(INI,LISTING);

stage_process_DFS0HR(INI,LISTING);

%save('DATA_Q.MATLAB','S','mapSTATIONS','-v7.3');
% add the last station after the entire file is eol

% Process the DFS0 and *.png files for inclusion on PDFs. User can set
% which *.png series to process: full, DD, or HR. Process only one at a
% time currently.

format compact
DPATH = INI.STAGE_DIR;                                          % set DPATH to directory location with necessary *.dfs0 and *.png files
% Set *.dfs0 DIRECTORY for the user defined pdf creation.
DIRPNG = [DPATH 'DFS0/'];                                       % location of DFS0 *.png files
%DIRPNG = [DPATH 'DFS0DD/'];                                    % location of DFS0DD *.png files
%DIRPNG = [DPATH 'DFS0HR/'];                                    % location of DFS0HR *.png files
PNGFILES = [DIRPNG '*.png'];
VECPNG = ls(PNGFILES);                                          % list all files in DIRPNG with extension *.png
% Set output FILENAME for the user defined pdf creation.
FILENAME = [DPATH 'STAGE.tex'];                                 % Destination STAGE LaTex file ( *.tex )
%FILENAME = [DPATH 'STAGE_DD.tex'];                             % Destination STAGE_DD LaTex file ( *.tex )
%FILENAME = [DPATH 'STAGE_HR.tex'];                             % Destination STAGE_HR LaTex file ( *.tex )
HEADER = 'Water Level Statistics';
noFIG = 3;                                                      % Set the number of image rows per latex page. Value can either be 2 or 3.

FID = fopen(FILENAME,'w');

latex_print_begin(FID,HEADER);


for i = 1:length(VECPNG)
    m = mod(i,3);                                       % This variable has no usage within this or any other function/script. Consider revising, removing this variable completely.
    n = mod(i,2);
    
%    if m == 0; noFIG = 3; else; noFIG = 2; end  % This is not the correct
%    way to determine NoFIG. Need to deteremine a better method else just
%    default to a 2 column 3 row image layout
    
    if mod(i,6) == 1; latex_begin_new_page(FID); end                        % If this is the first image to be processed, begin the latex page design.
    
    [~,NAME,EXT] = fileparts(VECPNG(i,:));
    latex_print_pages_figures(m,n,FID,DIRPNG,NAME,strtrim(EXT),noFIG);
    
    if ~mod(i,6) || i == length(VECPNG), latex_end_page(FID); end           % If the page has 6 total figures, or i is the last image in the list, end the latex page.

end

latex_print_end(FID)

fclose(FID);

end
%--------------------------------------------------------------------------