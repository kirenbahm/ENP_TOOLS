%---------------------------------------------------------------------
% function DATA = determineChainageM11(INI,DATA)
%---------------------------------------------------------------------
function DATA = determineChainageM11(INI,DATA)

SZ = size(DATA.V);
CF = INI.CONVERT_M11CHAINAGES;
fprintf('--- CONVERSION FACTOR FOR CHAINAGES::%f\n',CF);

for i=1:SZ(2)
    M11CHAIN = '';
    N = NaN;
    M11CHAIN = strrep(DATA.NAME{i},' ','');
    STR_TEMP = strsplit(M11CHAIN,';');
    N = str2num(STR_TEMP{2})*CF; % if chainage is per foot -> meters
    DATA.CHAINAGE(i) = N;
    
    NSTR = sprintf('%.0f',N);
    DATA.TYPE{i} = strrep(DATA.TYPE{i},' ','');
    if length(STR_TEMP) == 3
        % Code for MIKE 11
        M11CHAIN = [STR_TEMP{1} ';' NSTR ';' STR_TEMP{3}];
        DATA.STREAM{i} = STR_TEMP{1};
        DATA.M11CHAIN{i} = M11CHAIN;
    end
    
    if length(STR_TEMP) == 2
        %Code for MIKE 1D
        STRSPLIT2 = strsplit(DATA.NAME{i},' - ');
        STR_TEMP_B = strsplit(STRSPLIT2{2},';');
        M11CHAIN = [upper(STR_TEMP_B{1}) ';' NSTR ';' STRSPLIT2{1}];
        DATA.STREAM{i} = upper(STR_TEMP_B{1});
        DATA.M11CHAIN{i} = M11CHAIN;
    end
end

end
