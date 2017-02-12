#!/bin/bash

# The purpose of this script is to 1) unzip the json.gz files; convert to json; and output to a renamed file that is the projectmemberid's filetype.csv

# This loop will unzip the ENTRIES file; convert to json and pipe in dateString and sgv; and rename it as the projectmemberid_entries.csv

#change into the folder where your OH data is downloaded to 
cd ~/Desktop/TestExampleDataFolderSingle

ls -d [0-9]* | while read dir; do
    
    # Print the directory/folder name you're investigating
    echo $dir
  
  cd $dir/direct-sharing-31/

    #unzip the relevant json file and re-name it with the directory name as a json 
    gzip -cd entries.json.gz > ${dir}_entries.json
    
    # print the name of the new file, to confirm it unzipped successfully
    echo ${dir}_entries.json
    
    # pipe the json into csv, taking the dateString and sgv datums   
    cat ${dir}_entries.json | jsonv dateString,sgv > ${dir}_entries.csv
    
    #print the csv to confirm it was created
    echo ${dir}_entries.csv
    
    #if not created yet, create a copy at the $dir level for the copies of the csv to go for easier analyzing
    mkdir -p ../../EntriesCopies
    
    # copy the csv into the top level folder
    cp ${dir}_entries.csv ~/Desktop/TestExampleDataFolderSingle/EntriesCopies/
   
   cd ../../

    # print copy done, so you know that it made it through a full cycle on a single data folder
    echo "Copy done"

done

for type in profile devicestatus treatments; do

    # This loop will unzip the PROFILE/DEVICESTATUS/TREATMENTS file; convert to json; chunk into several files if needed depending on size; and convert to csv
    ls -d [0-9]* | while read dir; do
    
        echo $dir 
    cd $dir/direct-sharing-31/
            gzip -cd $type.json.gz > ${dir}_$type.json    
    echo ${dir}_$type.json
        #need to chunk-ify any large files
        jsonsplit ${dir}_$type.json 100000

        #json2csv program will convert from json into csv
        cd ${dir}_$type.json_parts
        ls *.json | while read file; do
        #read json file and convert to csv 
            complex-json2csv $file > ../${dir}_$file.csv
        done
        #(get out of parts and back to the rest of the data files)
        cd ../../../

        #print out the file to make sure you made it through a loop
        echo ${dir}_$type.csv

    done

done
