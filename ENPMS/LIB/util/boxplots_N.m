function boxplots_N(DATA,LABELS,SIM,C,ALPHA,COLORS_V)
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
KEEP_POS = [];
IND_DEL = [];
kk = 0; % adjust positions
for ii=1:L % years or months
    for jj=1:M % number of simulations
        TMP=DATA{ii,jj};
        if ~isempty(TMP)
            kk = kk + 1; % increment POS
            X=vertcat(X,TMP(:));
            GROUP=vertcat(GROUP,ones(size(TMP(:)))*jj+(ii-1)*M);
            KEEP_POS = [KEEP_POS jj+(ii-1)*M];
        else
            IND_DEL = [IND_DEL jj+(ii-1)*M];
%             POS(kk)=[];
%             kk = kk - 1; % Erase POS
        end
    end
end
POSMOD = POS(KEEP_POS);

% PLOT
hh = boxplot(X,GROUP, 'positions', POSMOD,'Notch','on','Whisker',2);

% SET X Labels
TMP=reshape(POS,M,[]);
labelpos = sum(TMP,1)./M;

set(gca,'xtick',labelpos);
set(gca,'xticklabel',LABELS);

% Apply colors
h = findobj(gca,'Tag','Box');
for jj=1:length(h)
   p(jj) = patch(get(h(jj),'XData'),get(h(jj),'YData'),C(1:3,jj)','FaceAlpha',ALPHA);
end

[~,h_legend] = legend(SIM);
PatchInLegend = findobj(h_legend, 'type', 'patch');

for i = 1:M
    set(PatchInLegend(i), 'FaceColor', COLORS_V(:,i)); 
end 

%legend boxoff; uncomment if leged should ot have a box

end
