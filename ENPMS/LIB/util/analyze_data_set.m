function INI = analyze_data_set (INI)

%---------------------------------------------------------------
% Run the modules
%---------------------------------------------------------------

if INI.USE_NEW_CODE
    if INI.A1 ; A1_load_extracted_timeseries(INI); end % New method
else
    if INI.A1 ; A1_load_computed_timeseries(INI); end  % Old method
end

if INI.USE_NEW_CODE
    if INI.A2 ; A2_generate_extracted_stat(INI); end  % New method
else
    if INI.A2 ; A2_generate_timeseries_stat(INI); end % Old method
end

if INI.A2a ; A2a_cumulative_flows(INI); end
if INI.A3 ; A3_create_figures_timeseries(INI); end
if INI.A3c ; A3_create_figures_acc_timeseries(INI); end
if INI.A3a ; A3a_boxmat(INI); end
if INI.A3exp ; A3a_boxmatEXP(INI); end
if INI.A4 ; A4_create_figures_exceedance(INI); end
if INI.A5 ; INI = A5_create_summary_stat(INI); end
if INI.A6; A6_GW_MAP_COMPARE(INI); end
if INI.A7; A7_MDR_SEEPAGE(INI); end
if INI.A9; A9_make_latex_report(INI); end

fclose('all');

end
