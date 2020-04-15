function INI = readM11_WM(INI)

mapM11CompP = containers.Map;
[fp,fn,fe] = fileparts(INI.fileM11WM); 
ext = strfind(INI.fileM11WM,'.'); %Location of where extension begins
sizeExt = size(ext);
% check flag to use res11
 if (INI.USE_RES11)
 dfs0File = strcat(INI.fileM11WM(1:ext(sizeExt(2))),'dfs0');
 dfs0Exists = exist(dfs0File,'file');
 res11File = strcat(INI.fileM11WM(1:ext(sizeExt(2))),'res11');
 res11Exists = exist(res11File, 'file');
 % check if files exist;
 % if dfs0 and res11, use together
 if(dfs0Exists && res11Exists)
  fprintf('--- Reading file M11 results::%s and %s\n',char(dfs0File), char(res11File));
  DFS0 = read_file_DFS0(dfs0File);
  wi = 1; %stores end index of water level items
  sizetype = size(DFS0.TYPE); %for determining loop length
  % determines how much of dfs0 data to use
  for i=1:sizetype(2)
   if(~strcmp(DFS0.TYPE{i},'Water Level'))
    wi = i - 1;
    break;
   end
  end
  RES11 = read_file_RES11(res11File, 2);
  % concatinate applicable results together from both files
  DATA.T = DFS0.T;
  DATA.V = cat(2,DFS0.V(:,1:wi),RES11.V(2:end,:));
  DATA.TYPE = cat(2,DFS0.TYPE(1:wi),RES11.TYPE);
  DATA.UNIT = cat(2,DFS0.UNIT(1:wi),RES11.UNIT);
  DATA.NAME = cat(2,DFS0.NAME(1:wi),RES11.NAME);
 %elseif only use res11
 elseif (res11Exists)
  fprintf('--- Reading file M11 results::%s\n',char(res11File));
  DATA = read_file_RES11(res11File, 0);
 %elseif only use dfs0
 elseif (dfs0Exists)
  fprintf('--- Reading file M11 results::%s\n',char(dfs0File));
  DATA = read_file_DFS0(dfs0File);
 %else can't use res11 option
 else
  % prints message of which files were missing
  if(~dfs0Exists)
  fprintf('WARNING: missing M11 file %s for:%s\n',char(fn), char(dfs0File));
  end
  if(~res11Exists)
  fprintf('WARNING: missing M11 file %s for:%s\n',char(fn), char(res11File));
  end
  return
 end
 else
 %if not using res11, use old dfs0 read
 dfs0File = strcat(INI.fileM11WM(1:ext),'dfs0');
 dfs0Exists = exist(dfs0File,'file');
 if(dfs0Exists)
  fprintf('--- Reading file M11 results::%s\n',char(dfs0File));
  DATA = read_file_DFS0(dfs0File);
 else
  fprintf('WARNING: missing M11 file %s for:%s\n',char(fn), char(dfs0File));
  return
 end
end
DATA.V(abs(DATA.V)<1e-8 & abs(DATA.V) > 0 ) = NaN; % remove non-physical values < 1e-8
SZ = size(DATA.V);
%xlswrite(char(INI.fileCompCoord),DATA.NAME','ALL_COMPUTED','B2');
fprintf('--- M11 results have %d Computational Points with %d Timesteps\n',SZ(2),SZ(1));

% create a map of chainages with Station Names as values
mapM11chain = getMapM11Chainages(INI);

CF = INI.CONVERT_M11CHAINAGES;
fprintf('--- CONVERSION FACTOR FOR CHAINAGES::%f\n',CF);

fi = 0;
fn = 0;
ii = 0;
for i=1:SZ(2)
 M11CHAIN = DATA.NAME{i};
 M11CHAIN = strrep(M11CHAIN,' ','');
 STR_TEMP = strsplit(M11CHAIN,';');
 N = str2num(STR_TEMP{2})*CF; %if chainage is per foot -> meters
 NSTR = sprintf('%.0f',N);
 M11CHAIN = [STR_TEMP{1} ';' NSTR ';' STR_TEMP{3}];
 
 try
  XSEL{i} = M11CHAIN;
  if isKey(mapM11chain,char(M11CHAIN))
   NAME = mapM11chain(char(M11CHAIN));
  else
   %fprintf('-%d- WARNING: Computed nodes Not-Mapped to requested M11 Stations \t%s:: \t NOT found::\n',i,char(M11CHAIN));
   % dont print too much output not needed, it s recorded in
   % LOG.xlsx
   fn = fn + 1;
   XNFOUND{fn} = M11CHAIN;
   continue
  end
  
  fi = fi + 1;
  fprintf('-%d\t\t Requested M11 Station \t%s \t mapped to:\t%s\n',fi,char(NAME),char(M11CHAIN));
  STATION = INI.mapCompSelected(char(NAME));
  STATION.M11NAME = STATION.STATION_NAME;
  STATION.M11UNIT = DATA.UNIT(i);
  STATION.M11TYPE = DATA.TYPE(i);
  STATION.M11T = DATA.T;
  STATION.M11V = DATA.V(:,i);
  STATION.TIMEVECTOR = DATA.T;
  STATION.DCOMPUTED = STATION.M11V;
  if strcmp(STATION.M11UNIT,'m')
   STATION.DCOMPUTED = STATION.M11V/0.3048;
   STATION.UNIT = 'ft';
   STATION.DATATYPE = 'Elevation';
  end
  if strcmp(STATION.M11UNIT,'m^3/s')
   STATION.DCOMPUTED = STATION.M11V/(0.3048^3);
   STATION.UNIT = 'feet^3/sec';
  end
  INI.mapCompSelected(char(NAME)) = STATION;
  XFOUND{fi} = M11CHAIN;
  NAME_FOUND(fi) = NAME;
 catch
  fn = fn + 1;
  fprintf('-%d- WARNING:: Exception in reading M11 in %s for requested station %s\n',i,char(NAME),char(M11CHAIN));
  XNFOUND{fn} = M11CHAIN;
 end
end

SELECTED = values(mapM11chain)';
SELECTED = cellfun(@(x) cell2mat(x),SELECTED,'un',0);
SELECTED = sort(SELECTED);

XLSH = [INI.LOG_XLSX_SH '_M11_SH'];

if length(XLSH)> 30
 fprintf('--- WARNING length of sheet name  %s is greater than 30 char, shortening to %s \n',char(XLSH),char(XLSH(1:30)));
 XLSH = XLSH(1:30);
end

[STATIONS_NOT_FOUND] = findM11NotFound(NAME_FOUND,SELECTED,mapM11chain);

%print selected
xlswrite(char(INI.LOG_XLSX),{'SELECTED'},char(XLSH),'B1');
xlswrite(char(INI.LOG_XLSX),SELECTED,char(XLSH),'B2');

% XFOUND = sort(XFOUND');
%print found
xlswrite(char(INI.LOG_XLSX),{'CHAINAGE'},char(XLSH),'D1');
xlswrite(char(INI.LOG_XLSX),XFOUND',char(XLSH),'D2');

% NAME_FOUND = sort(NAME_FOUND');
xlswrite(char(INI.LOG_XLSX),{'STATION'},char(XLSH),'E1');
xlswrite(char(INI.LOG_XLSX),NAME_FOUND',char(XLSH),'E2');

%print not found
XNFOUND = sort(XNFOUND');
xlswrite(char(INI.LOG_XLSX),{'NOTFOUND'},char(XLSH),'G1');
xlswrite(char(INI.LOG_XLSX),STATIONS_NOT_FOUND,char(XLSH),'G2');

xlswrite(char(INI.LOG_XLSX),{'ALL CHAINAGES'},char(XLSH),'I1');
xlswrite(char(INI.LOG_XLSX),XNFOUND,char(XLSH),'I2');

fprintf('--- Summary of M11 results from file %s \n',char(INI.fileM11WM));
fprintf('    - %d Requested M11 stations\n', length(mapM11chain));
fprintf('    - %d Computed nodes mapped to requested M11 Stations \n',length(XFOUND));
fprintf('    - %d Computed nodes Not-Mapped to requested M11 Stations\n',length(mapM11chain)-length(XFOUND));
S = strcat(INI.LOG_XLSX, '\', XLSH);
fprintf('    - Review LOG File %s for summary of Requested, Mapped, Not-Mapped M11 chainages::\n', char(S));
fprintf('    - Review Sheet::%s for exact listing of matched M11 computation nodes and stations\n\n', ['ALL_COMPUTED_' INI.MODEL]);

end

