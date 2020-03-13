function DATA_2D = BC2D_create_DFS2(INI)

fprintf('\n\n Beginning BC2D_create_DFS2.m \n\n');

%turn off interpolation warnings for duplicate points
warning('off','MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');

file_dfs2 = BC2D_write_DFS2_header(INI);

% initialize iteration vectors
XD = [];
YD = [];
HD = [];

k = 0;
PLOT = 0;

% create mesh
X = [INI.X0:INI.cell:INI.X0+(INI.nx-1)*INI.cell];
Y = [INI.Y0:INI.cell:INI.Y0+(INI.ny-1)*INI.cell];
[XI_UTM,YI_UTM]=meshgrid(X,Y);

% determine number of steps
% NSTEPS = datenum(INI.DATE_E) - datenum(INI.DATE_I) + 1;

NSTEPS = INI.NSTEPS;

% %for i = ntime_start:ntime_end
for i = 1:NSTEPS
    %print mark on each 100 step
    if (~mod(i,100))
        t = datestr(datetime(INI.DATE_I,'InputFormat','dd/MM/yyyy') + hours(i - 1));
        fprintf(' ... Step: %s: %d/%d \n', char(t), i,NSTEPS);
    end
     
    [HD, XD, YD,L] = BC2D_get_H_TS(INI,i);
    
    N = find(~isnan(HD));
    
    HD = HD(N);
    XD = XD(N);
    YD = YD(N);
    n = length(HD);
    HD = reshape(HD,n,1);
    XD = reshape(XD,n,1);
    YD = reshape(YD,n,1);
    %TriScatteredInterp is not recommended
    %F = TriScatteredInterp(XD,YD,HD,'natural');
    
    F = scatteredInterpolant(XD,YD,HD,'natural');
    HI = F(XI_UTM,YI_UTM);
        
    N = find(isnan(HI));
    HI(N) = -1e-030;
    
    HH =HI';
    file_dfs2.WriteItemTimeStepNext(0, NET.convertArray(single(HH(:)))); 
    
    
    DATA_2D(:,:,i) = HH;
%     NP202 = DATA_2D(45,39,i);
%     BICYA11 = DATA_2D(20,47);
    
    k = k + 1;
%     contourf(XI_UTM,YI_UTM,DOMAIN);
   
    h = HD;
    x = XD;
    y = YD;

if ~PLOT continue; end
%start plotting
    plot(XD,YD,'d','MarkerSize',4,'MarkerFaceColor','red','MarkerEdgeColor','w');
    hold on
    [C,h] = contourf(XI_UTM,YI_UTM,HI); %[C,h] = contourf(XI_UTM,YI_UTM,HI);
    
    caxis([-2 10]);
    TH = text(x,y,L,'FontSize',7,'FontName','times');
    clabel(C,h);
    %title(sprintf('%s',ds));
%     colorbar('location','westoutside');
    plot(XD,YD,'d','MarkerSize',4,'MarkerFaceColor','red','MarkerEdgeColor','w');

%     axis equal;
%     M(i) = getframe(gcf);
%     pause(0.1);
    mapshow(INI.SHP_DOMAIN);
%     [XDOMAIN, YDOMAIN] = get_XYDOMAIN();
%     plot(XDOMAIN,YDOMAIN);
    axis equal;
    %ds_FN = [PREFIX '_BMP/', ds_FN];
    %saveas(gcf,char(ds_FN),'bmp')
%     saveas(gcf,char(ds_FN),'bmp')

    hold off
%     pause(0.001);
%end plotting
end

file_dfs2.Close();

end