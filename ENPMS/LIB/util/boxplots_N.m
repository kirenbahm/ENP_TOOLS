function boxplots_N(DATA,LABELS,SIM,C,ALPHA,COLORS_V)
% Fnction plotting n time series per month or year
% requires data to be formatted in specific way

% Size of M is number of simulations. L is number of years or months
M=size(DATA,2);
L=size(DATA,1);
%COLORS_V = circshift(COLORS_V,1,2);

% Calculate the positions along the x axis to place the boxes evenly
POS=1:0.25:M*L*0.25+1+0.25*L;
POS(1:M+1:end)=[];

% DATA AND GROUP
X=[]; % initialize array of results values
GROUP=[]; % array of number of years or months times number of simulations
KEEP_POS = []; 
IND_DEL = []; % index_delete
UL = []; % 
UC = []; % colors
kk = 0; % adjust positions
for ii=1:L % years or months
    for jj=1:M % number of simulations
        TMP=DATA{ii,jj};
        if ~isempty(TMP)
            UL = [UL SIM(jj)];
            UC = [UC jj];
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
UL = [SIM ' '];
UC = unique(UC);

% PLOT
hh = boxplot(X,GROUP, 'positions', POSMOD,'Notch','on','Whisker',2); % hh is handle for figure

% SET X Labels
TMP=reshape(POS,M,[]);
labelpos = sum(TMP,1)./M;

set(gca,'xtick',labelpos);
set(gca,'xticklabel',LABELS);

% Apply colors
h = findobj(gca,'Tag','Box');
ALPHA = 1; % alpha can fade colors
for jj=1:length(h)
   p(jj) = patch(get(h(jj),'XData'),get(h(jj),'YData'),C(1:3,jj)','FaceAlpha',ALPHA);
end

% [~,h_legend] = legend(UL,'Color',[0.9 0.9 0.9]);
% PatchInLegend = findobj(h_legend, 'type', 'patch');

y1 = ylim; % this is the upper and lower limits of the timeseries
yd = y1(2)-y1(1); % this is the difference between upper and lower limits of timeseries
yt = get(gca,'ytick'); % this gets the label notation for vertical axis
yh = 0.025*yd; % this the spacing between legend entries
ypos = y1(2)-yd*0.05; % the initial position is at the top is at location ypos

x1=xlim; % this is the upper and lower limits of the timeseries
xd = x1(2)-x1(1);% this is the difference between upper and lower limits of timeseries
xt = get(gca,'xtick'); % this gets the label notation for vertical axis
xh = xd*0.05; % this the spacing between legend entries
xpos = x1(1); % the initial position is at the left hand side of the figure

ii = 0;

for i = UC
    ii = i;
    %set(PatchInLegend(ii), 'FaceColor', COLORS_V(:,i)); 
    %r=rectangle('Position',[xpos ypos xh yh],'FaceColor',COLORS_V(:,ii),'EdgeColor',COLORS_V(:,ii));
    r=rectangle('Position',[xpos ypos xh yh],'FaceColor',COLORS_V(:,ii));
    t=text(xpos + 1.15*xh, ypos + 0.6*yh,UL(ii));
    T = get(t);
    t.Margin = 0.01;
    t.Color = COLORS_V(:,ii);
    %t.BackgroundColor = [0.9 0.9 0.9];
    ypos =  ypos - 1.2*T.Extent(4);
    %rectangle('Position',T.Extent,'FaceColor','r')
end 
% legend('off');

%legend boxoff; uncomment if leged should ot have a box
end
