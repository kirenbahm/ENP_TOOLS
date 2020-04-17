function BC2D_save_H_points(INI)

% This function writes data in the 'HEADER' format to an *.XLSX spreadsheet
% It is unclear on the intent of this saved file beyond data evaluation.

XLSX = INI.XLSX;
HEADER  = {'H_STATION','X','Y','N','T_START','T_END'};
   
if strcmpi(INI.OLorSZ,'OL') 
    SHEET = 'HR';
elseif strcmpi(INI.OLorSZ,'SZ')
    SHEET = 'DD';
end

xlswrite(XLSX, HEADER, SHEET, 'A1');

% mapshow(char(INI.SHP_DOMAIN));
% hold on;
X = INI.H_POINTS.X';
Y = INI.H_POINTS.Y';
% plot(X,Y,'o');
N = INI.H_POINTS.N';
ST = INI.H_POINTS.STATION';
I = datestr(INI.H_POINTS.DATE_I);
E = datestr(INI.H_POINTS.DATE_E);
%A = char(ST);
II = INI.H_POINTS.I';
JJ = INI.H_POINTS.J';

xlswrite(XLSX, ST, SHEET, 'A2');
xlswrite(XLSX, X, SHEET, 'B2');
xlswrite(XLSX, Y, SHEET, 'C2');
xlswrite(XLSX, N, SHEET, 'D2');
xlswrite(XLSX, cellstr(I), SHEET, 'E2');
xlswrite(XLSX, cellstr(E), SHEET, 'F2');
xlswrite(XLSX, II, SHEET, 'G2');
xlswrite(XLSX, JJ, SHEET, 'H2');
% T = table(A,X,Y,N,I,E);
% struct2table(INI.H_POINTS);
% update_ALL_STATIONS(INI) ;

end
