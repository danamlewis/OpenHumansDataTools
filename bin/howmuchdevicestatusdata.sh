# Script howmuchdevicestatusdata.sh to pull the date ranges of OH data, output into CSV so you can analyze how much looping time someone has
# You should have run devicestatustimestamp.sh first

#!/bin/bash

set -eu
        
# create csv with PID and column headers
echo "PID, Start Date, End Date, Days (Total), Months (Total)" > howmuchdevicestatusdata.csv

# Note - this months averages and rounds up; you may want to convert to a decimal when analyzing, or re-do the formula in excel for the output.

ls -d [0-9]* | while read dir; do

    cd $dir/direct-sharing-31/devicestatus_timestamp
    
    echo $dir
 
    ls -d *.csv | while read file; do

        echo $file 

        # check for start and end date, and output into csv
        
        echo -n "${dir},"  >> ../../../howmuchdevicestatusdata.csv
            
        cat *timestamp*csv |  awk -F T '{print $1}' | egrep "^20[0-9][0-9]-" | cut -c 1-10 | sort | uniq | head -1 | tr '\n' ',' >> ../../../howmuchdevicestatusdata.csv
    
        cat *timestamp*csv | awk -F T '{print $1}' | egrep "^20[0-9][0-9]-" | cut -c 1-10 | sort | uniq | tail -1 | tr '\n' ',' >> ../../../howmuchdevicestatusdata.csv
       
        cat *timestamp*csv | awk -F T '{print $1}' | egrep "^20[0-9][0-9]-" | cut -c 1-10 | sort | uniq -c | sort -g | wc -l | tr '\n' ',' >> ../../../howmuchdevicestatusdata.csv
        
        cat *timestamp*csv | awk -F T '{print $1}' | egrep "^20[0-9][0-9]-" | cut -c 1-7 | sort | uniq -c | sort -g | wc -l | tr '\n' ',' >> ../../../howmuchdevicestatusdata.csv

        echo >> ../../../howmuchdevicestatusdata.csv

    done

    cd ../../../

done
