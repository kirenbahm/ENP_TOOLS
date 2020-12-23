function [DATA] = preproc_flag_DFE_file(myFILE, myFLAG, DFS0name, UseDfsFlags, DType_Flag, lowerRange, upperRange, constantPeriodLimit)
% This function reads a dat file, and optionally a dfs0 file.
% The  funcions takes this information and writes a copy of the dat file
% with data flags as well as outputs the values and flags to be written to
% a 3-column dfs0 files.
% Input:
%    myFILE - Full file path of dat file to read
%    myFLAG - Full file path of flagged dat file to write
%    DFS0name - Full file path of flagged 3-column dfs0 file to read
%    UseDfsFlags - boolean of whether to use 3-column dfs0 to flag dat file
%    DType_Flag - used to flag if stage or flow
%    lowerRange - lower acceptable range for values
%    upperRange - upper acceptable range for values
%    constantPeriodLimit - acceptable range for values to be constant
% Output:
%    Structure containing time series data from the dat file
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

% edited by Kiren Bahm and Lago Consulting

NET.addAssembly('DHI.Generic.MikeZero.EUM');
NET.addAssembly('DHI.Generic.MikeZero.DFS');
H = NETaddDfsUtil();
eval('import DHI.Generic.MikeZero.DFS.*');
eval('import DHI.Generic.MikeZero.DFS.dfs123.*');
eval('import DHI.Generic.MikeZero.*');

%----------------------------------
% initialize variables

StationHeader = "";
AgencyHeader = "";
GroundElevHeader = "";
LatitudeHeader = "";
LongitudeHeader = "";
DatumHeader = "";
ConversionHeader = "";

ConversionVal = 0.0;

validStageStationElevation = false;
validConversionValue       = false;
%validStationDatum          = false;
stageStationElevInNGVD29        = false;
stageStationElevInNAVD88        = false;

%----------------------------------
% Open file:

fileID = fopen( myFILE );
flagID = fopen(myFLAG,'W');
[~, fn, ~] = fileparts(myFILE);

StationNameParse = split(fn, ".");

%===================================================================
%  PARSE HEADER INFORMATION - set flags and print warnings
%===================================================================

%----------------------------------
% STATION NAME  (Header Line One)
%----------------------------------
% example: "#station: ESC"

tline = fgetl(fileID);
HeaderParse = split(tline, ":");

% check if station name matches filename - print warning if not
if strcmp(strtrim(HeaderParse{2}), StationNameParse{1})
    StationHeader = char(tline);
else
    StationHeader = strcat(tline," (Station name doesn't match filename)");
    fprintf(" BAD_StationName");
end

%----------------------------------
% AGENCY  (Header Line Two)
%----------------------------------
% example: "#agency: USGS"

tline = fgetl(fileID);
AgencyHeader = char(tline);

%----------------------------------
% STATION GROUND SURFACE ELEVATION  (Header Line Three)
%----------------------------------
% example: "#ground surface elevation ft: 4.3"
% example: "#ground surface elevation ft: Missing"

tline = fgetl(fileID);
HeaderParse = split(tline, ":");

% if this file is stage data (not flow data),
% print a warning if station elevation is not a valid number
if strcmpi(DType_Flag,'Water Level')
    % if value is a valid number, copy to outfile
    if ~isnan(str2double(HeaderParse{2}))
        GroundElevHeader = tline;
        validStageStationElevation = true;
    % else copy to outfile and add warning
    else
        GroundElevHeader = strcat(tline," (Should be numeric value)");
        fprintf(" BAD_GSE");
    end

% if this file is NOT stage data (ie. is flow data),
% DON'T print a warning if station elevation is not a valid number
% (but DO print a warning if value is not properly labeled as 'Missing')
else
    % if elev is a number, print as-is
    if ~isnan(str2double(HeaderParse{2}))
        GroundElevHeader = tline;
    % if elev is properly labeled as mission, print as-is
    elseif strcmpi(strtrim(HeaderParse{2}),'Missing')
        GroundElevHeader = char(tline);
    % else print as-is but add warning
    else
        GroundElevHeader = strcat(tline," (Should be 'Missing')");
        fprintf(" BAD_GSE");
    end
end

%----------------------------------
% LATITUDE  (Header Line Four)
%----------------------------------
tline = fgetl(fileID);
HeaderParse = split(tline, ":");
if ~isnan(str2double(HeaderParse{2}))
    LatitudeHeader = char(tline);
else
    LatitudeHeader = strcat(tline," (Should be numeric value)");
    fprintf(" BAD_Lat");
end

%----------------------------------
% LONGITUDE  (Header Line Five)
%----------------------------------
tline = fgetl(fileID);
HeaderParse = split(tline, ":");
if ~isnan(str2double(HeaderParse{2}))
    LongitudeHeader = char(tline);
else
    LongitudeHeader = strcat(tline," (Should be numeric value)");
    fprintf(" BAD_Lon");
end

%----------------------------------
% STATION VERTICAL DATUM  (Header Line Six)
%----------------------------------
% example: "#vertical datum:"
% example: "#vertical datum: NGVD29"
% example: "#vertical datum: NAVD88"
% example: "#vertical datum: LOCAL"

tline = fgetl(fileID);
HeaderParse = split(tline, ":");

% Check for values that need to be converted from NAVD88 to NGVD29 for subsequent scripts
% If Datum is NAVD88 conversion will occur later in script

if strcmp(strtrim(HeaderParse{2}),'NGVD29')
%    validStationDatum = true;
    DatumHeader = char(tline);
    stageStationElevInNGVD29 = true;
elseif (strcmp(strtrim(HeaderParse{2}),'NAVD88'))
%    validStationDatum = true;
    DatumHeader = char(tline);
    stageStationElevInNAVD88 = true;
else
    DatumHeader = strcat(tline," (Improper Datum)");
    fprintf(" BAD_Datum");
end

%----------------------------------
% DATUM CONVERSION VALUE  (Header Line Seven)
%----------------------------------
% example: "#conversion: -1.440"
% example: "#conversion: 0.000"

tline = fgetl(fileID);
HeaderParse = split(tline, ":");

% Flag if conversion value is not a number, or is 0.0.
% Otherwise, save header as is.
% (Conversion value of 0.0 is not possible in Florida.)
% Also save conversion value for later use.

ConversionVal = str2double(HeaderParse{2});
if ~isnan(ConversionVal)
    if (ConversionVal == 0.0)
        ConversionHeader = strcat(tline," (Datum conversion should not be 0.0)");
        fprintf(" BAD_Conversion");
        ConversionVal = NaN; % set any 0.0 values to NaN because they are incorrect
    else % else conversion value is non NaN and is not 0.0 (it is good)
        ConversionHeader = char(tline);
        validConversionValue = true;
    end
else % else conversion value is NaN
    ConversionHeader = strcat(tline," (Should be numeric value)");
    fprintf(" BAD_Conversion");
end

%----------------------------------
% EMPTY LINE  (Header Line Eight)
%----------------------------------
tline = fgetl(fileID);
EmptyLineHeader = char(tline);

%----------------------------------
% DATA HEADER LINE  (Header Line Nine)
%----------------------------------
% example: "#stn|type|date time|value(feet)|validation_date"

tline = fgetl(fileID);
DataValuesHeader = strcat(tline,"|Flag");

%----------------------------------
% CONVERT ANY STAGE STATION ELEVATION IN NAVD88 to NGVD29
% (and update Header info accordingly)
%----------------------------------
if (stageStationElevInNAVD88 && validStageStationElevation && validConversionValue)

    % Convert station elevation to NGVD29 and update GroundElevHeader
    HeaderParse = split(GroundElevHeader, ":");
    newStationElevString = num2str(str2double(strtrim(HeaderParse{2})) - ConversionVal);
    GroundElevHeader = strcat(HeaderParse{1}, ": ", newStationElevString);
    
    % Update Station Datum Header
    DatumHeader = strrep(DatumHeader,"NAVD88","NGVD29");
end 
  
%----------------------------------
% PRINT NEW HEADER TO OUTFILE AND CLOSE
%----------------------------------
fprintf(flagID, "%s\n", StationHeader);
fprintf(flagID, "%s\n", AgencyHeader);
fprintf(flagID, "%s\n", char(GroundElevHeader));
fprintf(flagID, "%s\n", LatitudeHeader);
fprintf(flagID, "%s\n", LongitudeHeader);
fprintf(flagID, "%s\n", DatumHeader);
fprintf(flagID, "%s\n", ConversionHeader);
fprintf(flagID, "%s\n", EmptyLineHeader);
fprintf(flagID, "%s\n", DataValuesHeader);

[~] = fclose( fileID );
fprintf(" ... ");

%===================================================================
%  BEGIN PARSE OF TIMESERIES DATA
%===================================================================

%----------------------------------
% Open file and scan measurement data (skip first 9 header lines)
%-----------------------------------
fileID = fopen( myFILE );
formatString = '%s %s %s %s %s %s %*[^\n]';
fileData = textscan(fileID,formatString,'HeaderLines',9,'Delimiter','|','EmptyValue',NaN);
[~] = fclose( fileID );

% Save data into arrays
Station    = fileData{1}; % Raw Data station Names
Type       = fileData{2}; % Raw Data Station Type (Flow or Stage)
Time       = fileData{3}; % Raw Data DateTimes
DataText   = fileData{4}; % Raw Data Measurements
DataDouble = str2double(fileData{4}); %Raw Data Measurements converted to doubles
Validation = fileData{5}; % Raw Data Validation date

%----------------------------------
% Process measurements for datum conversion
%  If datum is known and conversion is possible, convert to NAVD29
%  If datum is unknown, change data to NaN
%-----------------------------------

% Create array where value is zero if datatype='stage_ngvd29'. 
% Multiply datum offset by this to zero out offset conversion 
% of measurement datatype is already ngvd29

% if data are flow values, copy data without conversion
if strcmpi(DType_Flag,'Discharge')
    FIELD_MEASUREMENTS = DataDouble;
    Measurements = DataDouble;

% else if datatype is specified to be NGVD29, copy data without conversion
elseif strcmp(Type(1),'stage_ngvd29')
    FIELD_MEASUREMENTS = DataDouble;
    Measurements = DataDouble;

% else if datatype is specified to be NAVD88, and conversion is available,
% convert to NGVD29, otherwise set to NaN
elseif strcmp(Type(1),'stage_navd88')
    if validConversionValue
        FIELD_MEASUREMENTS = DataDouble - ConversionVal;
        Measurements = DataDouble - ConversionVal;
    else
        FIELD_MEASUREMENTS = NaN; %*%*%*%*%*%*%*%*%*%
        Measurements = NaN; %*%*%*%*%*%*%*%*%*%
    end
    
% otherwise this is stage data that is either:
%    1) in the same datum as the station, if the station has a datum
%    2) not referenced to a datum, if the station has no datum
else
    % if station datum is NGVD29, copy data as-is
    if  stageStationElevInNGVD29
        FIELD_MEASUREMENTS = DataDouble;
        Measurements = DataDouble;
        
    % if station datum is NAVD88 and conversion is valid, convert data
    elseif  (stageStationElevInNAVD88 && validConversionValue)
        FIELD_MEASUREMENTS = DataDouble - ConversionVal;
        Measurements = DataDouble - ConversionVal;

    % otherwise set data to NaN
    else
        FIELD_MEASUREMENTS = DataDouble * NaN; %*%*%*%*%*%*%*%*%*%
        Measurements = DataDouble * NaN; %*%*%*%*%*%*%*%*%*%
    end
end


%----------------------------------
% Set all 'NaN' measurements to value '-1e-35'
% in FIELD_MEASUREMENTS array
%----------------------------------
isDataNaN =isnan(FIELD_MEASUREMENTS);
FIELD_MEASUREMENTS(isDataNaN) = -1e-35;

%----------------------------------
% Place revised data from manual QA/QC of dfs0 files
%  into arrays dfsTime and dfsData  (if requested)
%-----------------------------------
if UseDfsFlags
    try
        dfs0FileName = [DFS0name '.dfs0'];
        dfs  = DfsFileFactory.DfsGenericOpen(dfs0FileName);
        dfsData = double(MatlabDfsUtil.DfsUtil.ReadDfs0DataDouble(dfs));
        dfsTime = zeros(size(dfsData, 1), 1);
        Y = double(dfs.FileInfo.TimeAxis.StartDateTime.Year);
        M = double(dfs.FileInfo.TimeAxis.StartDateTime.Month);
        D = double(dfs.FileInfo.TimeAxis.StartDateTime.Day);
        Hr = double(dfs.FileInfo.TimeAxis.StartDateTime.Hour);
        Mn = double(dfs.FileInfo.TimeAxis.StartDateTime.Minute);
        S = double(dfs.FileInfo.TimeAxis.StartDateTime.Second);
        DateTime0 = datenum(Y, M, D, Hr, Mn, S);
        for ti = 1:size(dfsTime, 1)
            dfsTime(ti, 1) = (dfsData(ti, 1) / 86400.0) + DateTime0;
        end
        dfs.Close();
    catch
        fprintf('dfs0 read error, skipping...');
        UseDfsFlags = false;
    end
end

%----------------------------------
% Convert station name to uppercase
%-----------------------------------
% This is to avoid problems later in processing
% because the code is not case-sensitive

FIELD_STATION = upper(fileData{1});

%-----------------------------------
% Process DATE-TIME arrays 
%-----------------------------------
% (two different datetime formats are possible, 
% and each file can have both intermixed. This code reads both types and
% creates one new datetime array in our desired format)
try
    try
        % the next two lines provide for two types of input formats.
        % it is expected that times will match one of the formats, and will be put in the corresponding array. the other parts of the array will be NaN.
        % the arrays should contain all the timestamps between them, with no
        % overlap.
        % (if the hour is 24:00 or above, it will not process correctly and
        % might error)
        myTimes1 = datenum(datetime(fileData{3},'Inputformat','yyyy-MM-dd HH:mm'));
        %fprintf(' myTimes1 successful. ');
    catch
        %fprintf(' myTimes1 failed. ');
        myTimes1 = 0;
    end
    
    try
        myTimes2 = datenum(datetime(fileData{3},'Inputformat','yyyy-MM-dd'' null'));
        %fprintf(' myTimes2 successful. ');
    catch
        %fprintf(' myTimes2 failed. ');
        myTimes2 = 0;
    end
catch
    fprintf(' couldnt parse date-time format. ');
end

% next we convert any NaN values to zeros so the time arrays can be added
iznan = isnan(myTimes1);
myTimes1(iznan) = 0;
iznan = isnan(myTimes2);
myTimes2(iznan) = 0;

% this adds the time arrays, creating one complete date-time array for the
% two complimentary arrays
FIELD_TIME = myTimes1 + myTimes2;

%-----------------------------------
% Loop through measurement data and perform checks
%-----------------------------------

% Initialize variables
dataSize = size(fileData{4});
FlagsNum = ones(dataSize(1), dataSize(2)); % Stores Numeric Flag for .dfs0 files
FlagsText = cell(dataSize(1), dataSize(2)); % Stores text flag for .dat files
stagnant = 0; % for checking how many lines the data has been constant
dfsi = 1; % index for position in dfs0 file if using flagged dfs0
% Some checks need some time to see if entries need to be flagged, such as
% stage remaining constant. Last write stores the index of the line that
% need sto be written next. That way the data only needs to be looped
% through once and you can use the last write index only with your current
% index to write all necessary lines.
lastwrite = 1;

% Loop through data and check
for di = 1:dataSize(1)
    try
        % CHECK FOR FLAGS IN DFS0 FILE
        % If using dfs0 flags, find first time step in dfs0 that is not prior to current timestep in raw
        if UseDfsFlags
            while FIELD_TIME(di) > dfsTime(dfsi)
                dfsi = dfsi + 1;
            end
        end
        % If using dfs0 flags, flag data as original or modified
        %   (if raw data matches, and DateTime matches)
        if UseDfsFlags && Measurements(di) == round(dfsData(dfsi, 2),4) && FIELD_TIME(di) == dfsTime(dfsi)
            if dfsData(dfsi, 3) == 1
                FlagsNum(di) = 1; % flag as original
                Measurements(di) = dfsData(dfsi, 2); % use adjusted measurement from dfs0
            elseif dfsData(dfsi, 3) == 2
                FlagsNum(di) = 2; % flag as modified
                Measurements(di) = dfsData(dfsi, 4); % use adjusted measurement from dfs0
                FlagsText{di} = strcat("M", num2str(Measurements(di))); % Contain modified numbers, if applicable
            else
                FlagsNum(di) = 0; % flag as original
                Measurements(di) = dfsData(dfsi, 4);
                FlagsText{di} = "Dfs0 Flagged Data"; % Contain modified numbers, if applicable
            end
            
        % PERFORM STANDARD DATA CHECKS    
        % If not using dfs0 flags, process measurement value by checking:
        %    if NaN, -Inf, value out of range, invalid datetime, 
        %    or repeating number
        else
            if isnan(Measurements(di,1)) % checks if value at timestep is nan
                Measurements(di, 1) = -1e-35;
                FlagsNum(di, 1) = 0;
                FlagsText{di, 1} = "Not a Number";
            elseif Measurements(di,1) == Inf || Measurements(di,1) == -Inf % checks if value at timestep is infinity
                Measurements(di, 1) = -1e-35;
                FlagsNum(di, 1) = 0;
                FlagsText{di, 1} = "Value was Infinity";
            elseif Measurements(di,1) < lowerRange % checks if value is too low
                Measurements(di, 1) = -1e-35;
                FlagsNum(di, 1) = 0;
                FlagsText{di, 1} = "Value below minimum range";
            elseif Measurements(di,1) > upperRange % checks if value is too high
                Measurements(di, 1) = -1e-35;
                FlagsNum(di, 1) = 0;
                FlagsText{di, 1} = "Value above maximum range";
            elseif FIELD_TIME(di,1) == 0 % Invalid DateTime Entry
                Measurements(di, 1) = -1e-35;
                FlagsNum(di, 1) = 0;
                FlagsText{di, 1} = "Invalid Datetime";
            elseif di > 1 % checks if value is constant for longer than specified period
                if Measurements(di, 1) == Measurements(di - 1, 1) && ~(strcmpi(DType_Flag,'discharge') && Measurements(di, 1) == 0)
                    stagnant = stagnant + 1;
                    if (FIELD_TIME(di,1) - FIELD_TIME(di - stagnant, 1)) >= constantPeriodLimit
                        FlagsNum((di - (stagnant - 1)):di - 1,1) = 0;
                        Measurements((di - (stagnant - 1)):di - 1, 1) = -1e-35;
                        for si = 1:stagnant - 1
                            FlagsText{di - si,1} = "Value is constant";
                        end
                    end
                else
                    stagnant = 0;
                end
                
            end
            
            % CHECK MIDNIGHT IS HOUR 24 or 00
            % check for date times where hour is 24:00, which is invalid. should be
            % 00:00. Works to place properly or mark as invalid.
            if ~isempty(myTimes1)
                timeCheck = strsplit(char(Time{di, 1}), ' ');
                if strcmp(timeCheck(2), '24:00')
                    prevMidnight = false;
                    nextMidnight = false;
                    if di < dataSize(1)
                        if mod(FIELD_TIME(di + 1), 1) == 0
                            nextMidnight = true;
                        end
                    end
                    if di > 1
                        prevdayi = di - 1;
                        numtime = datenum(datetime(timeCheck(1),'Inputformat','yyyy-MM-dd'));
                        while prevdayi > 0 && FIELD_TIME(prevdayi) > numtime
                            prevdayi = prevdayi - 1;
                        end
                        if FIELD_TIME(prevdayi) == numtime
                            prevMidnight = true;
                        end
                    end
                    if (prevMidnight && nextMidnight) || (~prevMidnight && nextMidnight)
                        Measurements(di, 1) = -1e-35;
                        FlagsNum(di, 1) = 0;
                        FlagsText{di, 1} = "Invalid DateTime";
                    elseif (prevMidnight && ~nextMidnight) || (~prevMidnight && ~nextMidnight)
                        FlagsNum{di, 1} = 2;
                        FIELD_TIME(di) = numtime + 1;
                    end
                end
            end
            
            % CHECK DATETIMES IN ORDER
            % Checks if date time is sorted, ie. if current datetime occurs
            % after previous and before next.
            % Examples
            % 1/1/2000 00:00, 1/1/2000 01:00, 1/1/2000 02:00 OK
            % 1/1/2000 00:00, 1/2/2000 01:00, 1/1/2000 02:00 BAD
            % 1/1/2000 00:00, 12/31/1999 01:00, 1/1/2000 02:00 BAD
            if di == 1 % For first element
                % if current datetime is later than next time step
                % Ex. 1/2/2000 is before 1/1/2000 
                if FIELD_TIME(di) > FIELD_TIME(di + 1) 
                    check = false;
                    % Limits check by additonally checking 2 ahead, if
                    % there is data
                    % Examples:
                    % First entry ok:
                    % 1/2/2000 00:00, 1/1/2000 00:00, 1/2/2000 01:00
                    % First entry bad:
                    % 1/2/2000 00:00, 1/1/2000 00:00, 1/1/2000 01:00 
                    if dataSize(1) > 2
                        check = FIELD_TIME(di) < FIELD_TIME(di + 2);
                    end
                    if ~check
                        Measurements(di, 1) = -1e-35;
                        FlagsNum(di, 1) = 0;
                        FlagsText{di, 1} = "Datetime Later than next timestep";
                    end
                end
            elseif di == dataSize(1) % for last element
                % if current datetime is earlier than previous time step
                % Ex. 1/1/2000 is after 1/2/2000 
                if FIELD_TIME(di) < FIELD_TIME(di - 1)
                    % Limits check by additonally checking 2 behind, if
                    % there is data
                    % Examples:
                    % Last entry ok:
                    % 1/1/2000 00:00, 1/2/2000 01:00, 1/1/2000 01:00
                    % Last entry bad:
                    % 1/2/2000 00:00, 1/2/2000 01:00, 1/1/2000 00:00 
                    check = false;
                    if dataSize(1) > 2
                        check = FIELD_TIME(di) > FIELD_TIME(di - 2);
                    end
                    if ~check
                        Measurements(di, 1) = -1e-35;
                        FlagsNum(di, 1) = 0;
                        FlagsText{di, 1} = "Datetime Earlier than prior timestep";
                    end
                end
            else
                % if current datetime is later than next time step
                % Ex. 1/2/2000 is before 1/1/2000 
                if FIELD_TIME(di) > FIELD_TIME(di + 1)
                    % Limits check by additonally checking 2 ahead, if
                    % there is data
                    % Examples:
                    % First entry ok:
                    % 1/2/2000 00:00, 1/1/2000 00:00, 1/2/2000 01:00
                    % First entry bad:
                    % 1/2/2000 00:00, 1/1/2000 00:00, 1/1/2000 01:00 
                    check = false;
                    if di + 2 <= dataSize(1)
                        check = FIELD_TIME(di) < FIELD_TIME(di + 2);
                    end
                    if ~check
                        Measurements(di, 1) = -1e-35;
                        FlagsNum(di, 1) = 0;
                        FlagsText{di, 1} = "Datetime Later than next timestep";
                    end
                % if current datetime is earlier than previous time step
                % Ex. 1/1/2000 is after 1/2/2000 
                elseif FIELD_TIME(di) < FIELD_TIME(di - 1)
                    % Limits check by additonally checking 2 behind, if
                    % there is data
                    % Examples:
                    % Last entry ok:
                    % 1/1/2000 00:00, 1/2/2000 01:00, 1/1/2000 01:00
                    % Last entry bad:
                    % 1/2/2000 00:00, 1/2/2000 01:00, 1/1/2000 00:00 
                    check = false;
                    if di - 2 >= 1
                        check = FIELD_TIME(di) > FIELD_TIME(di - 2);
                    end
                    if ~check
                        Measurements(di, 1) = -1e-35;
                        FlagsNum(di, 1) = 0;
                        FlagsText{di, 1} = "Datetime Earlier than prior timestep";
                    end
                end
            end
        end
        
        % WRITE DATA TO OUTPUT FILE
        % If first line write to file
        if di == 1
            if strcmp(DataText(di, 1), "")
                val = "";
            else
                val = num2str(FIELD_MEASUREMENTS(di, 1), '%.4f');
            end
            fprintf(flagID, "%s|%s|%s|%s|%s|%s\n", char(Station{di, 1}), char(Type{di, 1}),...
                char(Time{di, 1}), val, char(Validation{di, 1}), FlagsText{di, 1});
            lastwrite = di + 1;
            
        % else if value doesn't match previous value, value is nan, or is
        % last line, then write all lines to file between lastwrite index
        % and current one, "di".
        elseif FIELD_MEASUREMENTS(di, 1) ~= FIELD_MEASUREMENTS(di - 1, 1) || di == dataSize(1)|| isnan(Measurements(di, 1))
            for wi = lastwrite:di
                if strcmp(DataText(wi, 1), "")
                    val = "";
                else
                    val = num2str(FIELD_MEASUREMENTS(wi, 1), '%.4f');
                end
                fprintf(flagID, "%s|%s|%s|%s|%s|%s\n", char(Station{wi, 1}), char(Type{wi, 1}),...
                    char(Time{wi, 1}), val, char(Validation{wi, 1}), FlagsText{wi, 1});
            end
            lastwrite = di + 1;
        end
    catch
        %     fprintf('\nError on line %f\n',di + 9)
    end
end

%-----------------------------------
% close file
%-----------------------------------
[~] = fclose( flagID );

%-----------------------------------
% create and populate the output structure
%-----------------------------------
DATA.STATION      = FIELD_STATION;
DATA.TIME         = FIELD_TIME;
DATA.MEASUREMENTS = Measurements;
DATA.RAW          = FIELD_MEASUREMENTS;
DATA.FLAG         = FlagsNum;

end
