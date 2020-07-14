function [H,X,Y,L] = BC2D_get_H_TS(INI,nTS)

i = 0;

K = INI.MAP_H_DATA.keys;
n = length(K);

X(1:n) = NaN;
Y(1:n) = NaN;
H(1:n) = NaN;
L{1,n} = [];

for k = K
    i = i + 1;
    A = INI.MAP_H_DATA(char(k));
    X(i) = A.X_UTM;
    Y(i) = A.Y_UTM;
    if INI.USE_FOURIER_BC2D
        H(i) = A.dHf(nTS);
    else
        H(i) = A.dHd(nTS);
    end
    L{1,i} = k;
end

end