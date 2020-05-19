function DFS0_process_H_file_list_DD(INI)

FILE_FILTER = '*.dfs0'; % list only files with extension .dfs0
STAGE_DFS0_FILES = [INI.DIR_STAGE_DFS0 FILE_FILTER];
LISTING  = dir(char(STAGE_DFS0_FILES));
FIG_DIR = INI.DIR_STAGE_PNGSDD;

n = length(LISTING);
for i = 1:n
   s = LISTING(i);
   NAME = s.name;
   FILE_NAME = [INI.DIR_STAGE_DFS0 NAME];
   fprintf('  Processing: %d/%d: %s \n', i, n, char(NAME));
   
   % read database file
   fprintf('     reading input file... ');
   DFS0 = read_file_DFS0(FILE_NAME);
   
   %      DFS0 = DFS0_assign_DTYPE_UNIT(DFS0,NAME);            % Line
   %      commented out as it has been found to be unnecessary in current
   %      iteration. Possible use may be found for re-assignment of DFS0.UNIT
   %      based on a datatype/(summation or average) combinations where units
   %      need to be ammended.
   
   DFS0.NAME = NAME;
   
   fprintf('reducing to daily... ')
   DFS0 = DFS0_data_reduce_DD(DFS0);
   
   % create a daily file dfs0 file.
   [~,B,~] = fileparts(char(FILE_NAME));
   FILE_NAME = [INI.DIR_STAGE_DFS0DD,B,'.dfs0'];      % set this dir path for DFS0DD *.dfso file destination
   DFS0.STATION = B;
   % save the file in a new directory
   fprintf('saving... ')
   create_DFS0_GENERIC_DD(INI,DFS0,FILE_NAME);
   
   % read the new daily file
   fprintf('reading saved file...\n');
   DFS0 = read_file_DFS0(FILE_NAME);
   DFS0 = DFS0_assign_DTYPE_UNIT(DFS0,NAME);
   DFS0.NAME = NAME;
   
   %DFS0 = DFS0_cumulative_flow(DFS0);  % Function call is commented out for all 'water level' data sets.
   
   %INI.DIR_DFS0_FILES = strrep(INI.DIR_DFS0_FILES,'DFS0','DFS0DD');
   
   % generate plots (timeseries, exceedance, monthly/yearly boxplots, etc.)
   plot_6_figures('H',DFS0,FIG_DIR,INI.BLANK_PNG)
   
end

% Process the DFS0 and *.png files for inclusion on PDFs.
latex_6_plot(INI.DIR_STAGE_PNGSDD,INI.STAGEDD_LATEX_FILENAME,INI.STAGEDD_LATEX_HEADER,INI.STAGEDD_LATEX_RELATIVE_PNG_PATH)

fclose('all');
end
