function [H,X,Y,L] = BC2D_get_H_TS(INI,nTS)

i = 0;

% keys are station names
allKeys = INI.MAP_H_DATA.keys;
numKeys = length(allKeys);

X(1:numKeys) = NaN;
Y(1:numKeys) = NaN;
H(1:numKeys) = NaN;
L{1,numKeys} = [];

% iterate over each station
for currentKey = allKeys
    i = i + 1;
    
    % A is station data
    A = INI.MAP_H_DATA(char(currentKey));
    %X(i) = A.X_UTM;
    %Y(i) = A.Y_UTM;
    X(i) = A.utmXmeters;
    Y(i) = A.utmYmeters;
    
    if INI.USE_FOURIER
        H(i) = A.dHf(nTS); % dHf is Fourier temporal interpolation
    elseif INI.USE_JULIAN
        H(i) = A.dHd(nTS); % dHd is Julian temporal interpolation
    elseif INI.USE_UNFILLED 
        H(i) = A.dHr(nTS); % dHr is 'raw' - no temporal interpolation
    else
        fprintf("\n\nERROR - Cannot determine which data to use for BC2D interpolation\n\n");
    end

    L{1,i} = currentKey;
end

end