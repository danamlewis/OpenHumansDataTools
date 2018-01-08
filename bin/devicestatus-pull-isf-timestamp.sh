#The purpose of this script is to 1) pull ISF and timestamp values from devicestatus csv files 2) output to a new csv file.
#This assumes that you have unzipped and .csv devicestatus files. If not, use the script in the OpenHumansDataTools repo prior to running this script.
#install csvkit prior to running the script.

#this script will only run with OpenAPS datasets, not Loop.

#!/bin/bash

#run from the folder where your OH data is downloaded to. 

set -eu

ls -d [0-9]* | while read dir; do

	echo "Creating files for participant" $dir 
	
	cd $dir/direct-sharing-31/${dir}_devicestatus_csv
	
	mkdir -p autotune_analysis
	
	ls -d *.csv | while read file; do

    #cut timestamp and isf values from the devicestatus files and save to a new csv file

		csvcut -c openaps/enacted/timestamp $file > ${file%.csv}_timestamp.csv
		csvcut -c openaps/enacted/reason $file | awk -F "\"*, \"*" '{print $4}' | sed 's/.*://' > ${file%.csv}_isf.csv
		paste -d, ${file%.csv}_isf.csv <(cut -d, -f1- ${file%.csv}_timestamp.csv) > autotune_analysis/${file%.csv}_autotune.csv
		rm ${file%.csv}_isf.csv ${file%.csv}_timestamp.csv

 		echo ${file%.csv}_autotune.csv
	 
	done
	
	cd ../../../
  
done
