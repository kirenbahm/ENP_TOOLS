function mapSTATIONS = create_mapSTATIONS(D)                                % if this used? If so where?

mapSTATIONS = containers.Map();

for i = 1:length(D{1})
    ST.NAME = char(D{1}(i,:));
    ST.AGENCY = char(D{2}(i,:));
    ST.STR1 = char(D{3}(i,:));
    ST.BASIN = char(D{4}(i,:));
    ST.ELEVATION = D{5}(i,:);
    ST.LAT = D{6}(i,:);
    ST.LONG = D{7}(i,:);
    ST.DATUM = char(D{8}(i,:));
    ST.X_UTM17 = D{9}(i,:);
    ST.Y_UTM17 = D{10}(i,:);
    ST.DATE = char(D{11}(i,:));
    ST.UPDATES = char(D{12}(i,:));
    ST.N = D{13}(i,:);
    ST.F1 = D{14}(i,:);
    ST.PARK = char(D{15}(i,:)); 
    mapSTATIONS(char(ST.NAME)) = ST;
end

end

