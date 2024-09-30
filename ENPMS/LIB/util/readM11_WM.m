function INI = readM11_WM(INI,res11Exists,dfs0Exists,res1dExists)

%% read 1-D model results file (choose file based on preferential order: res1d, res11, dfs0)
% save data into 'DATA' variable
if(INI.USE_RES1D && res1dExists)
    DATA = read_file_RES1D(INI.fileM11Res1d);

elseif(INI.USE_RES11 && res11Exists)
    DATA = read_file_RES11(INI.fileM11Res11, 0);

elseif(INI.USE_DFS0 && dfs0Exists)
    DATA = read_file_DFS0(INI.fileM11Dfs0);

else
    % prints message of which files were missing
    if(~res1dExists)
        fprintf('\nWARNING: missing M11 file %s for:%s\n',char(fn), char(INI.fileM11Res1d));
    end
    if(~res11Exists)
        fprintf('\nWARNING: missing M11 file %s for:%s\n',char(fn), char(INI.fileM11Res11));
    end
    if(~dfs0Exists)
        fprintf('\nWARNING: missing M11 file %s for:%s\n',char(fn), char(INI.fileM11Dfs0));
    end
    return
end

%% process 'DATA'

% Is this line necessary? Specifically what data is it trying to filter out?
% This might need to be removed. -keb
DATA.V(abs(DATA.V)<1e-8 & abs(DATA.V) > 0 ) = NaN; % remove non-physical values < 1e-8




SZ = size(DATA.V);
%xlswrite(char(INI.fileCompCoord),DATA.NAME','ALL_COMPUTED','B2');
%fprintf('--- M11 results have %d Computational Points with %d Timesteps\n',SZ(2),SZ(1));

%% create a map of chainages with Station Names as values
% extract desired data into INI variable using station names from Excel
% file
mapM11chain = getMapM11Chainages(INI);

%fprintf('--- CONVERSION FACTOR FOR CHAINAGES::%f\n',INI.CONVERT_M11CHAINAGES);

fi = 0;
fn = 0;

for i=1:SZ(2)
    %% process MIKE 'canal;chainage;datatype' strings into separate variables
    M11CHAIN = DATA.NAME{i};            % copy name (expected format: 'stationName;chainage;riverName'
    M11CHAIN = strrep(M11CHAIN,' ',''); % remove spaces
    STR_TEMP = strsplit(M11CHAIN,';');  % break apart string into components
    N = str2num(STR_TEMP{2})*INI.CONVERT_M11CHAINAGES; % convert unit of chainage if requested
    NSTR = sprintf('%.0f',N);           % save the converted chainage
    M11CHAIN = [STR_TEMP{1} ';' NSTR ';' STR_TEMP{3}]; % re-assemble and write over original variable

    %% search 'DATA' for matches to desired stations, and save output data to 'INI.mapCompSelected' variable
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
        %fprintf('-%d\t\t Requested M11 Station \t%s \t mapped to:\t%s\n',fi,char(NAME),char(M11CHAIN));
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

%% write report of stations found and not found to Excel spreadsheet log
SELECTED = values(mapM11chain)';
SELECTED = cellfun(@(x) cell2mat(x),SELECTED,'un',0);
SELECTED = sort(SELECTED);

XLSH = [INI.LOG_XLSX_SH '_M11_SH'];

if length(XLSH)> 30
   fprintf('\n--- WARNING length of sheet name  %s is greater than 30 char, shortening to %s \n',char(XLSH),char(XLSH(1:30)));
   XLSH = XLSH(1:30);
end

[STATIONS_NOT_FOUND] = findM11NotFound(NAME_FOUND,SELECTED,mapM11chain);

%print selected
xlswrite(char(INI.LOG_XLSX),{'ALL REQUESTED STATIONS'},char(XLSH),'B1');
xlswrite(char(INI.LOG_XLSX),SELECTED,char(XLSH),'B2');

% XFOUND = sort(XFOUND');
%print found
xlswrite(char(INI.LOG_XLSX),{'CHAINAGES FOR FOUND STATIONS'},char(XLSH),'D1');
xlswrite(char(INI.LOG_XLSX),XFOUND',char(XLSH),'D2');

% NAME_FOUND = sort(NAME_FOUND');
xlswrite(char(INI.LOG_XLSX),{'STATIONS FOUND'},char(XLSH),'E1');
xlswrite(char(INI.LOG_XLSX),NAME_FOUND',char(XLSH),'E2');

%print not found
XNFOUND = sort(XNFOUND');
xlswrite(char(INI.LOG_XLSX),{'STATIONS NOT FOUND'},char(XLSH),'G1');
xlswrite(char(INI.LOG_XLSX),STATIONS_NOT_FOUND,char(XLSH),'G2');

xlswrite(char(INI.LOG_XLSX),{'LIST OF ALL CHAINAGES'},char(XLSH),'I1');
xlswrite(char(INI.LOG_XLSX),XNFOUND,char(XLSH),'I2');

fprintf('\n    - Summary of M11 results\n');
fprintf('      - %d Requested M11 stations\n', length(mapM11chain));
fprintf('      - %d Computed nodes mapped to requested M11 Stations \n',length(XFOUND));
fprintf('      - %d Computed nodes Not-Mapped to requested M11 Stations\n',length(mapM11chain)-length(XFOUND));
S = strcat(INI.LOG_XLSX, '\', XLSH);
fprintf('      - Review LOG File %s for summary of Requested, Mapped, Not-Mapped M11 chainages::\n', char(S));
fprintf('      - Review Sheet::%s for exact listing of matched M11 computation nodes and stations\n\n', ['ALL_COMPUTED_' INI.MODEL]);

end

