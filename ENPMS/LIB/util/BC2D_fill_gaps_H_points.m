function INI = BC2D_fill_gaps_H_points(INI)

fprintf('\n\n Beginning BC2D_fill_gaps_H_points.m \n\n');

allKeys = INI.MAP_H_DATA.keys;  % get list of keys (station names)

beginDate = datenum(INI.DATE_I); %the full requested period as specified in DATE_I
endDate   = datenum(INI.DATE_E); %the full requested period as specified in DATE_E

% Create date vector for entire requested period based on Hourly or Daily time increment
if strcmpi(INI.OLorSZ,'OL')
    dateVector = (beginDate:1/24:endDate)';
elseif strcmpi(INI.OLorSZ,'SZ')
    dateVector = (beginDate:1:endDate)';
end

% create properly-sized data vector for the entire requested period and initialize with NaNs
dataVector(1:length(dateVector),1) = NaN;

% get total number of timesteps
INI.NSTEPS = length(dateVector);

i = 0;
numKeys = length(allKeys);
for currentKey = allKeys
    i = i + 1;
    
    % load observed data for one station into variable ST
    ST = INI.MAP_H_DATA(char(currentKey));
    
    % copy datetime data and emty data vectors into ST
    ST.t_i = beginDate;
    ST.t_e = endDate;
    ST.dT  = dateVector;
    ST.dHr = dataVector; % vector for unfilled (raw) data
    ST.dHd = dataVector; % vector for Julian Day fit
    ST.dHf = dataVector; % vector for Fourier fit

    stnDataFilename = ST.NAME;
    
    numObsValues = length(ST.V);
    
    fprintf('... processing %d/%d: %s: with %d records...\n', i, numKeys, char(stnDataFilename),numObsValues);
    
    % Create un-filled (raw) data vector
    ST = BC2D_create_raw_data_vector(ST);

    % Create data vector filled using Julian Date method
    ST = BC2D_fit_gaps_julian(ST);
    
    % Create data vector filled using Fourier method
    Min_fourier = 18;
    if Min_fourier <= length(~isnan(ST.V))
        FIG_DIR_RESIDUALS = [INI.BC2D_DIR 'FIGURES-residuals/'];
        ST = BC2D_fit_gaps_fourier(INI,ST,FIG_DIR_RESIDUALS);
    else
        fprintf('Station: %s has fewer than 18 valid measurements. Fourier gap fitting was not performed.\n', char(stnDataFilename));
    end
    
    % set the station in the map to the updated station
    INI.MAP_H_DATA(char(currentKey)) = ST;
end

end