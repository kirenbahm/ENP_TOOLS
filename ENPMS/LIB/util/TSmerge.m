function [ValueVector] = TSmerge(TSdata, outputVectorLength, outputStartDate, outputEndDate, inputStartDate, inputEndDate)

   % This function takes an input vector of equal-interval timeseries data,
   % and returns a vector for a specific desired time interval, filled in
   % with NaNs on either side where they don't overlap
   %
   % Create and NaN the value vector for the desired length
   %    Set the timeseries data to within the requested interval
   %    and replace NaN in the value vector with the data
   %
   % TSdata = vector of all input data values (equal-interval timeseries)
   % dlength = number of (equal-interval) timesteps desired in output dataset
   % aI=datenum(startdate) = desired output start date
   % aF=datenum(enddate) = desired output end date
   % cI=dfsstartdatetime = integer start date of input data (=num days since 1/1/0000)
   % cF=DfsTime+dfsstartdatetime = integer end date of input data (=num days since 1/1/0000)
   %
   % ValueVector = vector of desired time interval, with NaNs
   %
   % V2 changes:  11/15 keb
   %   changed to more descriptive variable names
   %   added a ton of comments


   % print input index values
   % fprintf('%d %d %d %d %d\n',dlength,aI,aF,cI,cF);

   % initialize output vector with NaNs
   ValueVector(1:outputVectorLength) = NaN;

   % If output vector start date is on or after input vector start date
   %   Calculate number of input vector values to skip before copying data
   %   Set output vector start copy date to 1
   %   Set input vector start copy date to 1 + number to skip
   if (outputStartDate >= inputStartDate)
       numInputValues2skip = outputStartDate - inputStartDate;
       i_aI = 1;
       i_cI = 1 + numInputValues2skip;

   % If output vector start date is before input vector start date
   %   Calculate number of output vector values to skip before copying data
   %   Set input vector start copy date to 1
   %   Set output vector start copy date to 1 + number to skip
   else
       d = inputStartDate - outputStartDate;
       i_cI = 1;
       i_aI= 1 + d;
   end


   if (outputEndDate >= inputEndDate)
       d = outputEndDate - inputEndDate;
       i_aF = (outputEndDate - outputStartDate) - d + 1;
       i_cF = inputEndDate - inputStartDate + 1;
   else
       d = inputEndDate - outputEndDate;
       i_aF = outputEndDate - outputStartDate + 1;
       i_cF = inputEndDate - inputStartDate + 1 - d;
   end

   % print output index values
   % fprintf('%d %d %d %d\n',i_aI,i_aF,i_cI,i_cF);

   ValueVector(i_aI:i_aF) = TSdata(i_cI:i_cF);
end
