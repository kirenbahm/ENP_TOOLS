function DFS0_process_H_file_list(INI)

FILE_FILTER = '*.dfs0'; % list only files with extension .dfs0
STAGE_DFS0_FILES = [INI.DIR_STAGE_DFS0 FILE_FILTER];
LISTING  = dir(char(STAGE_DFS0_FILES));
FIG_DIR = INI.DIR_STAGE_PNGS;

n = length(LISTING);
for i = 1:n
   s = LISTING(i);
   NAME = s.name;
   FILE_NAME = [INI.DIR_STAGE_DFS0 NAME];
   fprintf('  Processing: %d/%d: %s \n', i, n, char(NAME));
   
   % read database file
   fprintf('     reading input file...\n');
   DFS0 = read_file_DFS0(FILE_NAME);
   
   %      DFS0 = DFS0_assign_DTYPE_UNIT(DFS0,NAME);            % Line
   %      commented out as it has been found to be unnecessary in current
   %      iteration. Possible use may be found for re-assignment of DFS0.UNIT
   %      based on a datatype/(summation or average) combinations where units
   %      need to be ammended.
   
   DFS0.NAME = NAME;
   
   %DFS0 = DFS0_cumulative_flow(DFS0);  % Function call is commented out for all 'water level' data sets.
   
   % generate plots (timeseries, exceedance, monthly/yearly boxplots, etc.)
   plot_6_figures('H',DFS0,FIG_DIR,INI.BLANK_PNG)

end

% Process the DFS0 and *.png files for inclusion on PDFs.
latex_6_plot(INI.DIR_STAGE_PNGS,INI.STAGE_LATEX_FILENAME,INI.STAGE_LATEX_HEADER,INI.STAGE_LATEX_RELATIVE_PNG_PATH)

fclose('all');
end
