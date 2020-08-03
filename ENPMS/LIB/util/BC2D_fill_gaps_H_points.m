function INI = BC2D_fill_gaps_H_points(INI)

fprintf('\n\n Beginning BC2D_fill_gaps_H_points.m \n\n');

K = INI.MAP_H_DATA.keys;
t_i = datenum(INI.DATE_I); %the full requested period as specified in DATE_I
t_e = datenum(INI.DATE_E); %the full requested period as specified in DATE_E

% Select Hourly or Daily time increment
if strcmpi(INI.OLorSZ,'OL')
    dT = (t_i:1/24:t_e)'; %Time vector for the entire requested period
elseif strcmpi(INI.OLorSZ,'SZ')
    dT = (t_i:1:t_e)'; %Time vector for the entire requested period
end

dH(1:length(dT),1) = NaN; % Datavector for the entire requested period
INI.NSTEPS = length(dT);

i = 0;
n = length(K);
for k = K
    i = i + 1;
    ST = INI.MAP_H_DATA(char(k));
    
    %initialize new vectors
    ST.t_i = t_i;
    ST.t_e = t_e;
    ST.dT = dT;
    ST.dHd = dH; % vector for Julian Day fit
    ST.dHf = dH; % vector for Fourier fit

    STATION_NAME = ST.STATION;
    N_OBS = length(ST.V);
    
    fprintf('... processing %d/%d: %s: with %d records...\n', i, n, char(STATION_NAME),N_OBS);
    
    % function to create new vectors with no gaps
%%%%    ST = BC2D_fit_gaps_ave_day(ST,INI.CREATE_FIGURES);     
    ST = BC2D_fit_gaps_ave_day(ST);     
    
    % function to perform Fourier gap filling
    Min_fourier = 18;
    if Min_fourier <= length(~isnan(ST.V))
        FIG_DIR_RESIDUALS = [INI.BC2D_DIR 'FIGURES-residuals/'];
        ST = BC2D_fit_gaps_ave_fourier(INI,ST,FIG_DIR_RESIDUALS);
    else
       fprintf('Station: %s has fewer than 18 valid measurements. Fourier gap fitting was not performed.\n', char(STATION_NAME));
    end

    % set the station in the map to the updated station
    INI.MAP_H_DATA(char(k)) = ST;
end

end