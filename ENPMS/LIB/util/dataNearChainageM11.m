%---------------------------------------------------------------------
% function DATANEAR = dataNearChainageM11(mapM11chain,DATA)
%---------------------------------------------------------------------
function DATANEAR = dataNearChainageM11(INI,KEY,DATA)

% split the string into parts
STR_TEMP = strsplit(KEY,';');
% find the requested chainage:
CF = INI.CONVERT_M11CHAINAGES;
N = str2num(STR_TEMP{2})*CF;

% find all chainages for given combnation of a stream name and data type
%ii = find(strcmp(DATA.STREAM,upper(STR_TEMP{1})))
%ii = find(strcmp(DATA.TYPE ,STR_TEMP{3})));

ii = find(strcmp(DATA.STREAM,upper(STR_TEMP{1})) & strcmp(DATA.TYPE ,STR_TEMP{3}));

if isempty(ii)
    % not found return empty array
    DATANEAR = [];
    return 
end

[minValue, m] = min(abs(DATA.CHAINAGE(ii)-N));

m = ii(m);

% Assign the structure of the closest computed to station;
DATANEAR.T = DATA.T;
DATANEAR.V = DATA.V(:,m);
DATANEAR.TYPE = DATA.TYPE(m);
DATANEAR.UNIT = DATA.UNIT(m);
DATANEAR.NAME = DATA.NAME(m);
DATANEAR.UNITDESCR = DATA.UNITDESCR(m);
DATANEAR.X = DATA.X(m);
DATANEAR.Y = DATA.Y(m);
DATANEAR.CHAINAGE = DATA.CHAINAGE(m);
DATANEAR.STREAM = DATA.STREAM(m);
DATANEAR.M11CHAIN = DATA.M11CHAIN(m);

end