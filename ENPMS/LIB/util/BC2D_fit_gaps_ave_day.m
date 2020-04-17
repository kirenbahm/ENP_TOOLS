function ST = BC2D_fit_gaps_ave_day(ST)
%%function ST = BC2D_fit_gaps_ave_day(ST,~)
    % temporary vectors for data and time o is for observed
    oH = ST.V;
    oT = ST.T; % observed time vector
    
    % convert the obs time vector to a datetime vector to determine dayofyear
    VEC_D = datevec(oT);
    TT = datetime(VEC_D);
    %AAA = unique(TT);
    DI = day(TT,'dayofyear');
    uDI = unique(DI);
    
    % convert the extended timevector to a datetime vector to determine
    % dayofyear
    DI_T = day(datetime(datevec(ST.dT)),'dayofyear');
    
    % iterate over each day of the year and determine the mean for that
    % particular day
    for ii = uDI'
        iii = find(DI==ii);
        iv = find(DI_T==ii);
        ST.dHd(iv) = mean(oH(iii))';
    end
    
    % eliminate H values before initial and after the final date
    %VEC_D = oT(oT>=ST.t_i & oT<=ST.t_e); 
    oH = oH(oT>=ST.t_i & oT<=ST.t_e);
    
    % find observed values are in the same vectors : extrapolated and obs
    v = ismember(ST.dT,oT);
    
    %apply the observed data where avaialbe
    ST.dHd((v>0)) = oH;
        
    
end
