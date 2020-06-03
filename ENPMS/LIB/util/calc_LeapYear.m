function leapyearTF = calc_LeapYear(year)
%Function uses the provided 4-digit year and calcualtes if a leap year

div4 = mod(year, 4) == 0; %is year divisible by 4?
if ~div4
    leapyearTF = false; %not divible 4 for then not a leap year
else
    div100 = mod(year, 100) == 0; % is year divisible by 100?
    if ~div100
        leapyearTF = true; %divisble by 4, but not 100
    else
        div400 = mod(year, 400) == 0; % is year divisible by 100?
        if div400
            leapyearTF = true; % is divible by 100 and 400
        else
            leapyearTF = false; % is divible by 100 but not 400
        end
    end
end

end

