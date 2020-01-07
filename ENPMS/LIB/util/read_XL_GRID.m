function XLARRAY = read_XL_GRID(xlinfile,FILE_SHEETNAME)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load group definition data from Excel file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('%s Reading file: %s\n',datestr(now), char(xlinfile));

% if ~exist(xlinfile,'file')
%     fprintf('MISSING: %s, exiting...', xlinfile);
%     return
% end

% stn_counter_begin = 0;
% stn_counter_end = 0;
num_sheets = length(FILE_SHEETNAME);

XLARRAY=[];
try
    for sheetnum = 1:num_sheets  % iterate through sheet names given in A0 setup script
        xlsheet = FILE_SHEETNAME{sheetnum};
        [~,~,xldata] = xlsread(xlinfile,xlsheet);
        [numrows,trash] = size(xldata);
        
        % append array of numrows and 11 columns
        XLARRAY = [XLARRAY;xldata(2:numrows,1:11)];
        
        %     stn_counter_begin = stn_counter_end + 1;
        %     stn_counter_end = stn_counter_end + (numrows - 1); % subtract 1 for header row
        %     MyRequestedStnNames(stn_counter_begin:stn_counter_end) = xldata(2:numrows,1);
        %     rows0(stn_counter_begin:stn_counter_end) = xldata(2:numrows,2);
        %     cols0(stn_counter_begin:stn_counter_end) = xldata(2:numrows,3);
        %     lyrs1(stn_counter_begin:stn_counter_end) = xldata(2:numrows,4);
        %     multip(stn_counter_begin:stn_counter_end) = xldata(2:numrows,5);
        %     itms1(stn_counter_begin:stn_counter_end) = xldata(2:numrows,6);
    end
catch
    fprintf('\n--- Exception in read_XL_GRIDDED(): %s\n', char(xlinfile))
    
end
end
