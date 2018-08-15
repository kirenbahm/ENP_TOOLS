function INI = BC2D_plot_all(INI,SWITCH)

M = INI.MAP_H_DATA; 
KEYS = M.keys;

for K = KEYS
    clf;
    fprintf('... plotting: %s \n', char(K));
    STATION = M(char(K));
    DATUM = 'NGVD29';
    if isfield(STATION,'DATUM')
        if strcmp(STATION.DATUM,'NAVD88')
            DATUM = 'NAVD88';
        end
    end
    T = datestr(STATION.T);
    V = STATION.V_OBS;
    TTS1 = timeseries(V,T);
    %     TTS.name = char(K);
    TTS1.TimeInfo.Format = 'mmm-yyyy';
    plot(TTS1,'Linestyle', 'none', 'Color', 'red', 'Marker','o', 'MarkerSize',3);
    
    hold on;
    
    T = datestr(STATION.dT);
    V = STATION.dHf;
    TTS2 = timeseries(V,T);
    %     TTS.name = char(K);
    TTS2.TimeInfo.Format = 'mmm-yyyy';
    plot(TTS2,'Linestyle', '-', 'Color', 'b', 'Marker','none');
    
    V = STATION.DINTERP;
    TTS3 = timeseries(V,T);
    TTS.name = char(K);
    TTS3.TimeInfo.Format = 'mmm-yyyy';
    plot(TTS3,'Linestyle', '-', 'Color', 'k', 'Marker','none');
    
    tstart = datetime(1999,1,1);
    tend = datetime(2015,12,31);
    ax = gca;
    ax.XLim = [tstart tend];

NN(1) = {['Observed, ft ' DATUM]};
NN(2) = {'TS interpolation, ft NGVD29'};
NN(3) = {'Grid value, ft NGVD29'};    
legend(NN,'Location','SouthEast');
title(char(K),'FontSize',10,'FontName','Times New Roman');


if strcmpi(SWITCH,'OL')
    figurefile = [INI.BC2D_DIR 'FIGURES/' char(K) '_HR.png'];
elseif strcmpi(SWITCH,'SZ')
    figurefile = [INI.BC2D_DIR 'FIGURES/' char(K) '_DD.png'];
end

print('-dpng',char(figurefile),'-r300');
end


end