function [MAP_ALL] = readXLSmonpts(MAKETEXTFILE,INI,xlfile2,outfiles)
% read monpts MikeSHE and M11 xls file,
%  for import to the mikeshe storing of results setup option
%  for use in creating dfso from txt files
%  return the MAPs in a structure

%
% Added outfiles, use blank or 'none' if MAKETEXTFILE is 0
% v8: 2016-03-15 keb modified code to work with GIT's scripts
% v7: -2016-03-14 keb added read for M11 angle. prob some other stuff but
% not sure
%
% v6: - Added syntax to skip first line of xls files, which is now a header row
%     - Added syntax to not crash when an xls sheet has no station data rows
%     - Added check for dfs0 obs file existence:
%        if it doesn't exist, print warning, and change filename to 'none'
%     NOTE: For data code descriptions, see:
%           E:\APPS\Manuals\MIKE2011\MIKE_SHE\MIKE_SHE_Printed_V1.pdf page 83
%     keb 2015-09-09

%TODO:
% Add logic to ignore empty cells, currently it is very sensitive to cells
% where data was entered then deleted vs cells where there was never any data entered.
%%%%%%%%%%%

% Create the text file for 'detailed timeseries input'
% always returns the structure with the MAP container
if (~exist('MAKETEXTFILE','var')), MAKETEXTFILE = 0; end
%output file
if (~exist('printname','var')),printMSHEname = [INI.MATDIR 'DATASTRUCTURES/detTSmsheALL.txt']; end
xlsMSHE = 'monpts';
xlsMSHEadd = 'monptsadd';
dfs0MSHEdir=[INI.PATHDIR 'DHIMODEL/INPUTFILES/MSHE/TIMESERIES/'];
dfs0MSHEdpthdir= [INI.PATHDIR 'DHIMODEL/INPUTFILES/MSHE/TSDEPTH/'];
if (~exist('printname','var')),printM11name = [INI.MATDIR 'DATASTRUCTURES/detTSm11ALL.txt']; end
xlsM11 = 'M11';
xlsM11add = 'M11add';
dfs0M11dir=[INI.PATHDIR 'INPUTFILES/M11/TIMESERIES/'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% Do the MSHE %%%%%%%%%%%%%%%%%%%%%%%%%
% read the main MSHE sheet of stations
[~,~,xldata] = xlsread(xlfile2,xlsMSHE);
[numrows,~] = size(xldata);
stat= xldata(2:numrows,1);
utmx = xldata(2:numrows,2);
utmy = xldata(2:numrows,3);
filename = xldata(2:numrows,4);
code = xldata(2:numrows,5);
depth = xldata(2:numrows,6);
row = xldata(2:numrows,7);
col = xldata(2:numrows,8);
dfegse =  xldata(2:numrows,9);
gridgse = xldata(2:numrows,10);

% create a container of the selected stations
for i = 1:numrows-1
    N = stat(i);
    DATA0(i).utmx = utmx(i);
    DATA0(i).utmy = utmy(i);
    DATA0(i).filename = filename(i);
    DATA0(i).code = code(i);
    DATA0(i).depth = depth(i);
    DATA0(i).row = row(i);
    DATA0(i).col = col(i);
    DATA0(i).dfegse = dfegse(i);
    DATA0(i).gridgse = gridgse(i);
    MAP_KEY(i) = N;
    MAP_VALUE(i) = {DATA0(i)};
    % Output for GIS
    %     fprintf (fidg,'%s,%7.1f,%8.1f\n', char(stat(i)),cell2mat(utmx(i)), cell2mat(utmy(i)));
end

% read the additional monpts
[~,~,xldata] = xlsread(xlfile2,xlsMSHEadd);
[numrowsadd,~] = size(xldata);
if (numrowsadd > 1)
    stat= xldata(2:numrowsadd,1);
    utmx = xldata(2:numrowsadd,2);
    utmy = xldata(2:numrowsadd,3);
    filename = xldata(2:numrowsadd,4);
    code = xldata(2:numrowsadd,5);
    depth = xldata(2:numrowsadd,6);
    row = xldata(2:numrowsadd,7);
    col = xldata(2:numrowsadd,8);
    dfegse =  xldata(2:numrowsadd,9);
    gridgse = xldata(2:numrowsadd,10);
    for i = 1:numrowsadd-1
        MAP_KEY(numrows-1+i) = stat(i);
        DATA0(numrows-1+i).utmx = utmx(i);
        DATA0(numrows-1+i).utmy = utmy(i);
        DATA0(numrows-1+i).filename = filename(i);
        DATA0(numrows-1+i).code = code(i);
        DATA0(numrows-1+i).depth = depth(i);
        DATA0(numrows-1+i).row = row(i);
        DATA0(numrows-1+i).col = col(i);
        DATA0(numrows-1+i).dfegse = dfegse(i);
        DATA0(numrows-1+i).gridgse = gridgse(i);
        MAP_VALUE(numrows-1+i) = {DATA0(numrows-1+i)};
        % Output for GIS
        %     fprintf (fidg,'%s,%7.1f,%8.1f\n', char(stat(i)),char(stat(i)),cell2mat(utmx(i)), cell2mat(utmy(i)));
    end
end
%Save MSHE monitoring points
MAP_statMSHE = containers.Map(MAP_KEY, MAP_VALUE);

% fclose(fidg);
%%%%%%%%%%%%%%%%%  Do the M11  %%%%%%%%%%%%%%%%%%

[~,~,xldata] = xlsread(xlfile2,xlsM11);
[numrows,~] = size(xldata);
selstat= xldata(2:numrows,1);
%0= water level; 1= discharge
type = xldata(2:numrows,2);
branch = xldata(2:numrows,3);
chain = xldata(2:numrows,4);
filename11 = xldata(2:numrows,5);
utmx = xldata(2:numrows,6);
utmy = xldata(2:numrows,7);
angledir = xldata(2:numrows,8);

% create a container of the selected stations
for i = 1:numrows-1
    MAP_KE(i) = selstat(i);
    DATA1(i).type = type(i);
    DATA1(i).branch = branch(i);
    DATA1(i).filename11 = filename11(i);
    DATA1(i).chain = chain(i);
    DATA1(i).utmx = utmx(i);
    DATA1(i).utmy = utmy(i);
    DATA1(i).angledir = angledir(i);
    DATA1(i).gridgse = 0;
    MAP_VALU(i) = {DATA1(i)};
    %fprintf('%s\n', char(selstat(i)));
end

[~,~,xldata] = xlsread(xlfile2,xlsM11add);
[numrowsadd,~] = size(xldata);
if (numrowsadd > 1)
    selstat= xldata(2:numrowsadd,1);
    %0= water level; 1= discharge
    type = xldata(2:numrowsadd,2);
    branch = xldata(2:numrowsadd,3);
    chain = xldata(2:numrowsadd,4);
    filename1 = xldata(2:numrowsadd,5);
    utmx = xldata(2:numrowsadd,6);
    utmy = xldata(2:numrowsadd,7);
    angledir = xldata(2:numrowsadd,8);
    
    % create a container of the selected stations
    for i = 1:numrowsadd-1
        MAP_KE(numrows-1+i) = selstat(i);
        DATA1(numrows-1+i).type = type(i);
        DATA1(numrows-1+i).branch = branch(i);
        DATA1(numrows-1+i).filename11 = filename1(i);
        DATA1(numrows-1+i).chain = chain(i);
        DATA1(i).utmx = utmx(i);
        DATA1(i).utmy = utmy(i);
        DATA1(i).angledir = angledir(i);
        DATA1(i).gridgse = 0;
        MAP_VALU(numrows-1+i) = {DATA1(numrows-1+i)};
    end
end
MAP_statM11 = containers.Map(MAP_KE, MAP_VALU);

%%%%%%%%%%%%% Do the GIS Locomotion %%%%%%%%%%%%%%%%%%

if MAKETEXTFILE
    %output to printfile
    fidp=fopen(char(printMSHEname),'w');
    K = keys(MAP_statMSHE);
    i=1;
    for k = K
        seldat = MAP_statMSHE(char(k));
        useobs = 1;
        filenm = [dfs0MSHEdir seldat.filename{:}];
        if (strcmp(seldat.filename{:}, 'none'))
            useobs = 0;
            filenm = 'none';
            % check if file exists, if not, print warning message
        elseif (exist([filenm '.dfs0'], 'file') ~= 2)
            fprintf('Warning: file does not exist:\n%s\nIf you use this to import detTS to MIKE, you might get a red checkbox but no specific warning message\n\n', [filenm '.dfs0'])
            useobs = 0;
            filenm = 'none';
        end
        
        if(regexp(char(k),'dpth'))
            filenm = [dfs0MSHEdpthdir  seldat.filename{:}];
        end
        fprintf(fidp, '%s\t%d\t1\t%8.1f\t%8.1f\t%6.1f\t%d\t%s\t1\n', char(k),seldat.code{:},seldat.utmx{:},seldat.utmy{:},seldat.depth{:},useobs,filenm);
        i=i+1;
    end
    fclose(fidp);
    
    %output to printfile
    fidp=fopen(char(printM11name),'w');
    K = keys(MAP_statM11);
    i=1;
    for k = K
        seldat = MAP_statM11(char(k));
        useobs = 1;
        filenm = [dfs0M11dir seldat.filename11{:}];
        if (strcmp(seldat.filename11{:}, 'none'))
            useobs = 0;
            filenm = 'none';
        elseif (exist([filenm '.dfs0'], 'file') ~= 2)
            fprintf('Warning: file does not exist:\n%s\nIf you use this to import detTS to MIKE, you might get a red checkbox but no specific warning message\n\n', [filenm '.dfs0'])
            useobs = 0;
            filenm = 'none';
        end
        fprintf(fidp, '%s\t%d\t%s\t%8.2f\t%d\t%s\t1\n', char(k),seldat.type{:},seldat.branch{:},seldat.chain{:},useobs,filenm);
        i=i+1;
    end
    fclose(fidp);
end

MAP_ALL.MSHE = MAP_statMSHE;
MAP_ALL.M11 = MAP_statM11;


end

