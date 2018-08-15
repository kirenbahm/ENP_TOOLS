function [DATA, STATION, TYPE] = D03_read_DFE_file(fileID)

formatString = '%s %s %s %s %*[^\n]';

n = 100000; % Read file in blocks in 10,000 lines, 
i = uint64(0); % counter

% initialize maps and vectors
mapDATA_Q = containers.Map();
mapDATA_H = containers.Map();
Q_TIME = [];
Q_VALUE = [];
H_TIME = [];
H_VALUE = [];

CURRENT_STATION = '';
n_st = 1;
FIELD_STATION = [];
FIELD_DTYPE = [];
FIELD_TIME = [];
FIELD_V = [];

tic;
while ~feof(fileID)

    D = textscan(fileID,formatString,'HeaderLines',9,'Delimiter','|','EmptyValue',NaN);
    i = i + n;
   try
        STATION = D{1};
        DTYPE = D{2};
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
        V = D{5};

        % find all NaNs in the data vector
        IND =isnan(V);
        
        % Erase all  rows that have V=NaN's
        STATION(IND) = [];
        DTYPE(IND) = [];
        TIME(IND) = [];
        V(IND) = [];
        
        FIELD_STATION = [FIELD_STATION; STATION];
        FIELD_DTYPE = [FIELD_DTYPE; DTYPE];
        FIELD_TIME = [FIELD_TIME; TIME];
        FIELD_V = [FIELD_V; V];

   catch
        fprintf('EXCEPTION: %d::%s::%s::%s::D0 = %s\n', i, char(STATION(1)), ...
            char(DTYPE(1)),char(TSTR(1)),char(D0(1)));
        fprintf('EXCEPTION::CONTINUING::\n');
        %        error(errorStruct);
        continue
    end
    if mod(i,n)==0 || ~feof(fileID)
        toc;
        fprintf('... %d\t:%s:: %s: %s=%f :: %s\n', length(FIELD_V), ...
            char(STATION(1)), DATESTR(1), char(DTYPE(1)), V(1));
        tic;
    end    
end

% eliminate dates earlier than 1960, there were some errors in the database
% resulting in reading dates that were negative (once case is S_331_S_173)

IND = find(FIELD_TIME<715876); 
FIELD_STATION(IND) = [];
FIELD_DTYPE(IND) = [];
FIELD_TIME(IND) = [];
FIELD_V(IND) = [];

% create a structure
DATA.STATION = FIELD_STATION;
DATA.DTYPE = upper(FIELD_DTYPE);
DATA.TIME = FIELD_TIME;
DATA.V = FIELD_V;

STATION = unique(DATA.STATION);
TYPE = unique(DATA.DTYPE);
end