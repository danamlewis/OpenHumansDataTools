#!/bin/bash

# The purpose of this script is to 1) unzip the json.gz files; 2) convert to json; and
# 3) output to a renamed file that is the projectmemberid's filetype.csv

# This was designed based on the Nightscout data source type from the Nightscout Data Trasnfer app
# This pulls profile, entries, treatments, and devicestatus data
# You can easily sub in different data $type file names in the future;
# the first for loop is for special purpose, but second for loop is the most general purpose.

#run from the folder where your OH data is downloaded to

ls -d [0-9]* | while read dir; do

    # Print the directory/folder name you're investigating
    echo $dir

    cd $dir/direct-sharing-31/

    # if date run has a space in .gz file name, remove the space before processing
    for f in *\ *; do mv "$f" "${f// /}"; done &>/dev/null
    
    # exit the script right away if something fails
    set -eu

    #unzip the relevant json file and re-name it with the directory name as a json
    type=entries
    ls ${type}*.gz | sed "s/.gz//" | while read file; do    

        gzip -cd ${file} > ${dir}_${file}
        #gzip -cd entries.json.gz > ${dir}_entries.json

        # print the name of the new file, to confirm it unzipped successfully
        ls ${dir}_${file}

        mkdir -p ${dir}_${file}_csv

        # pipe the json into csv, taking the dateString and sgv datums
        if cat ${dir}_${file} | jq -e .[0] > /dev/null; then
          cat ${dir}_${file} | jq '.[] | [.dateString, .sgv | tostring] | join (", ")' | tr -d '"' > ${dir}_${file}_csv/${dir}_${file}.csv
        else
          echo "${dir}_${file} does not appear to be valid json, or is empty"
        fi

        #print the csv to confirm it was created
        ls ${dir}_${file}_csv/${dir}_${file}.csv || echo "${dir}_${file}.csv not found - continuing"

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
    ls ${type}*.gz | sed "s/.gz//" | while read file; do
        gzip -cd ${file}.gz > ${dir}_${file}.json
        #gzip -cd $type.json.gz > ${dir}_$type.json
        echo "Extracted ${dir}_${file}.json; splitting it..."

        #need to chunk-ify any large files
        if cat ${dir}_${file}.json | jq -e .[0] > /dev/null; then
          jsonsplit ${dir}_${file}.json 15000
        else
          echo "${dir}_${file}.json does not appear to be valid json"
          continue
        fi

        #create a folder for the csv output to go into
        mkdir -p ${dir}_${file}_csv

        #json2csv program will convert from json into csv
        cd ${dir}_${file}_parts
        echo "Creating CSV files..."
        ls *.json | while read partsfile; do
            #read json file and convert to csv
            if cat ${partsfile} | jq -e .[0] > /dev/null; then
              complex-json2csv ${partsfile} > ../${dir}_${file}_csv/${partsfile%.json}.csv
            else
              echo "${partsfile} does not appear to be valid json"
            fi
            echo -n "=" > /dev/stderr
        done
        echo

        cd ../${dir}_${file}_csv/
        echo -n "Participant $dir: $file CSV files created:"
        ls *$file*.csv | wc -l
        cd ../

    done # ls ${type}_*.gz | sed "s/.gz//" | while read file

    #(get out of csv and back to the rest of the data files)
    cd ../../

  done # for type in profile treatments devicestatus

done # ls -d [0-9]* | while read dir
