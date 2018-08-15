function PE = get_PE_plot_fig_PE_1(D)
%D = [3,4,2,3,1,4,6,7];
idx = 1:length(D);
D = sort(D,'descend');
P = sort(idx,'ascend')';
P = P/(length(P)+1);
PE=[P D];
end
