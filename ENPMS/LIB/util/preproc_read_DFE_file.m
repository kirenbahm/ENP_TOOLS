function [DATA] = preproc_read_DFE_file(INI, fileID)

% Expected data formats:
% station_name|datatype|date-time(YYYY-MM-DD HH:MM)|measurement_value|other_unneeded_data
% 
% Example data strings:
% 3A28|stage|1957-01-22 null|7.7400|
% 3A28|stage|1958-06-18 null||1996-06-07
% 3A28|stage|1958-06-19 null||
% 3A28|stage|1983-06-19 null|8.9500|2003-02-03
% 3A28|stage|2019-02-08 23:45|9.3700|
% 3A28|stage|2019-02-09 00:00|9.3700|
% C111W15|stage_realtime|2015-05-29 07:45|1.9600|2015-05-29
% S332BW|tail_water|2000-04-08 null||


formatString = '%s %s %s %s %*[^\n]';

n = 100000; % Read file in blocks in 10,000 lines,
i = uint64(0); % counter

FIELD_STATION = [];
% FIELD_DTYPE = []; (unused)
FIELD_TIME = [];
FIELD_MEASUREMENTS = [];

%tic;
while ~feof(fileID)

    fileData = textscan(fileID,formatString,'HeaderLines',9,'Delimiter','|','EmptyValue',NaN);
    i = i + n;
    try
        %-----------------------------------
        % FIELD 1:  STATION NAME
        %-----------------------------------
        %   Convert this to uppercase
        STATION = upper(fileData{1});
        
        %-----------------------------------
        % FIELD 2:  DATATYPE
        %-----------------------------------
        %   Datatype is not used
        % DTYPE = fileData{2};
        
        %-----------------------------------
        % FIELD 4:  MEASUREMENT VALUE
        %-----------------------------------
        % Take measurement value strings, remove any strings that say 'null', convert to double, and save
        MEASUREMENTS = str2double(strrep(fileData{4},'null',''));
        
        %-----------------------------------
        % FIELD 3:  DATE ~OR~ DATE-TIME
        %-----------------------------------

        myDATEandTIME=split(fileData{3},' '); % Split the date-time cell column into separate cell columns
        myDATE = cellstr(myDATEandTIME(:,1)); % Put date strings into one cell array (YYYY-MM-DD)
        myTIME = cellstr(strrep(myDATEandTIME(:,2),':','')); % Put time strings into a cell array without ':' (HHMM)

        %-----
        % this section provides alternative handling of the hour:minute values
        myTIMEdouble = str2double(myTIME);

        % evaluate first element in the array, and write first element in new array
        if isnan(myTIMEdouble(1)), myTIMEdouble(1) = 0; end
        myOtherTimesString = sprintf('%04d',myTIMEdouble(1));
        
        % if more than one element in array, evaluate and append subsequent elements to new array
        if length(myTIMEdouble) > 1
            for myTimeIndex = 2:length(myTIMEdouble)
                currentIndexTime = myTIMEdouble(myTimeIndex);
                if isnan(currentIndexTime), currentIndexTime = 0; end
                myOtherTimesString = [myOtherTimesString; sprintf('%04d',currentIndexTime)];
            end
        end
        
        TSTR = strcat(myDATE,myOtherTimesString); % concatenate into new array, format 'yyyy-mm-ddHHMM'
        % end alternative handling
        %-----
        
        myNewDateTime= datenum(TSTR,'yyyy-mm-ddHHMM');
        myDATEVEC = datevec(myNewDateTime);
        myDATEandTIMEstring = datestr(myDATEVEC,31);
        
        %-----------------------------------
        % find all NaNs in the data vector, and erase all associated rows in other arrays
        isDataNaN =isnan(MEASUREMENTS);
        
        STATION(isDataNaN) = [];
        %DTYPE(isDataNaN) = []; (unused)
        myNewDateTime(isDataNaN) = [];
        MEASUREMENTS(isDataNaN) = [];
        
        %-----------------------------------
        
        FIELD_STATION = [FIELD_STATION; STATION];
        %FIELD_DTYPE = [FIELD_DTYPE; DTYPE]; (unused)
        FIELD_TIME = [FIELD_TIME; myNewDateTime];
        FIELD_MEASUREMENTS = [FIELD_MEASUREMENTS; MEASUREMENTS];
        
    catch
        if INI.DEBUG
            fprintf('EXCEPTION: %d::%s::%s::D0 = %s\n', i, char(STATION(1)), ...
                char(TSTR(1)),char(myOtherTimesString(1)));
            fprintf('EXCEPTION::CONTINUING::\n');
            %        error(errorStruct);
        end
        continue
    end
    if INI.DEBUG && (mod(i,n)==0 || ~feof(fileID))
        toc;
        fprintf('... %d\t:%s:: %s: %s :: %s\n', length(FIELD_MEASUREMENTS), ...
            char(STATION(1)), myDATEandTIMEstring(1), MEASUREMENTS(1));
        tic;
    end
end

%-----------------------------------
% eliminate dates earlier than 1960
% (there were some errors in the database resulting in reading dates that were negative (once case is S_331_S_173))

isTimeBefore1960 = find(FIELD_TIME<715876);

FIELD_STATION(isTimeBefore1960) = [];
% FIELD_DTYPE(isTimeNaN) = []; (unused)
FIELD_TIME(isTimeBefore1960) = [];
FIELD_MEASUREMENTS(isTimeBefore1960) = [];
%-----------------------------------

% create a structure
DATA.STATION = FIELD_STATION;
% DATA.DTYPE = upper(FIELD_DTYPE); (unused)
DATA.TIME = FIELD_TIME;
DATA.MEASUREMENTS = FIELD_MEASUREMENTS;

%STATION = unique(DATA.STATION); (unused)
%TYPE = unique(DATA.DTYPE); (unused)
end