function ARRAY_GROUPS = sum_ARRAY_GROUPS(ARRAY,MyRequestedStnNames);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variable ARRAY contains the computed values, ARRRAY_GROUPS is the
% sumation over the unique names
n_array = size(ARRAY);
GROUPS = unique(MyRequestedStnNames);
n_groups = size(GROUPS);
ARRAY_GROUPS(1:n_array(1),n_groups(1)) = 0;
i = 0;
for N = GROUPS'
    i = i + 1;
    IND = ismember(MyRequestedStnNames,N)';
    ARRAY_GROUPS(:,i)  = sum(ARRAY(:,IND),2);
end

end

