#!/bin/bash

# Script outcomes.sh to pulls data range of entries & device status data; calculates % TIR and Readings in range plus average glucose 

# exit the script on errors.  most intermediate output is cached, so subsequent runs are faster
set -eu
       
outputdir="$PWD"

# create csv with PID and column headers

echo -n "PID, Entries Start Date, Entries End Date, Entries Days (Total), Devicestatus Start Date, Devicestatus End Date, Devicestatus Days (Total)," | tee outcomes.csv

echo "Time Low (% < 70), Low readings, Time in range (%), Readings in range, Time high (% > 180), High readings, Average glucose" | tee -a outcomes.csv

ls -d [0-9]* | while read dir; do

    cd $dir/direct-sharing-31/
   
    echo -n \"${dir}\",  | tee -a "$outputdir/outcomes.csv"

    for type in entries devicestatus; do

        # if the file we need already exists (and isn't empty), don't re-generate it
        if [ ! -s /tmp/${dir}_${type}-dates.sorted ]; then 
            
            # find all the dates in 2018-01-01 format. just sort the input file once for speed, and use for all three checks below
            # move the file over to it permanent name only after it successfully completes
            cat ${dir}_${type}*_csv/*.csv | egrep -o "20(1[4-9]|[2-9][0-9])-[01][0-9]-[0-3][0-9]" | sort > /tmp/${dir}_${type}-dates.sorted.new && \
            mv /tmp/${dir}_${type}-dates.sorted.new /tmp/${dir}_${type}-dates.sorted
        fi

        # check for start and end date, and output into csv
        cat /tmp/${dir}_${type}-dates.sorted | uniq | head -1 | tr '\n' ',' | tee -a "$outputdir/outcomes.csv"
        cat /tmp/${dir}_${type}-dates.sorted | uniq | tail -1 | tr '\n' ',' | tee -a "$outputdir/outcomes.csv" 

        # count the number of unique days in which there is data
        cat /tmp/${dir}_${type}-dates.sorted | uniq -c | sort -g | wc -l | tr '\n' ',' | tee -a "$outputdir/outcomes.csv" 

    done
    
    # calculate time in range only for days with devicestatus data
    
    mkdir -p /tmp/${dir}/
    
    type=devicestatus
    
    if [ ! -s /tmp/${dir}_${type}-dates.sorted.uniq ]; then
       
       # create a sorted list of all the unique dates looping
        cat /tmp/${dir}_${type}-dates.sorted | uniq > /tmp/${dir}_${type}-dates.sorted.uniq.new && \
        mv /tmp/${dir}_${type}-dates.sorted.uniq.new /tmp/${dir}_${type}-dates.sorted.uniq
    fi
    
    type=entries
    
    if [ ! -s /tmp/${dir}_${type}.sorted.uniq ]; then
        cat ${dir}_${type}*_csv/*.csv | sort | uniq > /tmp/${dir}_${type}.sorted.uniq.new && \
        mv /tmp/${dir}_${type}.sorted.uniq.new /tmp/${dir}_${type}.sorted.uniq
    fi
    
    if [ ! -s /tmp/${dir}/${type}-looping.csv ]; then
        LC_ALL=C fgrep -f /tmp/${dir}_devicestatus-dates.sorted.uniq /tmp/${dir}_${type}.sorted.uniq > /tmp/${dir}/${type}-looping.csv.new && \
        mv /tmp/${dir}/${type}-looping.csv.new /tmp/${dir}/${type}-looping.csv
    fi
    
    cd /tmp/${dir}/
    
    # this replaces timeSpent.py to calculate TIR etc.
    cat /tmp/${dir}_${type}.sorted.uniq | awk 'BEGIN{OFS=",";} {if ($2<70) low++; else if ($2>180) high++; else inrange++; count++; sum += $2} END {print low/count,low,inrange/count,inrange,high/count,high,sum/count}' | tee -a "$outputdir/outcomes.csv"

    cd "$outputdir/"

    #echo | tee -a "$outputdir/outcomes.csv" 
    
done
