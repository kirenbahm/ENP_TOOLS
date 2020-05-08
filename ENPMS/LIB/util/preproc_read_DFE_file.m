function [DATA] = preproc_read_DFE_file(myFILE)

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


% read file

fileID = fopen( myFILE );
formatString = '%s %s %s %f %*[^\n]';
fileData = textscan(fileID,formatString,'HeaderLines',9,'Delimiter','|','EmptyValue',NaN);
[~] = fclose( fileID );


%-----------------------------------
% FIELD 1:  STATION NAME
%-----------------------------------
%   Convert this to uppercase
FIELD_STATION = upper(fileData{1});

%-----------------------------------
% FIELD 2:  DATATYPE
%-----------------------------------
%   Datatype is not used

%-----------------------------------
% FIELD 3:  DATE-TIME
%-----------------------------------

try
    try
        % the next two lines provide for two types of input formats.
        % it is expected that times will match one of the formats, and will be put in the corresponding array. the other parts of the array will be NaN.
        % the arrays should contain all the timestamps between them, with no
        % overlap.
        % (if the hour is 24:00 or above, it will not process correctly and
        % might error)
        myTimes1 = datenum(datetime(fileData{3},'Inputformat','yyyy-MM-dd HH:mm'));
        fprintf(' myTimes1 successful ');
    catch
        fprintf(' myTimes1 failed ');
        myTimes1 = 0;
    end
    
    try
        myTimes2 = datenum(datetime(fileData{3},'Inputformat','yyyy-MM-dd'' null'));
        fprintf(' myTimes2 successful ');
    catch
        fprintf(' myTimes2 failed ');
        myTimes2 = 0;
    end
catch
    fprintf(' couldnt parse date-time format ');
end

% next we convert any NaN values to zeros so the arrays can be added
iznan = isnan(myTimes1);
myTimes1(iznan) = 0;
iznan = isnan(myTimes2);
myTimes2(iznan) = 0;

% this adds the arrays, creating one complete date-time array for the
% two complimentary arrays
FIELD_TIME = myTimes1 + myTimes2;

%-----------------------------------
% FIELD 4:  MEASUREMENT VALUE
%-----------------------------------
% Take measurement value strings, remove any strings that say 'null', convert to double, and save
FIELD_MEASUREMENTS = fileData{4};


%-----------------------------------
% find all NaNs in the data vector, and erase all associated rows in other arrays
isDataNaN =isnan(FIELD_MEASUREMENTS);

FIELD_STATION(isDataNaN) = [];
FIELD_TIME(isDataNaN) = [];
FIELD_MEASUREMENTS(isDataNaN) = [];

%-----------------------------------

% create a structure
DATA.STATION = FIELD_STATION;
DATA.TIME = FIELD_TIME;
DATA.MEASUREMENTS = FIELD_MEASUREMENTS;

end