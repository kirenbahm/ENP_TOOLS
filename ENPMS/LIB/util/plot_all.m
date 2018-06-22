function INI = plot_all(INI)

M = INI.mapCompSelected;

KEYS = M.keys;

try
    for K = KEYS
        STATION = M(char(K));
        T = datestr(STATION.TIMEVECTOR);
        E = STATION.DCOMPUTED;
        TTS = timeseries(E,T);
        TTS.name = char(K);
        TTS.TimeInfo.Format = 'mm/yy';
        F = plot(TTS);
    end
catch
    fprintf('...exception in::%s\n', char(K));
    %msgException = getReport(INI,'extended','hyperlinks','on')
end

end

