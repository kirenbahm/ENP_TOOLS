function STR = stat_TS(ii,STR, TS, D)

STR(ii).MIN = min(D);
STR(ii).MAX = max(D);
STR(ii).MEDIAN = median(D);
STR(ii).MEAN = mean(D);
STR(ii).MODE = mode(D);
STR(ii).STD = std(D);
STR(ii).VAR = var(D);


end