function DFS0_process_Q_file_list(INI)

FILE_FILTER = '*.dfs0'; % list only files with extension .dfs0
FLOW_DFS0_FILES = [INI.DIR_FLOW_DFS0 FILE_FILTER];
LISTING  = dir(char(FLOW_DFS0_FILES));
FIG_DIR = INI.DIR_FLOW_PNGS;

n = length(LISTING);
for i = 1:n
   s = LISTING(i);
   NAME = s.name;
   FILE_NAME = [INI.DIR_FLOW_DFS0 NAME];
   fprintf('  Processing: %d/%d: %s \n', i, n, char(NAME));
   
   % read database file
   fprintf('     reading input file...\n');
   DFS0 = read_file_DFS0(FILE_NAME);
   DFS0.NAME = NAME;
   %      DEXT = 'Q';
   
   DFS0 = DFS0_cumulative_flow(DFS0);
   
   % generate plots (timeseries, exceedance, monthly/yearly boxplots, etc.)
   plot_6_figures('Q',DFS0,FIG_DIR,INI.BLANK_PNG)

end

% Process the DFS0 and *.png files for inclusion on PDFs.
latex_6_plot(INI.DIR_FLOW_PNGS,INI.FLOW_LATEX_FILENAME,INI.FLOW_LATEX_HEADER,INI.FLOW_LATEX_RELATIVE_PNG_PATH)

fclose('all');
end