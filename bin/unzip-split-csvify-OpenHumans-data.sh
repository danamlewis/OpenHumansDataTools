#!/bin/bash

# The purpose of this script is to 1) unzip the json.gz files; 2) convert to json; and
# 3) output to a renamed file that is the projectmemberid's filetype.csv

#run from the folder where your OH data is downloaded to

# exit the script right away if something fails
set -eu

ls -d [0-9]* | while read dir; do

    echo "Starting participant $dir"

    # This loop will unzip the ENTRIES/PROFILE/DEVICESTATUS/TREATMENTS files; convert to json; chunk into several files if needed depending on size; and convert to csv

    for type in profile treatments entries devicestatus; do
        cd $dir/direct-sharing-31/
        gzip -cd $type.json.gz > ${dir}_$type.json && echo "Extracted ${dir}_$type.json; splitting it..."

        #need to chunk-ify any large files
        jsonsplit ${dir}_$type.json 10000

        #json2csv program will convert from json into csv
        cd ${dir}_${type}_parts
        ls *.json | while read file; do
            #read json file and convert to csv
            complex-json2csv $file > ../${file%.json}.csv
            echo -n "=" > /dev/stderr
        done
        echo

        cd ../
        echo -n "Participant $dir: $type CSV files created:"
        ls *$type*.csv | wc -l

        #(get out of parts and back to the rest of the data files)
        cd ../../

    done

done
