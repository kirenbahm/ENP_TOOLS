function DFS0_process_file_list(INI,LISTING)
% The INI input changes during teh course of this script. In order to
% ensure coninuity the original INI is preserved here.
original_INI = INI;

n = length(LISTING);
for i = 1:n
   try
      s = LISTING(i);
      NAME = s.name;
      FILE_NAME = [INI.DIR_DFS0_FILES NAME];
      %FILE_ID = fopen(char(FILE_NAME));
      fprintf('... reading: %d/%d: %s \n', i, n, char(FILE_NAME));
      
      % read database file
      DFS0 = read_file_DFS0(FILE_NAME);
      DFS0.NAME = NAME;
%      DEXT = 'Q';
      
      DFS0 = DFS0_cumulative_flow(DFS0);
      
      % generate Timeseries
      plot_fig_TS_1(DFS0,INI);
      
      % generate Cumulative
      plot_fig_CUMULATIVE_1(DFS0,INI);
      
      % generate CDF
%       plot_fig_CDF_1(DFS0,INI)                            
%       This is
%       commented out due to issues with ecdf.m, a function called
%       within the plot_fig_CDF_1 function. Set breakpoints here and within
%       the called function to disgnose the issue and potentially resolve.
      
      % generate PE
       plot_fig_PE_1(DFS0,INI)
      
      % plot Monthly
%       plot_fig_MM_1(DFS0,INI)                            
%       This is
%       commented out due to issues with boxplot.m, a function called
%       within the plot_fig_MM_1 function. Set breakpoints here and within
%       the called function to disgnose the issue and potentially resolve.
      
      % plot Annual
%       plot_fig_YY_1(DFS0,INI)
%       This is
%       commented out due to issues with boxplot.m, a function called
%       within the plot_fig_YY_1 function. Set breakpoints here and within
%       the called function to disgnose the issue and potentially resolve.
      
   catch
      fprintf('... exception (A) in: %d/%d: %s \n', i, n, char(FILE_NAME));
   end
   INI = original_INI;
end
fclose('all');
end