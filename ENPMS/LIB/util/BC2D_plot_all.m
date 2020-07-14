function INI = BC2D_plot_all(INI)

fprintf('\n\n Beginning BC2D_plot_all.m \n\n');

M = INI.MAP_H_DATA;
KEYS = M.keys;

for K = KEYS
    clf;
    fprintf('... plotting: %s \n', char(K));
    STATION = M(char(K));
    DATUM = 'NGVD29'; %%% THESE SHOULD NOT BE HARDCODED %%%
    if isfield(STATION,'DATUM')
        if strcmp(STATION.DATUM,'NAVD88')
            DATUM = 'NAVD88';
        end
    end
    T = datestr(STATION.T);
    % V = STATION.V_OBS; % in original datum
    V = STATION.V;
    TTS1 = timeseries(V,T);
    %     TTS.name = char(K);
    TTS1.TimeInfo.Format = 'mmm-yyyy';
    plot(TTS1,'Linestyle', 'none', 'Color', 'red', 'Marker','o', 'MarkerSize',3);
    
    hold on;
      
    if ~INI.USE_FOURIER_BC2D
        T = datestr(STATION.dT);
        V = STATION.dHd;
        TTS2 = timeseries(V,T);
        %     TTS.name = char(K);
        TTS2.TimeInfo.Format = 'mmm-yyyy';
        plot(TTS2,'Linestyle', '-', 'Color', 'g', 'Marker','none');
        Ncell = {strcat('TS interpolation - Julian Day, ft ', DATUM)}; %%% THESE SHOULD NOT BE HARDCODED %%%
    else
        T = datestr(STATION.dT);
        V = STATION.dHf;
        TTS2 = timeseries(V,T);
        %     TTS.name = char(K);
        TTS2.TimeInfo.Format = 'mmm-yyyy';
        plot(TTS2,'Linestyle', '-', 'Color', 'b', 'Marker','none');
        Ncell = {strcat('TS interpolation - Fourier, ft ', DATUM)}; %%% THESE SHOULD NOT BE HARDCODED %%%
    end
    
    V = STATION.DINTERP;
    TTS3 = timeseries(V,T);
    %    TTS.name = char(K);
    TTS3.TimeInfo.Format = 'mmm-yyyy';
    plot(TTS3,'Linestyle', '-', 'Color', 'k', 'Marker','none');
    
    tstart = datetime(INI.DATE_I, 'InputFormat', 'MM/dd/yyyy');
    tend = datetime(INI.DATE_E, 'InputFormat', 'MM/dd/yyyy');
    ax = gca;
    ax.XLim = [tstart tend];
    
    NN(1) = {['Observed, ft ' DATUM]};
    NN(2) = Ncell;
    NN(3) = {'Grid value, ft NGVD29'};       %%% THESE SHOULD NOT BE HARDCODED %%%
    legend(NN,'Location','SouthEast'); %supress legends for now
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
