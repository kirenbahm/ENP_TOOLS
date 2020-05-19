function plot_6_figures(HorQ,DFS0,FIG_DIR,BLANK_PNG)
   % generate Timeseries
   try
      fprintf('     creating TS  plot...');
      plot_fig_TS_1(DFS0,FIG_DIR);
      fprintf('  success\n');
   catch
      fprintf('  *** FAILED ***\n');
      [~,NA,~] = fileparts(DFS0.NAME);
      F = strcat(FIG_DIR,NA,'-TS','.png');
      copyfile(BLANK_PNG,F)
   end
   
   % generate Cumulative
   try
      fprintf('     creating CUM plot...');
      if strcmp(HorQ,'H') % if datatype is stage, insert blank plot
        [~,NA,~] = fileparts(DFS0.NAME);
        F = strcat(FIG_DIR,NA,'-CUM','.png');
        copyfile(BLANK_PNG,F)
        fprintf('  (skipped)\n');
      else %(assume 'Q') % otherwise attempt cumulative plot
         plot_fig_CUMULATIVE_1(DFS0,FIG_DIR);
         fprintf('  success\n');
      end
   catch
      fprintf('  *** FAILED ***\n');
      [~,NA,~] = fileparts(DFS0.NAME);
      F = strcat(FIG_DIR,NA,'-CUM','.png');
      copyfile(BLANK_PNG,F)
   end
   
   % generate CDF
   try
      fprintf('     creating CDF plot...');
      plot_fig_CDF_1(DFS0,FIG_DIR)
      fprintf('  success\n');
   catch
      fprintf('  *** FAILED ***\n');
      [~,NA,~] = fileparts(DFS0.NAME);
      F = strcat(FIG_DIR,NA,'-CDF','.png');
      copyfile(BLANK_PNG,F)
   end
   
   % generate PE
   try
      fprintf('     creating PE  plot...');
      plot_fig_PE_1(DFS0,FIG_DIR) % This function works properly provided the Statistics Toolbox is installed.
      fprintf('  success\n');
   catch
      fprintf('  *** FAILED ***\n');
      [~,NA,~] = fileparts(DFS0.NAME);
      F = strcat(FIG_DIR,NA,'-PE','.png');
      copyfile(BLANK_PNG,F)
   end
   
   % plot Monthly
   try
      fprintf('     creating MM  plot...');
      plot_fig_MM_1(DFS0,FIG_DIR)
      fprintf('  success\n');
   catch
      fprintf('  *** FAILED ***\n');
      [~,NA,~] = fileparts(DFS0.NAME);
      F = strcat(FIG_DIR,NA,'-MM','.png');
      copyfile(BLANK_PNG,F)
   end
   
   % plot Annual
   try
      fprintf('     creating YY  plot...');
      plot_fig_YY_1(DFS0,FIG_DIR)
      fprintf('  success\n');
   catch
      fprintf('  *** FAILED ***\n');
      [~,NA,~] = fileparts(DFS0.NAME);
      F = strcat(FIG_DIR,NA,'-YY','.png');
      copyfile(BLANK_PNG,F)
   end
