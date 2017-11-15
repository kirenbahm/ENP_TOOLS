
function INI = setup_ini(INI,U)

% setup_ini(INI) SETS UP additionall options which rarely change but if
% user decides to modify some of the options here, there sill be impact on
% the analysis in subsequent files

% get_INI(INI) calculates the remaining input variables
% the user should not modify anything in get_INI(INI)

INI.SAVEFIGS = 0;

INI.DATUM = 'NGVD29';
INI.SELECTED_STATION_LIST = [INI.CURRENT_PATH U.SELECTED_STATION_LIST];
%INI.FILE_OBSERVED = [INI.MATLAB_SCRIPTS 'DATA_OBSERVATIONS/' U.FILE_OBSERVED]; %  all selected stations
%INI.STATION_DATA   = [INI.MATLAB_SCRIPTS 'DATA_OBSERVATIONS/' U.STATION_DATA];
INI.FILE_OBSERVED = [U.FILE_OBSERVED]; %  all selected stations
INI.STATION_DATA   = [U.STATION_DATA];
INI.MAPF = [INI.CURRENT_PATH U.MAPF];
% Assign the same of Seeapge Map U.MAPF to the Excel outup file:
[D,N,E] = fileparts(char(INI.MAPF));
INI.fileXL = [D '/' INI.ANALYSIS_TAG '/' INI.ANALYSIS_TAG '_' N '.xlsx'];
% path for a log file which will record all exceptions
INI.LOGFILE = [INI.ANALYSIS_PATH  INI.ANALYSIS_TAG '/' INI.ANALYSIS_TAG '_LOGFILE.TXT'];

% NOT SURE HOW THESE ARE IMPLEMENTED YET:
INI.INCLUDE_OBSERVED      = 'YES'; % Include observed in the output figs and tables. Check if this switch works
INI.COMPUTE_SENSITIVITES  = 'YES'; % Compute statistics and generate tables in Latex? Check if this switch works
INI.MAKE_STATISTICS_TABLE = 'YES';  % Make the statistics tables in LaTeX
INI.MAKE_EXCEEDANCE_PLOTS = 'YES'; % Generate exceedance curve plots? Also generates the exceedance table.

% GRAPHICS_PROPERTIES
INI.GRAPHICS_CO = {'r', 'k', 'b', '[0 0.5 0]', 'm', 'b', 'k', 'g', 'c', 'm', 'k', 'g', 'b', 'm', 'b'};
INI.GRAPHICS_LS = {'none','-','-','-','-','-.','-.','-.','-.','-.',':','-','-','-','-','-.','-.'};
INI.GRAPHICS_M = {'s','none','none','none','none','none','none','none','none','none','none','none','none','none','none'};
INI.GRAPHICS_MSZ = [ 2 3 3 3 3 3 3 3 3 3 3 3 3 3 3];
INI.GRAPHICS_LW = [ 1 1 1 1 1 1 1 1 1 1 3 3 3 3 3];

% STATIONS TO BE ANALYZED/EXTRACTED, the default is to check current dir for selected_station_list.txt

%---------------------------------------------------------------------
% CHOOSE MODEL OUTPUT FILES TO EXTRACT DATA FROM   1=yes, 0=no
%---------------------------------------------------------------------

INI.LOAD_MOLUZ    = 1;  % Detailed Timeseries stored on UZ/OC timesteps (loads all items)
INI.LOAD_M11      = 1;  % Detailed Timeseries (loads all items)
INI.LOAD_MSHE     = 1;  % Detailed Timeseries (loads all items)
INI.LOAD_OL       = 0;  % Overland dfs2 file (loads cells defined in xls spreadsheet)
INI.LOAD_3DSZQ    = 0;  % Saturated zone dfs3 flow file (loads cells defined in xls spreadsheet)

INI.OVERWRITE_MON_PTS = 0; % this regenerates the monitoring points from
%                             the corresponding EXCEL file. If this is 0
%                            monitoring points come from a matlab data file
%                            MONPOINTS.MATLAB
INI.OVERWRITE_GRID_XL = 0; % this regenerates the gridded points from
%                             the corresponding EXCEL file. If this is 0
%                            monitoring points come from a matlab data file
%                            the same as the excel file but ext .MATLAB

%---------------------------------------------------------------------
% CHOOSE GROUP DEFINITIONS FOR EXTRACTING GRIDDED DATASETS
% (This gets used if INI.LOAD_OL=1 or INI.LOAD_3DSZQ=1)
%---------------------------------------------------------------------

%!!! The settings below are in setup_ini() to keep the convention that
% user defined options are in setup_ini(), get_INI() should be used to
% populate, or compute, some variables which may be used in any function by
% passing the structure INI as a function argument (this is to avoid
% global values)

% Overland Flow File
i=1;
INI.CELL_DEF_FILE_DIR_OL   = [''];
INI.CELL_DEF_FILE_NAME_OL  = 'Transects_v12';
INI.CELL_DEF_FILE_SHEETNAME_OL{i} = 'OL Flow'; i=i+1;
INI.CELL_DEF_FILE_SHEETNAME_OL{i} = 'OL2RIV'; i=i+1;

% 3D Saturated Zone Flow file
i=1;
INI.CELL_DEF_FILE_DIR_3DSZQ   = [''];
INI.CELL_DEF_FILE_NAME_3DSZQ  = 'Transects_v12';
INI.CELL_DEF_FILE_SHEETNAME_3DSZQ{i} = 'SZ Flow'; i=i+1;
INI.CELL_DEF_FILE_SHEETNAME_3DSZQ{i} = 'SZunderRIV'; i=i+1;
INI.CELL_DEF_FILE_SHEETNAME_3DSZQ{i} = 'SZ2RIV'; i=i+1;


%---------------------------------------------------------------------
%  INITIALILIZE STRUCTURE INI
%---------------------------------------------------------------------

INI = get_INI(INI);

% SELECTED_STATION_LIST = [INI.ANALYSIS_DIR '/selected_station_list.txt'];

%infile = INI.SELECTED_STATION_LIST;
% if (exist(char(infile),'file'))
% %if (exist(char(infile))~=2)
%     infile = SELECTED_STATION_LIST;
% else
%     infile = [INI.DATADIR 'selected_station_list-MDR.txt']%listALL
%     fprintf(' --> missing SELECTED_STATION_LIST\n')
%     fprintf(' --> will use the general list in %s\n', infile)
% end
% INI.SELECTED_STATIONS = get_station_list(INI.SELECTED_STATION_LIST);
INI.SELECTED_STATIONS = get_station_list_alt(INI.SELECTED_STATION_LIST);

end