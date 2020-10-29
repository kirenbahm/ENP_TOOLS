function INI = A12_make_latex_flow_report(INI)
fprintf('\n------------------------------------');
fprintf('\nBeginning A12_make_latex_flow_report    (%s)',datestr(now));
fprintf('\n------------------------------------\n');
format compact

% Find Yearly Average Data File
FlowDataFile = [INI.POST_PROC_DIR 'DS_YEARLY_AVE.txt'];
FlowDataExist = exist(FlowDataFile,'file') == 2;

% Find Flow Report Format
FormatFile = INI.FLOWS_REPORT_DEFS;
FormatExist = exist(FormatFile,'file') == 2;

% File name for output latex file
LatexFileName = [INI.POST_PROC_DIR 'latex\Critical_Flows_Report.tex'];

fprintf('\n');
if(~FlowDataExist)
    fprintf('ERROR: Flow data was not found at %s.\n',char(FlowDataFile));
end
if(~FormatExist)
    fprintf('ERROR: Report format was not found at %s.\n',char(FormatFile));
end
if FlowDataExist && FormatExist
    % Parse Flow Data from YEARLY_AVE_.txt
    fileID = fopen( FlowDataFile );
    fgetl(fileID); % Title
    tline = fgetl(fileID); % Column Headers
    alternatives = strsplit(tline, '\t');
    nA = size(alternatives);
    latexTableSize = '';
    %Based on number of alternatives, creates latex code for table size
    for c=1:nA(2)
        if c == 1
            latexTableSize = [latexTableSize 'l '];
        elseif c == nA(2)
            latexTableSize = [latexTableSize 'c'];
        else
            latexTableSize = [latexTableSize 'c '];
        end
    end
    alternatives = alternatives(2:nA(2));
    TableHeader = '';
    % uses alternatives to create latex table head
    for a = 1:size(alternatives, 2)
        TableHeader = [TableHeader '& ' alternatives{a} ' '];
    end
    i = 1;
    tline = fgetl(fileID); % First Data row
    while ischar(tline)
        %parse Flow Data line
        lineData = strtrim(strsplit(tline, '\t'));
        FlowDataID{i} = lineData{1}; %save station name
        FlowDataValues{i} = lineData(2:end); % save flow array
        i = i + 1; % increment index
        tline = fgetl(fileID); % read next line
    end
    fclose(fileID);
    % Open format file
    formatID = fopen( FormatFile );
    % create latex file
    % Write latex as format is read
    % Write Latex preamble
    tline = fgetl(formatID); % First Data row
    Title = '';
    % Find Latex report title
    while ischar(tline)
        if startsWith(tline, 'ReportTitle:') % If format line has ReportTitle Keyword
            repTitle = strsplit(tline, ':'); % split by :
            Title = strtrim(repTitle{2});% save ReportTitle
            break;
        else
            tline = fgetl(formatID); % First Data row
        end
    end
    %If reportTile not found, throw error and close
    if strcmp(Title, '')
        fprintf('ReportTitle not found in %s. \n...Aborting flow report generation...',FormatFile);
        fclose(formatID);
        return;
    end
    % Create latex file
    fidTEX = fopen(LatexFileName,'w');
    % write latex preamble
    line = '\documentclass[12pt]{article}';
    fprintf(fidTEX, '%s\n', line);
    line = '\usepackage[';
    fprintf(fidTEX, '%s\n', line);
    line = 'singlelinecheck=false';
    fprintf(fidTEX, '%s\n', line);
    line = ']{caption}';
    fprintf(fidTEX, '%s\n', line);
    line = '\begin{document}';
    fprintf(fidTEX, '%s\n', line);
    line = '\begin{flushleft}';
    fprintf(fidTEX, '%s\n', line);
    line = ['{\Large ' Title '}'];
    fprintf(fidTEX, '%s\n\n', line);
    Now = datetime('now');
    line = ['Date: ' num2str(Now.Year) '/' num2str(Now.Month) '/' num2str(Now.Day)];
    fprintf(fidTEX, '%s\n\n', line);
    line = ['P.O.R: ' num2str(INI.ANALYZE_DATE_I(1)) '--' num2str(INI.ANALYZE_DATE_F(1))];
    fprintf(fidTEX, '%s\n\n', line);
    line = 'All values (annual average are in Kac-ft)';
    fprintf(fidTEX, '%s\n', line);
    line = '\vspace{5mm}';
    fprintf(fidTEX, '%s\n', line);
    start = true;
    % Loop through format file and write latex tables
    tline = fgetl(formatID); % First Data row
    while ischar(tline)
        if strcmp(tline(1), '#') % if line is comment line, skip
            tline = fgetl(formatID);
            continue
        else
            %parse line
            if startsWith(tline, 'TableTitle:') % if line has TableTile keyword, is table start
                if start % Check if first table. If it is, flip flag
                    start = false;
                else % if it is not the first table, close previous table block before creating new table.
                    line = '[1ex]';
                    fprintf(fidTEX, '%s\n', line);
                    line = '\hline';
                    fprintf(fidTEX, '%s\n', line);
                    line = '\end{tabular}';
                    fprintf(fidTEX, '%s\n', line);
                    line = ['\label{table:' TableTitle '}'];
                    fprintf(fidTEX, '%s\n', line);
                    line = '\end{table}';
                    fprintf(fidTEX, '%s\n\n', line);
                end
                % Create new latex table
                tabTitle = strsplit(tline, ':');
                TableTitle = strtrim(tabTitle{2});
                line = '\begin{table}[ht]';
                fprintf(fidTEX, '%s\n', line);
                line = '\footnotesize';
                fprintf(fidTEX, '%s\n', line);
                line = ['\caption{' TableTitle '}'];
                fprintf(fidTEX, '%s\n', line);
                line = ['\begin{tabular}{' latexTableSize '}'];
                fprintf(fidTEX, '%s\n', line);
                line = '\hline';
                fprintf(fidTEX, '%s\n', line);
                line = [TableHeader '\\[0.5ex]'];
                fprintf(fidTEX, '%s\n', line);
                line = '\hline';
                fprintf(fidTEX, '%s', line);
            else % If not comment, ReportTitle, or TableTitle, is station name
                StationName = strtrim(tline); % Trim line for station name
                FlowValues = -1;
                found = false;
                for f = 1:size(FlowDataID, 2) % loop through list of Flow Data Station Names
                    if strcmp(StationName, FlowDataID{f}) % If Station name Flow data is found 
                        FlowValues = FlowDataValues{f}; % Save Station Flow Data
                        found = true; % flag that station data was found
                        break;
                    end
                end
                line = strrep(StationName, '_', '\_'); %If station name has '_' add escape character for latex
                for nV = 1:(nA(2) - 1) % loop through flow values for alternatives
                    if ~found % if station data not found, add blank table values
                        line = [line ' & '];
                    else
                        nVal = str2double(FlowValues{nV});
                        if isnan(nVal) % if alternative values is NaN add blank table value
                            line = [line ' & '];
                        else % if alternative has numeric data, add to table values
                            line = [line ' & ' FlowValues{nV}];
                        end
                    end
                end
                fprintf(fidTEX, '\n%s\\\\', line); % write station alternative values to table
            end
            tline = fgetl(formatID); % get next line in format file
        end
    end
    % After all of format file is read close last latex table
    line = '[1ex]';
    fprintf(fidTEX, '%s\n', line);
    line = '\hline';
    fprintf(fidTEX, '%s\n', line);
    line = '\end{tabular}';
    fprintf(fidTEX, '%s\n', line);
    line = ['\label{table:' TableTitle '}'];
    fprintf(fidTEX, '%s\n', line);
    line = '\end{table}';
    fprintf(fidTEX, '%s\n\n', line);
    % end latex flush and document
    line = '\end{flushleft}';
    fprintf(fidTEX, '%s\n', line);
    line = '\input{tail.sty}';
    fprintf(fidTEX, '%s\n', line);
    fclose(formatID);
end

fprintf('\n------------------------------------');
fprintf('\nFinishing A12_make_latex_flow_report    (%s)',datestr(now));
fprintf('\n------------------------------------\n');
format compact
end
