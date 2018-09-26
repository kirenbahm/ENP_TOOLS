function DFS0_process_file_list_DD(INI)

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
   create_DFS0_GENERIC_DD_Q(INI,DFS0,FILE_NAME);
   
   % read the new daily file
   fprintf('reading saved file...\n');
   DFS0 = read_file_DFS0(FILE_NAME);
   %      DFS0 = DFS0_assign_DTYPE_UNIT(DFS0,NAME);
   DFS0.NAME = NAME;
   
   DFS0 = DFS0_cumulative_flow(DFS0);
   %INI.DIR_DFS0_FILES = strrep(INI.DIR_DFS0_FILES,'DFS0','DFS0DD');
   
   % generate Timeseries
   try
      fprintf('     creating TS  plot...');
      plot_fig_TS_1(DFS0,FIG_DIR);
      fprintf('  success\n');
   catch
      fprintf('  *** FAILED ***\n');
      [~,NA,~] = fileparts(DFS0.NAME);
      NA = strrep(NA,'.','_');
      F = strcat(FIG_DIR,NA,'-TS','.png');
      copyfile(INI.BLANK_PNG,F)
   end
   
   % generate Cumulative
   try
      fprintf('     creating CUM plot...');
      plot_fig_CUMULATIVE_1(DFS0,FIG_DIR);
      fprintf('  success\n');
   catch
      fprintf('  *** FAILED ***\n');
      [~,NA,~] = fileparts(DFS0.NAME);
      NA = strrep(NA,'.','_');
      F = strcat(FIG_DIR,NA,'-CUM','.png');
      copyfile(INI.BLANK_PNG,F)
   end
   
   % generate CDF
   try
      fprintf('     creating CDF plot...');
      plot_fig_CDF_1(DFS0,FIG_DIR)
      fprintf('  success\n');
   catch
      fprintf('  *** FAILED ***\n');
      [~,NA,~] = fileparts(DFS0.NAME);
      NA = strrep(NA,'.','_');
      F = strcat(FIG_DIR,NA,'-CDF','.png');
      copyfile(INI.BLANK_PNG,F)
   end
   
   % generate PE
   try
      fprintf('     creating PE  plot...');
      plot_fig_PE_1(DFS0,FIG_DIR) % This function works properly provided the Statistics Toolbox is installed.
      fprintf('  success\n');
   catch
      fprintf('  *** FAILED ***\n');
      [~,NA,~] = fileparts(DFS0.NAME);
      NA = strrep(NA,'.','_');
      F = strcat(FIG_DIR,NA,'-PE','.png');
      copyfile(INI.BLANK_PNG,F)
   end
   
   % plot Monthly
   try
      fprintf('     creating MM  plot...');
      plot_fig_MM_1(DFS0,FIG_DIR)
      fprintf('  success\n');
   catch
      fprintf('  *** FAILED ***\n');
      [~,NA,~] = fileparts(DFS0.NAME);
      NA = strrep(NA,'.','_');
      F = strcat(FIG_DIR,NA,'-MM','.png');
      copyfile(INI.BLANK_PNG,F)
   end
   
   % plot Annual
   try
      fprintf('     creating YY  plot...');
      plot_fig_YY_1(DFS0,FIG_DIR)
      fprintf('  success\n');
   catch
      fprintf('  *** FAILED ***\n');
      [~,NA,~] = fileparts(DFS0.NAME);
      NA = strrep(NA,'.','_');
      F = strcat(FIG_DIR,NA,'-YY','.png');
      copyfile(INI.BLANK_PNG,F)
   end
   
end

% Process the DFS0 and *.png files for inclusion on PDFs.
format compact
DIRPNG = INI.DIR_FLOW_PNGSDD;
PNGFILES = [DIRPNG '*.png'];
VECPNG = ls(PNGFILES);                                      % list all files in DIRPNG with extension *.png
[num_pngs,~] = size(VECPNG);
noFIG = 3;                                                  % Set the number of image rows per latex page. Value can either be 2 or 3.

FID = fopen(INI.FLOWDD_LATEX_FILENAME,'w');

latex_print_begin(FID,INI.FLOWDD_LATEX_HEADER);

for i = 1:num_pngs
    m = mod(i,2);                                       % This variable has no usage within this or any other function/script. Consider revising, removing this variable completely.
    n = mod(i,3);
    
%    if m == 0; noFIG = 3; else; noFIG = 2; end  % This is not the correct
%    way to determine NoFIG. Need to deteremine a better method else just
%    default to a 2 column 3 row image layout
    
    if mod(i,6) == 1; latex_begin_new_page(FID); end                        % If this is the first image to be processed, begin the latex page design.
    
    [~,NAME,EXT] = fileparts(VECPNG(i,:));
    latex_print_pages_figures(m,n,FID,INI.FLOWDD_LATEX_RELATIVE_PNG_PATH,NAME,strtrim(EXT),noFIG);
    
    if ~mod(i,6) || i == num_pngs, latex_end_page(FID); end           % If the page has 6 total figures, or i is the last image in the list, end the latex page.
end

latex_print_end(FID)
fclose(FID);

fclose('all');
end