function [DATA] = preproc_read_DFE_file(INI, fileID)

formatString = '%s %s %s %s %*[^\n]';

n = 100000; % Read file in blocks in 10,000 lines, 
i = uint64(0); % counter

% initialize maps and vectors
% mapDATA_Q = containers.Map(); (unused)
% mapDATA_H = containers.Map(); (unused)
% Q_TIME = []; (unused)
% Q_VALUE = []; (unused)
% H_TIME = []; (unused)
% H_VALUE = []; (unused)
% 
% CURRENT_STATION = ''; (unused)
% n_st = 1; (unused)
FIELD_STATION = [];
% FIELD_DTYPE = []; (unused)
FIELD_TIME = [];
FIELD_MEASUREMENTS = [];

%tic;
while ~feof(fileID)

    D = textscan(fileID,formatString,'HeaderLines',9,'Delimiter','|','EmptyValue',NaN);
    i = i + n;
   try
      % Field 1 is station name. Convert this to uppercase
        STATION = upper(D{1}); % convert station to upper case
      % Field 2 is datatype. This is not used.
        %DTYPE = D{2}; (unused)
      % Field 3 is date or date-time
      % Field 4 is the measurement value
        D{5}=str2double(strrep(D{4},'null',''));                                                                  % Create new cell array column of measurement values
        B=split(D{3},' '); E = cellstr(B(:,1)); F = cellstr(strrep(B(:,2),':','')); % Split the date-time cell column into separate cell columns
        D{3} = E; D{4} = F; clear ('B','E','F')                                     % Rejoin cell columns to the cell array 'D' and clear excess variables
        % this section provides alternative handling of the hour:minute
        % values
        DN = str2double(D{4});
        if isnan(DN(1)), DN(1) = 0; end
        D0 = sprintf('%04d',DN(1));
        if length(DN) > 1
            for i2 = 2:length(DN)
                dn = DN(i2);
                if isnan(dn), dn = 0; end
                D0 = [D0; sprintf('%04d',dn)];
            end
        end
        TSTR = strcat(D{3},D0);
        % end alternative handling
        
        TIME = datenum(TSTR,'yyyy-mm-ddHHMM');
        DATEVEC = datevec(TIME);
        DATESTR = datestr(DATEVEC,31);
        MEASUREMENTS = D{5};

        % find all NaNs in the data vector
        IND =isnan(MEASUREMENTS);
        
        % Erase all  rows that have V=NaN's
        STATION(IND) = [];
        %DTYPE(IND) = []; (unused)
        TIME(IND) = [];
        MEASUREMENTS(IND) = [];
        
        FIELD_STATION = [FIELD_STATION; STATION];
        %FIELD_DTYPE = [FIELD_DTYPE; DTYPE]; (unused)
        FIELD_TIME = [FIELD_TIME; TIME];
        FIELD_MEASUREMENTS = [FIELD_MEASUREMENTS; MEASUREMENTS];

   catch
      if INI.DEBUG
        fprintf('EXCEPTION: %d::%s::%s::D0 = %s\n', i, char(STATION(1)), ...
            char(TSTR(1)),char(D0(1)));
        fprintf('EXCEPTION::CONTINUING::\n');
        %        error(errorStruct);
      end
        continue
    end
    if INI.DEBUG && (mod(i,n)==0 || ~feof(fileID))
        toc;
           fprintf('... %d\t:%s:: %s: %s :: %s\n', length(FIELD_MEASUREMENTS), ...
               char(STATION(1)), DATESTR(1), MEASUREMENTS(1));
        tic;
    end    
end

% eliminate dates earlier than 1960, there were some errors in the database
% resulting in reading dates that were negative (once case is S_331_S_173)

IND = find(FIELD_TIME<715876); 
FIELD_STATION(IND) = [];
% FIELD_DTYPE(IND) = []; (unused)
FIELD_TIME(IND) = [];
FIELD_MEASUREMENTS(IND) = [];

% create a structure
DATA.STATION = FIELD_STATION;
% DATA.DTYPE = upper(FIELD_DTYPE); (unused)
DATA.TIME = FIELD_TIME;
DATA.MEASUREMENTS = FIELD_MEASUREMENTS;

%STATION = unique(DATA.STATION); (unused)
%TYPE = unique(DATA.DTYPE); (unused)
end