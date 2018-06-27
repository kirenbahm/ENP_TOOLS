function station_name_list = get_station_list(infile)

% This reads a text file with a list of stations.
% It will skip lines with a '#', which designates comment lines
%
% This is the new method for reading the station list, implemented 11/2017.
% keb 11/2017

% 	% open file ------------------
fid = fopen(char(infile));
if fid==-1
  error('File %s not found or permission denied', infile);
end

i = 0;
while  (~feof(fid))
  tmp = fgetl(fid);  %read a line
  if ~isempty(regexp(tmp,'^#', 'once')) % throw out comment lines
        trash=1;   
  else
  	 i = i + 1;
    % tmp= tmp(~isspace(tmp)); %remove spaces or tabs, can not have spaces
    station_name_list{i} = tmp; 
  end
end

return

end
