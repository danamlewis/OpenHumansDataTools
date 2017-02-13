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
    gzip -cd entries.json.gz > ${dir}_entries.json

    # print the name of the new file, to confirm it unzipped successfully
    echo ${dir}_entries.json

        mkdir -p ${dir}_entries_csv

    # pipe the json into csv, taking the dateString and sgv datums   
    cat ${dir}_entries.json | jsonv dateString,sgv > ${dir}_entries_csv/${dir}_entries.csv

    #print the csv to confirm it was created
    echo ${dir}_entries.csv
   
    #if not created yet, create a copy at the $dir level for the copies of the csv to go for easier analyzing
    #mkdir -p ../../EntriesCopies
    
    # copy the csv into the top level folder
    #cp ${dir}_entries.csv ~/Desktop/TestExampleDataFolderSingle/EntriesCopies/
   
   cd ../../

    # print copy done, so you know that it made it through a full cycle on a single data folder
    #echo "Copy done"

done

ls -d [0-9]* | while read dir; do

    echo "Starting participant $dir"

    # This loop will unzip the PROFILE/DEVICESTATUS/TREATMENTS files; convert to json; chunk into several files if needed depending on size; and convert to csv

    for type in profile treatments devicestatus; do

    cd $dir/direct-sharing-31/
        gzip -cd $type.json.gz > ${dir}_$type.json && echo "Extracted ${dir}_$type.json; splitting it..."

        #need to chunk-ify any large files
        jsonsplit ${dir}_$type.json 15000

        #create a folder for the csv output to go into
        mkdir -p ${dir}_${type}_csv

        #json2csv program will convert from json into csv
        cd ${dir}_${type}_parts
        echo "Creating CSV files..."
        ls *.json | while read file; do
            #read json file and convert to csv
            complex-json2csv $file > ../${dir}_${type}_csv/${file%.json}.csv
            echo -n "=" > /dev/stderr
        done
        echo

        cd ../${dir}_${type}_csv/
        echo -n "Participant $dir: $type CSV files created:"
        ls *$type*.csv | wc -l

        #(get out of csv and back to the rest of the data files)
        cd ../../../

    done

done
