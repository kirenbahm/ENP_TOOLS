function [ INI ] = A2_generate_extracted_stat(INI)
%---------------------------------------------
%{
 FUNCTION DESCRIPTION:

this function is after load computed_timeseries, it requires the computed
and observed to be loaded in a map

BUGS:
COMMENTS:
----------------------------------------
REVISION HISTORY:

changes introduced to v2:  (rjf 12/2011)
calling get_station_statV1

changes introduced to v1:  (keb 7/2011)
 -script would exit prematurely if a STATION name from STATIONS_LIST
  was not found in the MAP_ALL_DATA container. modified script to 'try'
  to find station and just issue message if not found
%}
%----------------------------------------
fprintf('\n------------------------------------');
fprintf('\nBeginning A2_generate_extracted_stat    (%s)',datestr(now));
fprintf('\n------------------------------------');
format compact

% load the file with elevation data
%fprintf('... Loading elevations:\n %s\n', char(INI.FILE_ELEVATION));
%rjf; not needed?
%%%load(INI.FILE_ELEVATION,'-mat');

%load the file with observed and computed data
%%%FILEDATA = [INI.ANALYSIS_DIR_TAG '/' INI.ANALYSIS_TAG '_TIMESERIES_DATA.MATLAB'];
FILEDATA = INI.FILESAVE_TS;
fprintf('\n\n--Loading computed and observed data from file:\n\t %s', char(FILEDATA));
load(FILEDATA, '-mat');

%setup the file where data will be saved as a structure which can be loaded
%in MATLAB subsequently.
%%%FILESAVE = [INI.ANALYSIS_DIR_TAG '/' INI.ANALYSIS_TAG '_TIMESERIES_STAT.MATLAB'];
FILESAVE = INI.FILESAVE_STAT;
%fprintf('\n... Computed and observed stat data will be saved in file: %s\n', char(FILESAVE))


% to select a list of station either use the line below. For selected
% stations rerun the entire script sequence A0, A1,...
% STATIONS_LIST = INI.SELECTED_STATIONS.data.list;
%do it with the map
%keys(INI.SELECTED_STATIONS.MAP)

% this processes the statistics of all stations from the MIKE SHE and MIKE
% 11 dfs0 result files.

% reduce timeseries to daily

i = 0;
tStart = INI.ANALYZE_DATE_I;
tEnd = INI.ANALYZE_DATE_F;
nD = length(INI.MODEL_ALL_RUNS)+1;
TIMEVECTOR =  [datenum(tStart):1:datenum(tEnd)]';
TIMESERIES(1:1:length(TIMEVECTOR),1:1:nD) = NaN;

KEYS = keys(MAP_ALL_DATA);
ind = ismember(INI.SELECTED_STATIONS,KEYS);
INI.SELECTED_STATIONS = INI.SELECTED_STATIONS(ind);
STATIONS_LIST = INI.SELECTED_STATIONS;
fprintf('\n--Processing station data:');

for M =  STATIONS_LIST % {'{'T19'}'} % % this uses only the list of the selected stations
    i = i + 1;
    M = strtrim(M);
    fprintf('\n %4d  %-25s', i, char(M));
    try
        STATION = MAP_ALL_DATA(char(M));  %get a tmp structure, modify values
        STATION.TIMEVECTOR = TIMEVECTOR;
        STATION.TIMESERIES = TIMESERIES;
        STATION.DFSTYPE = STATION.DATATYPE;
        for ii = 1:nD
            DV = STATION.DATA(ii).TIMESERIES;
            TV = STATION.DATA(ii).TIMEVECTOR;
            if ~isempty(DV)
                DATA_DAILY = get_daily_data(DV,TV,TIMEVECTOR);
                STATION.TIMESERIES(:,ii) = DATA_DAILY(:);
            end
        end
        MAP_ALL_DATA(char(M)) = STATION; % modify the value for this key
    catch
        fprintf('\t---> data for \"%s\" not found in MAP_ALL_DATA container', char(M));
    end
end
fprintf('\n');

i = 1;
fprintf('\n--Processing station stats:');
for M =  STATIONS_LIST% {'3A28'} %%  % this uses only the list of the selected stations
    fprintf('\n %4d  %-25s', i, char(M));
    try
        STATION = MAP_ALL_DATA(char(M));  %get a tmp structure, modify values
        STATION.NAME = STATION.STATION_NAME;
        try
            TS_NAN_STR = remove_nan(STATION,INI); % remove pairs that have NaN
            STATION.TS_NAN = TS_NAN_STR;
            STATION = get_station_stat(STATION); % make all station stats;
            try
                STATION.Z_GRID = cell2mat(INI.MAPXLS.MSHE(char(k)).gridgse);
            catch
                STATION.Z_GRID = -1.0e-35;
            end
            MAP_ALL_DATA(char(M)) = STATION; % modify the value for this key
        catch
            fprintf('\t---> No observations, skipping \"%s\"',char(STATION.NAME));
        end
    catch
        fprintf('\t---> Cannot find \"%s\" in MAP_ALL_DATA container', char(M));
    end
    i = i + 1;
end
fprintf('\n')

fprintf('\n--Saving data in file:\n\t %s\n', char(FILESAVE))
save(FILESAVE,'MAP_ALL_DATA','-v7.3');
%test code
try
    %STATION = MAP_ALL_DATA (char(K));
    K = '3A28';
    STATION = MAP_ALL_DATA (char(K));
    K = 'G211_Q';
    STATION = MAP_ALL_DATA (char(K));
catch
end

end

function DATA_DAILY = get_daily_data(DINST,TINST,TIMEVECTOR)

%use only specified vector timeserie

DINST = DINST(TINST>=TIMEVECTOR(1));
TINST = TINST(TINST>=TIMEVECTOR(1));
DINST = DINST(TINST<=TIMEVECTOR(end));
TINST = TINST(TINST<=TIMEVECTOR(end));
DATA_DAILY = TIMEVECTOR;
DATA_DAILY(:) = NaN;

[y,m,d,h,mi,s] = datevec(TINST);
DATE_VEC = [y,m,d,h,mi,s];

DD_ARRAY = [y,m,d];DD_ARRAY = unique(DD_ARRAY,'rows','stable');

%extract values for the specified vector
n = length(DD_ARRAY);
DRED.DD_WAVE(1:n) = NaN; % daily weighted average
% DRED.DD_AVE(1:n) = NaN; % daily  average
% DRED.DD_WSUM(1:n) = NaN; % daily weighted sumation
% DRED.DD_SUM(1:n) = NaN; % dailly  sumation

for i = 1:n
    yy = DD_ARRAY(i,1);
    mm = DD_ARRAY(i,2);
    dd = DD_ARRAY(i,3);
    I1 = find(DATE_VEC(:,1)==yy & DATE_VEC(:,2)==mm &DATE_VEC(:,3)==dd ); % select year
    t1 = TINST(I1); % selected time vector
    DT = diff(t1)*86400; % difference in seconds
    X = DINST(I1); % determine number of seconds per period
    % weighted average
%     DRED.DD_AVE(i) = mean(X); % simple average
%     DRED.DD_SUM(i) = sum(X); % sumation for rainfall, ET, PET
    if isempty(DT)
        DRED.DD_WAVE(i) = X;
%         DRED.DD_WSUM(i) = 86400*X;
    else
        DRED.DD_WAVE(i) = dot(X(1:end-1),DT)/sum(DT); % weighted average
%         DRED.DD_WSUM(i) = sum(times(X(1:end-1),DT)); %X*DT sumation for Flow
    end
end

IND = ismember(TIMEVECTOR,datenum(DD_ARRAY));

DATA_DAILY(IND) = DRED.DD_WAVE';
% check size of arrays
end