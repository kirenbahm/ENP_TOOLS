function [H,X,Y,L] = BC2D_get_H_TS(INI,nTS)

i = 0;

allKeys = INI.MAP_H_DATA.keys;
numKeys = length(allKeys);

X(1:numKeys) = NaN;
Y(1:numKeys) = NaN;
H(1:numKeys) = NaN;
L{1,numKeys} = [];

for currentKey = allKeys
    i = i + 1;
    A = INI.MAP_H_DATA(char(currentKey));
    %X(i) = A.X_UTM;
    %Y(i) = A.Y_UTM;
    X(i) = A.utmXmeters;
    Y(i) = A.utmYmeters;
    if INI.USE_FOURIER_BC2D
        H(i) = A.dHf(nTS);
    else
        H(i) = A.dHd(nTS);
    end
    L{1,i} = currentKey;
end

end