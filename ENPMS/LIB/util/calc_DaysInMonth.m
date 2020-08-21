function [days] = calc_DaysInMonth(year, month)
%Function uses the provided 4-digit year and calcualtes the total number of
%days in that calendar year.
if month == 2
    if calc_LeapYear(year)
        days = 29;
    else
        days = 28;
    end
elseif month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12
    days = 31;
else
    days = 30;
end
end

