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
    
    % if using Fourier technique, 
    if INI.USE_FOURIER_BC2D
        H(i) = A.dHf(nTS); % dHf is Fourier temporal interpolation
    else
        H(i) = A.dHd(nTS); % dHd is Julian temporal interpolation
    end
    L{1,i} = currentKey;
end

end