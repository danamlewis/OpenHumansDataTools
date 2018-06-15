#!/bin/bash

# Script outcomes.sh to pulls data range of entries & device status data; calculates % TIR and Readings in range plus average glucose

function dates-sorted-uniq {

    dir=$1
    filetype=${2-entries}
    looptype=${3-""}

    # if the file we need already exists (and isn't empty), don't re-generate it
    if [ ! -s /tmp/${dir}_${looptype}${filetype}-dates.sorted.uniq ]; then

        # find all the dates in 2018-01-01 format. just sort the input file once for speed, and use for all three checks below
        # move the file over to it permanent name only after it successfully completes
        gzcat -f ${dir}_${filetype}*.json* 2>/dev/null | grep "${looptype}" | egrep -o "20(1[4-9]|[2-9][0-9])-[01][0-9]-[0-3][0-9]" | sort | uniq > /tmp/${dir}_${looptype}${filetype}-dates.sorted.uniq.new && \
        mv /tmp/${dir}_${looptype}${filetype}-dates.sorted.uniq.new /tmp/${dir}_${looptype}${filetype}-dates.sorted.uniq
    fi
    #ls -la /tmp/${dir}_${looptype}${filetype}-dates.sorted.uniq

}

# exit the script on errors.  most intermediate output is cached, so subsequent runs are faster
set -eu

outputdir="$PWD"

# create csv with PID and column headers

echo -n "PID, Entries Start Date, Entries End Date, Entries Days (Total), Devicestatus Start Date, Devicestatus End Date, Devicestatus Days (Total)," | tee outcomes.csv

for looptype in Openaps Loop "Not looping"; do
    echo -n "${looptype} Time Low (% < 70), ${looptype} Low readings, ${looptype} Time in range (%), ${looptype} Readings in range, ${looptype} Time high (% > 180), ${looptype} High readings, ${looptype} Total readings, ${looptype} Average glucose, ${looptype} Estimated A1c, ${looptype} eAG*readings," | tee -a outcomes.csv
done
echo | tee -a "$outputdir/outcomes.csv"

ls -d [0-9]* | while read dir; do

    cd $dir/direct-sharing-31/

    echo -n \"${dir}\",  | tee -a "$outputdir/outcomes.csv"

    dates-sorted-uniq ${dir} entries
    dates-sorted-uniq ${dir} devicestatus
    dates-sorted-uniq ${dir} devicestatus openaps
    dates-sorted-uniq ${dir} devicestatus Loop

    for filetype in entries devicestatus; do

        # check for start and end date, and output into csv
        cat /tmp/${dir}_${filetype}-dates.sorted.uniq | head -1 | tr '\n' ',' | tee -a "$outputdir/outcomes.csv"
        cat /tmp/${dir}_${filetype}-dates.sorted.uniq | tail -1 | tr '\n' ',' | tee -a "$outputdir/outcomes.csv"

        # count the number of unique days in which there is data
        cat /tmp/${dir}_${filetype}-dates.sorted.uniq | wc -l | tr '\n' ',' | tee -a "$outputdir/outcomes.csv"

    done

    # calculate time in range only separately for each loop type, and for not-looping days

    mkdir -p /tmp/${dir}/

    if [ ! -s /tmp/${dir}_entries.sorted.uniq ]; then
        cat ${dir}_*entries*_csv/*.csv | sort | uniq > /tmp/${dir}_entries.sorted.uniq.new && \
        mv /tmp/${dir}_entries.sorted.uniq.new /tmp/${dir}_entries.sorted.uniq
    fi
    for looptype in openaps Loop; do
        if [ ! -s /tmp/${dir}/${looptype}-looping.csv ]; then
            if [ -s /tmp/${dir}_${looptype}devicestatus-dates.sorted.uniq ]; then
                LC_ALL=C fgrep -f /tmp/${dir}_${looptype}devicestatus-dates.sorted.uniq /tmp/${dir}_entries.sorted.uniq > /tmp/${dir}/${looptype}-looping.csv.new && \
                mv /tmp/${dir}/${looptype}-looping.csv.new /tmp/${dir}/${looptype}-looping.csv
            fi
        fi
    done
    # combine the openaps and Loop files into one combined file for all looping
    cat /tmp/${dir}_openapsdevicestatus-dates.sorted.uniq /tmp/${dir}_Loopdevicestatus-dates.sorted.uniq | sort >> /tmp/${dir}_loopingdevicestatus-dates.sorted.uniq
    looptype=not
    if [ ! -s /tmp/${dir}/${looptype}-looping.csv ]; then
        LC_ALL=C fgrep -vf /tmp/${dir}_loopingdevicestatus-dates.sorted.uniq /tmp/${dir}_entries.sorted.uniq > /tmp/${dir}/${looptype}-looping.csv.new && \
        mv /tmp/${dir}/${looptype}-looping.csv.new /tmp/${dir}/${looptype}-looping.csv
    fi


    cd /tmp/${dir}/

    for looptype in openaps Loop not; do
        # this replaces timeSpent.py to calculate TIR etc.
        if [ -s /tmp/${dir}/${looptype}-looping.csv ]; then
            cat /tmp/${dir}/${looptype}-looping.csv | awk 'BEGIN{OFS=",";} {if ($2<70) low++; else if ($2>180) high++; else inrange++; count++; sum += $2} END {print low/count,low,inrange/count,inrange,high/count,high,count,sum/count,(46.7 + sum/count) / 28.7,sum}' | tr '\n' ',' | tee -a "$outputdir/outcomes.csv"
        else
            echo -n ",,,,,,,,,," | tee -a "$outputdir/outcomes.csv"
        fi
    done

    cd "$outputdir/"

    echo | tee -a "$outputdir/outcomes.csv"

done
