function [days] = calc_DaysInYear(year)
%Function uses the provided 4-digit year and calcualtes the total number of
%days in that calendar year.
try
    FirstDay = ['01/01/' strtrim(char(year))];
    LastDay = ['31/12/' strtrim(char(year))];

    FirstDay_num = datenum(FirstDay, 'dd/mm/yyyy');
    LastDay_num = datenum(LastDay, 'dd/mm/yyyy');
catch
    if isreal(year)
        year = num2str(year);
        FirstDay = ['01/01/' strtrim(char(year))];
        LastDay = ['31/12/' strtrim(char(year))];

        FirstDay_num = datenum(FirstDay, 'dd/mm/yyyy');
        LastDay_num = datenum(LastDay, 'dd/mm/yyyy');
    else
        fprintf('\n ERROR processing YEAR for: %s', year);
        pause
    end
end

days = LastDay_num - FirstDay_num + 1;
end

