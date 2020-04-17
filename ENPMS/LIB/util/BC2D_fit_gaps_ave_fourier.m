function ST = BC2D_fit_gaps_ave_fourier(INI,ST,FIG_DIR)   
%%%%%%function ST = BC2D_fit_gaps_ave_fourier(ST,INI,INI.OLorSZ)   

oT = ST.T; % observed time vector
xData = ST.T;
oH = ST.V;
yData = ST.V;

% Identify all valid measurement values ( i.e. non-NaN values).
idxValid = ~isnan(yData);

% Set up fittype and options.
ft = fittype( 'fourier8' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.00570107549362045];

% Fit model to data.
[fitresult, ~] = fit( xData(idxValid), yData(idxValid), ft, opts );

% calculate the entire vector
ST.dHf = fitresult(ST.dT);
% eliminate H values before initial and after the final date
%VEC_D = oT(oT>=ST.t_i & oT<=ST.t_e);
oH = oH(oT>=ST.t_i & oT<=ST.t_e);

% find observed values are in the same vectors : extrapolated and obs
v = ismember(ST.dT,oT);

%apply the observed data where avaialbe
ST.dHf((v>0)) = oH;

if ~INI.CREATE_FIGURES, return, end 

% Create a figure for the plots.
figure(1);
clf;
TITLE = strrep(ST.STATION,'_',' ');

% Plot fit with data.
subplot(2, 1, 1);
hold on
title(char(TITLE));
% plot( fitresult, xData, yData, 'predobs', 0.99 );
% plot( fitresult, xData, yData, 'predobs', 0.95 );
%plot( fitresult, xData, yData, 'predobs', 0.90 );

plot(fitresult, ST.dT, ST.dHf, 'predobs', 0.90);
b = gca; legend(b,'off'); %suppress legend
datetick('x','yyyy','keeplimits');

% Label axes
xlabel Year;
ylabel 'H, ft NGVD29';
grid on

% Plot residuals.
subplot(2, 1, 2);
plot(fitresult, xData, yData, 'residuals');
b = gca; legend(b,'off'); %suppress legend
datetick('x','yyyy','keeplimits');
% Label axes
xlabel Year;
ylabel 'Residuals, ft';
grid on

%%%%%%% Select Hourly or Daily time increment
%%%%%%if strcmpi(INI.OLorSZ,'OL') 
%%%%%%    print(char([INI.BC2D_DIR 'DFS0HR/' char(ST.STATION)]),'-dpng');
%%%%%%elseif strcmpi(INI.OLorSZ,'SZ')
%%%%%%    print(char([INI.BC2D_DIR 'DFS0DD/' char(ST.STATION)]),'-dpng');
%%%%%%end

print(char([FIG_DIR char(ST.STATION)]),'-dpng');

    
end