#!/bin/bash

# The purpose of this script is to 1) unzip the json.gz files; 2) convert to json; and
# 3) output to a renamed file that is the projectmemberid's filetype.csv

# This was designed based on the Nightscout data source type from the Nightscout Data Trasnfer app
# This pulls profile, entries, treatments, and devicestatus data
# You can easily sub in different data $type file names in the future;
# the first for loop is for special purpose, but second for loop is the most general purpose.

#run from the folder where your OH data is downloaded to

# exit the script right away if something fails
set -eu

ls -d [0-9]* | while read dir; do

    # Print the directory/folder name you're investigating
    echo $dir

    cd $dir/direct-sharing-31/

    #unzip the relevant json file and re-name it with the directory name as a json
    type=entries
    ls ${type}_*.gz | sed "s/.gz//" | while read file; do
        gzip -cd ${file} > ${dir}_${file}
        #gzip -cd entries.json.gz > ${dir}_entries.json

        # print the name of the new file, to confirm it unzipped successfully
        ls ${dir}_${file}

        mkdir -p ${dir}_${file}_csv

        # pipe the json into csv, taking the dateString and sgv datums
        cat ${dir}_${file} | jsonv dateString,sgv > ${dir}_${file}_csv/${dir}_${file}.csv

        #print the csv to confirm it was created
        ls ${dir}_${file}.csv

    done

    cd ../../

    # print copy done, so you know that it made it through a full cycle on a single data folder
    #echo "Copy done"

done

ls -d [0-9]* | while read dir; do

  echo "Starting participant $dir"

  # This loop will unzip the PROFILE/DEVICESTATUS/TREATMENTS files; convert to json; chunk into several files if needed depending on size; and convert to csv

  for type in profile treatments devicestatus; do

    cd $dir/direct-sharing-31/
    ls ${type}_*.gz | sed "s/.gz//" | while read file; do
        gzip -cd ${file} > ${dir}_${file}
        #gzip -cd $type.json.gz > ${dir}_$type.json
        echo "Extracted ${dir}_${file}; splitting it..."

        #need to chunk-ify any large files
        jsonsplit ${dir}_${file} 15000

        #create a folder for the csv output to go into
        mkdir -p ${dir}_${file}_csv

        #json2csv program will convert from json into csv
        cd ${dir}_${file}_parts
        echo "Creating CSV files..."
        ls *.json | while read partsfile; do
            #read json file and convert to csv
            complex-json2csv ${partsfile} > ../${dir}_${partsfile}_csv/${partsfile%.json}.csv
            echo -n "=" > /dev/stderr
        done
        echo

        cd ../${dir}_${file}_csv/
        echo -n "Participant $dir: $file CSV files created:"
        ls *$file*.csv | wc -l

        #(get out of csv and back to the rest of the data files)
        cd ../../../

    done # ls ${type}_*.gz | sed "s/.gz//" | while read file

  done # for type in profile treatments devicestatus

done # ls -d [0-9]* | while read dir
