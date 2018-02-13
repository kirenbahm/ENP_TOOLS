function boxplots_N(DATA,LABELS,SIM,COLORS_V,ALPHA)
% Fnction plotting n time series per month or year
% requires data to be formatted in specific way

% Size of M - simulations and L - years or months
M=size(DATA,2);
L=size(DATA,1);

% Calculate the positions of the boxes
POS=1:0.25:M*L*0.25+1+0.25*L;
POS(1:M+1:end)=[];

% DATA AND GROUP 
X=[];
GROUP=[];

for ii=1:L % years or months
    for jj=1:M % number of simulations
        TMP=DATA{ii,jj};
        X=vertcat(X,TMP(:));
        GROUP=vertcat(GROUP,ones(size(TMP(:)))*jj+(ii-1)*M);
    end
end

% PLOT
hh = boxplot(X,GROUP, 'positions', POS,'Notch','on','Whisker',2);

% SET X Labels
TMP=reshape(POS,M,[]);
labelpos = sum(TMP,1)./M;

set(gca,'xtick',labelpos);
set(gca,'xticklabel',LABELS);

% This setting considers random colors uncommenting provides colors from
% setup_ini
cmap = hsv(M)'; %assume random collors
cmap=vertcat(cmap,ones(1,M)*0.5);
COLORS_V = cmap;
%%%%%%%%%%%%%% 

% replicate colors for each simulation and group
C=repmat(COLORS_V, 1, L);

% Apply colors
h = findobj(gca,'Tag','Box');
for jj=1:length(h)
   patch(get(h(jj),'XData'),get(h(jj),'YData'),C(1:3,jj)','FaceAlpha',ALPHA);
end

legend(fliplr(SIM));
% legend((SIM));
%legend boxoff; uncomment if leged should ot have a box

end
