function [DATA, STATION, TYPE] = read_file_DFS0_PNTRO(fileID)

% THIS IS PROBSBLY THE WRONG FUNCTION AND IS NOT USED IN THE MAIN
% analysis_DFS0_Q_.m function.

formatString = '%s %s %s %s %f %s %s %s %s %s %s';
%,'Delimiter','^','EmptyValue',NaN,'Whitespace','';

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
FIELD_STR_REMAIN = [];

tic;
while ~feof(fileID)
   %    tline = fgetl(fileID);
   % use the line below if the file is really large, 1 GB for example
   %D = textscan(fileID,formatString, n,'Delimiter','^','EmptyValue',NaN);
   D = textscan(fileID,formatString, 'Delimiter','^','EmptyValue',NaN);
   i = i + n;
   try
      STATION = D{1};
      DTYPE = D{2};
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
      STR_REMAIN = strcat(D{6},':',D{7},':',D{8},':',D{9},':',D{10},':',D{11});
      
      % find all NaNs in the data vector
      IND =isnan(V);
      
      % Erase all  rows that have V=NaN's
      STATION(IND) = [];
      DTYPE(IND) = [];
      TIME(IND) = [];
      V(IND) = [];
      STR_REMAIN(IND) = [];
      
      FIELD_STATION = [FIELD_STATION; STATION];
      FIELD_DTYPE = [FIELD_DTYPE; DTYPE];
      FIELD_TIME = [FIELD_TIME; TIME];
      FIELD_V = [FIELD_V; V];
      FIELD_STR_REMAIN = [FIELD_STR_REMAIN; STR_REMAIN];
   catch
      fprintf('EXCEPTION (D): %d::%s::%s::%s::D0 = %s\n', i, char(STATION(1)), ...
         char(DTYPE(1)),char(TSTR(1)),char(D0(1)));
      fprintf('EXCEPTION::CONTINUING::\n');
      %        error(errorStruct);
      continue
   end
   if mod(i,n)==0 || ~feof(fileID)
      toc;
      fprintf('... %d\t:%s:: %s: %s=%f :: %s\n', length(FIELD_V), ...
         char(STATION(1)), DATESTR(1), char(DTYPE(1)), V(1), ...
         char(STR_REMAIN(1)));
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
FIELD_STR_REMAIN(IND) = [];

% create a structure
DATA.STATION = FIELD_STATION;
DATA.DTYPE = upper(FIELD_DTYPE);
DATA.TIME = FIELD_TIME;
DATA.V = FIELD_V;
DATA.STR_REMAIN = FIELD_STR_REMAIN;

STATION = unique(DATA.STATION);
TYPE = unique(DATA.DTYPE);
end