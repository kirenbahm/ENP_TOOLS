function stage_process_DFS0HR(INI,LISTING)
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
%      DFS0 = DFS0_assign_DTYPE_UNIT(DFS0,NAME);            % Line
%      commented out as it has been found to be unnecessary in current
%      iteration. Possible use may be found for re-assignment of DFS0.UNIT
%      based on a datatype/(summation or average) combinations where units
%      need to be ammended.
      DFS0.NAME = NAME;
      
      fprintf('... reducing: %d/%d: %s \n', i, n, char(FILE_NAME))
      DFS0 = DFS0_data_reduce_HR(DFS0);
      
      % create a hourly file dfs0 file.
      [~,B,~] = fileparts(char(FILE_NAME));
      FILE_NAME = [INI.STAGE_DIR,'DFS0HR/',B,'.dfs0'];
      DFS0.STATION = B;
      % save the file in a new directory
      create_DFS0_GENERIC_HR_H(INI,DFS0,FILE_NAME);
      
      % read the new hourly file
      fprintf('... reading: %d/%d: %s \n', i, n, char(FILE_NAME));
      DFS0 = read_file_DFS0(FILE_NAME);
      DFS0 = DFS0_assign_DTYPE_UNIT(DFS0,NAME);
      DFS0.NAME = NAME;
      
      DFS0 = DFS0_cumulative_flow(DFS0);                            % UNCLEAR on usage of cumulative flow here... Need to address purpose of this function call.
      INI.DIR_DFS0_FILES = strrep(INI.DIR_DFS0_FILES,'DFS0','DFS0HR');
      % generate Timeseries
      plot_fig_TS_1(DFS0,INI);
      
      % generate Cumulative
      plot_fig_CUMULATIVE_1(DFS0,INI);
% Previously commented out

      % generate CDF
%      plot_fig_CDF_1(DFS0,INI)
%       This is
%       commented out due to issues with ecdf.m, a function called
%       within the plot_fig_CDF_1 function. Set breakpoints here and within
%       the called function to disgnose the issue and potentially resolve     
      
      % generate PE
      plot_fig_PE_1(DFS0,INI)                   % This function works properly provided the Statistics Toolbox is installed.
      
      % plot Monthly
%      plot_fig_MM_1(DFS0,INI)
%       This is
%       commented out due to issues with boxplot.m, a function called
%       within the plot_fig_MM_1 function. Set breakpoints here and within
%       the called function to disgnose the issue and potentially resolve

      % plot Annual
%      plot_fig_YY_1(DFS0,INI)
%       This is
%       commented out due to issues with boxplot.m, a function called
%       within the plot_fig_YY_1 function. Set breakpoints here and within
%       the called function to disgnose the issue and potentially resolve

   catch
      fprintf('... exception (C) in: %d/%d: %s \n', i, n, char(FILE_NAME));
   end
   INI = original_INI;
end
fclose('all');
end