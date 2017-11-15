function INI = analyze_data_set (INI)

%---------------------------------------------------------------
% Run the modules
%---------------------------------------------------------------

if INI.ANALYSIS_EXTRACTED
    if INI.A1 ; A1_load_extracted_timeseries(INI); end
else
    if INI.A1 ; A1_load_computed_timeseries(INI); end
end

if INI.ANALYSIS_EXTRACTED
    if INI.A2 ; A2_generate_extracted_stat(INI); end
else
    if INI.A2 ; A2_generate_timeseries_stat(INI); end
end

if INI.A2a ; A2a_cumulative_flows(INI); end
if INI.A3 ; A3_create_figures_timeseries(INI); end
if INI.A3c ; A3_create_figures_acc_timeseries(INI); end
if INI.A3a ; A3a_boxmat(INI); end
if INI.A3exp ; A3a_boxmatEXP(INI); end
if INI.A4 ; A4_create_figures_exceedance(INI); end
if INI.A5 ; A5_create_summary_stat(INI); end
if INI.A6; A6_GW_MAP_COMPARE(INI); end
if INI.A7; A7_MDR_SEEPAGE(INI); end
fclose('all');

end
