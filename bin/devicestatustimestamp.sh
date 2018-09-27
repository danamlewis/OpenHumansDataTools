# This will pull timestamp out of device status, so you can run howmuchdevicestatusdata.sh later

#This assumes that you have unzipped and .csv devicestatus files. If not, use the script in the OpenHumansDataTools repo prior to running this script.
# install csvkit prior to running the script

#this script will only run with OpenAPS datasets, not Loop. (Future TODO: add loop/enacted/timestamp so Loop users don't result in 0)

#!/bin/bash

#run from the folder where your OH data is downloaded to. 

set -eu

ls -d [0-9]* | while read dir; do

    echo "Creating files for participant" $dir 
   
    cd $dir/direct-sharing-31/${dir}_devicestatus_*csv
   
    mkdir -p ../devicestatus_timestamp
    
    ls -d *.csv | while read file; do

    #cut timestamp and isf values from the devicestatus files and save to a new csv file
        #echo "Timestamp" > ../devicestatus_timestamp/${file%.csv}_timestamp.csv
        paste -d, \
          <(csvcut -c openaps/enacted/timestamp $file | cut -d, -f1- | sed 1d) \
          >> ../devicestatus_timestamp/${file%.csv}_timestamp.csv
        echo ${file%.csv}_timestamp.csv
    
    done
   
    cd ../../../
 
done
