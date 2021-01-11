# !/bin/bash

# Name: data_requestMIKE.sh
# Created: 2018-07-10
# Author: Adam Karczynski


# RUN THIS SCRIPT ON TOADFISH  10.146.112.20


# The following script runs a data request to DFE for MIKE.she and MATLAB processing as part of the COP model.
# The script uses lists of STATION and DATATYPE from the '_input' directory, requests data from DFE via
# data_request.sh, and outputs *.dat files to their respective subdirectories "Flow", "Stage", and any
# additional as necessary.

# Designed and curated by Kiren Bahm and any changes to this script or the input stations or datatypes requested
# should be directed toward her.

if [[ $# -ne 2 ]] ; then
	echo "Usage: $0 start_date end_date"
	echo "ex: $0 2010-01-01 2017-12-31 or"
	echo "'begin_date' 'end_date' for fulle record"
	echo "*** Date format must be YYYY-mm-dd ***"
	echo ""
	echo "(run this script on toadfish 10.146.112.20)"
	exit 0
fi

start=$1
end=$2

# Set output and input storage locations for requested data directories

inputDir=_input
outputDir=/opt/physical/adam/MIKE_MATLAB/DATA_ENP
bin_dir=/opt/physical/util

# For loop of requested DataTypes. More can be added as necessary but user must ensure and storage directories,
# station list with datatypes files exist and any additions are subsequently added to the 'for' loop and 'if'
# statements as necessary.

for dataType in Flow Stage ; do
	if [[ "$dataType" == Flow ]]
		then
		$bin_dir/data_requestMIKE.sh $outputDir/$inputDir/stationFlow.lst $start $end aggregate_level aggregate_statistic $inputDir/$dataType validation_level
	elif [[ "$dataType" == Stage ]]
		then
		$bin_dir/data_requestMIKE.sh $outputDir/$inputDir/stationStage.lst $start $end aggregate_level aggregate_statistic $inputDir/$dataType validation_level
	else
		echo "Station-Datatype pair is not found"
	fi
done
