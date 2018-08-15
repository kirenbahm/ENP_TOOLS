function DFS0 = DFS0_assign_DTYPE_UNIT(DFS0,NAME)

if regexpi(NAME,'rain')
   DFS0.UNIT = 'mm/day';
   DFS0.TYPE = 'Rain';
elseif regexpi(NAME,'stage')
   DFS0.UNIT = 'ft';
   DFS0.TYPE = 'Stage';
elseif regexpi(NAME,'PET')
   DFS0.UNIT = 'mm';
   DFS0.TYPE = 'PET';
elseif regexpi(NAME,'water')
   DFS0.UNIT = 'ft';
   DFS0.TYPE = 'Water Level';
   % keep water ahead of salinity because there is surface-water-salinity
elseif regexpi(NAME,'salinity')
   DFS0.UNIT = 'ppt';
   DFS0.TYPE = 'Salinity';
elseif  regexpi(NAME,'ET')
   DFS0.UNIT = 'mm';
   DFS0.TYPE = 'ET';
elseif  regexpi(NAME,'_Q')
   %     DFS0.UNIT = 'mm';
   %     DFS0.TYPE = 'ET';
else % no need to assign already assigned
   DFS0.UNIT = 'ft';
   DFS0.TYPE = 'Unknown';
end

end
