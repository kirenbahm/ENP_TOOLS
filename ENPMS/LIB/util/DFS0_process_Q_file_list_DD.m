function DFS0_process_Q_file_list_DD(INI)

FILE_FILTER = '*.dfs0'; % list only files with extension .dfs0
FLOW_DFS0_FILES = [INI.DIR_FLOW_DFS0 FILE_FILTER];
LISTING  = dir(char(FLOW_DFS0_FILES));
FIG_DIR = INI.DIR_FLOW_PNGSDD;

n = length(LISTING);
for i = 1:n
   s = LISTING(i);
   NAME = s.name;
   FILE_NAME = [INI.DIR_FLOW_DFS0 NAME];
   fprintf('  Processing: %d/%d: %s \n', i, n, char(NAME));
   
   % read database file
   fprintf('     reading input file... ');
   DFS0 = read_file_DFS0(FILE_NAME);
   
   DFS0.NAME = NAME;
   
   fprintf('reducing to daily... ')
   DFS0 = DFS0_data_reduce_DD(DFS0);
   
   % create a daily file dfs0 file.
   [~,B,~] = fileparts(char(FILE_NAME));
   FILE_NAME = [INI.DIR_FLOW_DFS0DD,B,'.dfs0'];      % set this dir path for DFS0DD *.dfso file destination
   DFS0.STATION = B;
   % save the file in a new directory
   fprintf('saving... ')
   create_DFS0_GENERIC_DD(INI,DFS0,FILE_NAME);
   
   % read the new daily file
   fprintf('reading saved file...\n');
   DFS0 = read_file_DFS0(FILE_NAME);
   %      DFS0 = DFS0_assign_DTYPE_UNIT(DFS0,NAME);
   DFS0.NAME = NAME;
   
   DFS0 = DFS0_cumulative_flow(DFS0);
   %INI.DIR_DFS0_FILES = strrep(INI.DIR_DFS0_FILES,'DFS0','DFS0DD');
   
   % generate plots (timeseries, exceedance, monthly/yearly boxplots, etc.)
   plot_6_figures('Q',DFS0,FIG_DIR,INI.BLANK_PNG)
   
end

% Process the DFS0 and *.png files for inclusion on PDFs.
latex_6_plot(INI.DIR_FLOW_PNGSDD,INI.FLOWDD_LATEX_FILENAME,INI.FLOWDD_LATEX_HEADER,INI.FLOWDD_LATEX_RELATIVE_PNG_PATH)

fclose('all');
end