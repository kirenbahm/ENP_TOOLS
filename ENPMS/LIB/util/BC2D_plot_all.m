function INI = BC2D_plot_all(INI)

fprintf('\n\n Beginning BC2D_plot_all.m \n\n');

M = INI.MAP_H_DATA;
KEYS = M.keys;

for K = KEYS
    clf;
    fprintf('... plotting: %s \n', char(K));
    STATION = M(char(K));
      
    NN(1) = {'Spatially Interpolated Grid value'};
    T = datestr(STATION.dT);
    V = STATION.DINTERP;
    TTS1 = timeseries(V,T);
    TTS1.TimeInfo.Format = 'mmm-yyyy';
    plot(TTS1,'Linestyle', '-', 'Color', [0.5,0.5,0.5], 'Marker','none');
    
    hold on;
    
    if ~INI.USE_FOURIER_BC2D
        NN(2) = {'Temporal interpolation - Julian Day'};
        T = datestr(STATION.dT);
        V = STATION.dHd;
        TTS2 = timeseries(V,T);
        TTS2.TimeInfo.Format = 'mmm-yyyy';
        plot(TTS2,'Linestyle', 'none', 'Color', 'r', 'Marker','.', 'MarkerSize',2);
    else
        NN(2) = {'Temporal interpolation - Fourier'};
        T = datestr(STATION.dT);
        V = STATION.dHf;
        TTS2 = timeseries(V,T);
        TTS2.TimeInfo.Format = 'mmm-yyyy';
        plot(TTS2,'Linestyle', 'none', 'Color', 'r', 'Marker','.', 'MarkerSize',2);
    end
    
    NN(3) = {'Raw Observed Data'};
    T = datestr(STATION.T);
    % V = STATION.V_OBS; % in original datum
    V = STATION.V;
    TTS3 = timeseries(V,T);
    TTS3.TimeInfo.Format = 'mmm-yyyy';
    plot(TTS3,'Linestyle', 'none', 'Color', 'b', 'Marker','.', 'MarkerSize',2);

    
    tstart = datetime(INI.DATE_I, 'InputFormat', 'MM/dd/yyyy');
    tend = datetime(INI.DATE_E, 'InputFormat', 'MM/dd/yyyy');
    ax = gca;
    ax.XLim = [tstart tend];
    
    legend(NN,'Location','best'); 
    title(char(K),'FontSize',10,'FontName','Times New Roman');
    
    FIGURE_DIR = [INI.BC2D_DIR 'FIGURES/'];
    if ~exist(FIGURE_DIR, 'dir')
        mkdir(FIGURE_DIR)
    end
    
    if strcmpi(INI.OLorSZ,'OL')
        figurefile = [FIGURE_DIR char(K) '_HR.png'];
    elseif strcmpi(INI.OLorSZ,'SZ')
        figurefile = [FIGURE_DIR char(K) '_DD.png'];
    end
    
    
    print('-dpng',char(figurefile),'-r300');
end


end
