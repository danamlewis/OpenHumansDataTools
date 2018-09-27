# Script howmuchBGdata.sh to pull the date ranges of OH data, output into CSV so you can analyze how much BG data someone has

#!/bin/bash

set -eu
        
# create csv with PID and column headers
echo "PID, Start Date, End Date, Days (Total), Months (Total)" > howmuchdata.csv

ls -d [0-9]* | while read dir; do

    cd $dir/direct-sharing-31/${dir}_entries*csv
    
    echo $dir
 
    ls -d *.csv | while read file; do

        echo $file 

        # check for start and end date, and output into csv
        
        echo -n "${dir},"  >> ../../../howmuchBGdata.csv
            
        cat ${dir}_entries*csv |  awk -F T '{print $1}' | egrep "^20[0-9][0-9]-" | cut -c 1-10 | sort | uniq | head -1 | tr '\n' ',' >> ../../../howmuchBGdata.csv
    
        cat ${dir}_entries*csv | awk -F T '{print $1}' | egrep "^20[0-9][0-9]-" | cut -c 1-10 | sort | uniq | tail -1 | tr '\n' ',' >> ../../../howmuchBGdata.csv
       
        cat ${dir}_entries*csv | awk -F T '{print $1}' | egrep "^20[0-9][0-9]-" | cut -c 1-10 | sort | uniq -c | sort -g | wc -l | tr '\n' ',' >> ../../../howmuchBGdata.csv
        
        cat ${dir}_entries*csv | awk -F T '{print $1}' | egrep "^20[0-9][0-9]-" | cut -c 1-7 | sort | uniq -c | sort -g | wc -l | tr '\n' ',' >> ../../../howmuchBGdata.csv

        echo >> ../../../howmuchBGdata.csv

    done
   
    cd ../../../

done
