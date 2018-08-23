# !/bin/bash

# Name: data_requestMIKE.sh
# Created: 2018-07-10
# Author: Adam Karczynski

# The following script runs a data request to DFE for MIKE.she and MATLAB processing as part of the COP model.
# The script uses lists of STATION and DATATYPE from the '_input' directory, requests data from DFE via
# data_request.sh, and outputs *.dat files to tehir respective subdirectories "Flow", "Stage", and any
# additioanl as necessary.

# Designed and curated by Kiren Bahm and any changes to this script or the input stations or datatypes requested
# should be directed toward her.

if [[ $# -ne 3 ]] ; then
	print "\n\tUsage: $0 start_date end_date aggregate_level"
	print "\t ex: $0 2010-01-01 2017-12-31 hourly"
	print "\t *** Date format must be YYYY-mm-dd ***"
	print "\t *** Aggregate Level = real time, hourly, daily, and etc... ***" 
	exit 0
fi

start=$1
end=$2
time=$3

# Set storage location for reqursted data directories

baseDir=/opt/physical/adam/MIKE_MATLAB/DATA_ENP
subDir=_input

# For loop of requested DataTypes. More can be added as necessary but user must ensure and storage directories,
# station list with datatypes files exist and any additions are subsequently added to the 'for' loop and 'if'
# statements as necessary.

for dataType in Flow Stage ; do
	if [[ "$dataType" == Flow ]]
		then
		data_request.sh $baseDir/$subDir/stationFlow.lst $start $end $time average $subDir/$dataType validation_level
	else
		data_request.sh $baseDir/$subDir/stationStage.lst $start $end $time average $subDir/$dataType validation_level
	fi
done
