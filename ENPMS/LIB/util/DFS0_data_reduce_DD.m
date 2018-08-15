function DFS0 = DFS0_data_reduce_DD(DFS0)

V = DFS0.V;
IND = isnan(V);
V(IND) = [];
T = DFS0.T;
T(IND) = [];

DFS0.DRED = reduce_NONEQDIST_DD(T,V,'d');

end

