function INI = analyze_data_set (INI)

%---------------------------------------------------------------------
%  INITIALILIZE STRUCTURE INI
%---------------------------------------------------------------------
try
    INI = setup_ini(INI);
    INI.SELECTED_STATIONS = get_station_list(INI.SELECTED_STATION_FILE);
catch INI
    fprintf('\nException in readMSHE_WM(INI), i=%d\n', i);
    msgException = getReport(INI,'extended','hyperlinks','on')
end

INI.MAKE_STATISTICS_TABLE = 1; % Make the statistics tables in LaTeX. should be always 1
INI.MAKE_EXCEEDANCE_PLOTS = 1; % Generate exceedance curve plots. should be always 1

fprintf('\n %s Intialized all data for %.3g seconds\n',datestr(now), toc);

%---------------------------------------------------------------
% Run selected modules
%---------------------------------------------------------------

if INI.USE_NEW_CODE
    if INI.A1 ; INI = A1_load_extracted_timeseries(INI); end % New method
else
    if INI.A1 ; A1_load_computed_timeseries(INI); end  % Old method
end

if INI.USE_NEW_CODE
    if INI.A2 ; INI = A2_generate_extracted_stat(INI); end  % New method
else
    if INI.A2 ; A2_generate_timeseries_stat(INI); end % Old method
end

if INI.A2a ; INI = A2a_cumulative_flows(INI); end
if INI.A3 ; INI = A3_create_figures_timeseries(INI); end
if INI.A3c ; INI = A3_create_figures_acc_timeseries(INI); end
if INI.A3B ; INI = A3B_BoxPlot(INI); end
if INI.A4 ; INI = A4_create_figures_exceedance(INI); end
if INI.A5 ; INI = A5_create_summary_stat(INI); end
% if INI.A6; INI = A6_GW_MAP_COMPARE(INI); end
%if INI.A7; INI = A7_MDR_SEEPAGE(INI); end
if INI.A9; INI = A9_make_latex_report(INI); end
if INI.A10; INI = A10_make_alternatives_difference_maps(INI); end
if INI.A11; INI = A11_Generate_Statistic_Graphics(INI); end
if INI.A12; INI = A12_make_latex_flow_report(INI); end
fclose('all');

end
