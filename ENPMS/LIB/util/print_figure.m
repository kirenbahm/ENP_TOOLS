function [output_args] = print_figure(S)

% NumTicks = 14;
% L = get(gca,'XLim');
% set(gca,'XTick',linspace(L(1),L(2),NumTicks));



ax = gca;
ax.XTickMode = 'manual';
ax.YTickMode = 'manual';
ax.ZTickMode = 'manual';

fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 12 5];
fig.PaperPositionMode = 'manual';

set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperSize', [12,5]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0,0,12,5]);
set(gca, 'Position', get(gca, 'OuterPosition') - ...
   get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);

%set(gca,'LooseInset',get(gca,'TightInset')); % THIS IS THE NEW LINE

set(gcf, 'Renderer', 'OpenGL');


%print(char(S),'-dpng','-r600');
F=strrep(S,'.','-');
F = strcat(S,'.png');
exportfig(char(F),'Format','png','width',12,'height',6,'FontSize',12);

%exportfig(char(F),'resolution',600,'FontSize',10,'width',12,'height',6);
%saveas(gcf,char(F));

end