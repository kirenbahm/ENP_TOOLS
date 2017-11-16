function X = get_station_list_alt_delete_this_function(infile)
%this reads the selected_station_list text file
% This is the new method for reading the station list, implemented 11/2017.
% The script was renamed 'get_station_list' so it replaced the previous version.
% The old version was renamed 'get_station_list_old_format'
% keb 11/2017

% 	% open file ------------------
fid = fopen(char(infile));
if fid==-1
  error('File %s not found or permission denied', infile);
end

i = 0;
while  (~feof(fid))
    i = i + 1;
        %read a line
    X{i} = fgetl(fid);
end

return

end
