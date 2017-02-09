#!/bin/bash

# The purpose of this script is to 1) unzip the json.gz files; convert to json; and output to a renamed file that is the projectmemberid's filetype.csv

# This loop will unzip the ENTRIES file; convert to json and pipe in dateString and sgv; and rename it as the projectmemberid_entries.csv

#run this from the folder where your OH data is downloaded to 

ls | while read dir; do

    # Print the directory/folder name you're investigating
    echo $dir

    #unzip the relevant json file and pipe the json into csv, taking just the dateString and sgv fields
    gzip -cd $dir/direct-sharing-31/entries.json.gz | jsonv dateString,sgv > $dir/direct-sharing-31/${dir}_entries.csv
    
    #print the csv to confirm it was created
    echo ${dir}_entries.csv
    
    #if not created yet, create a copy at the $dir level for the copies of the csv to go for easier analyzing
    mkdir -p EntriesCopies
    
    # copy the csv into the top level folder
    cp ${dir}/direct-sharing-31/${dir}_entries.csv EntriesCopies/
    
    # print copy done, so you know that it made it through a full cycle on a single data folder
    echo "Copy done"

done

# This loop will unzip the PROFILE file; convert to json and pipe in dateString and sgv; and rename it as the projectmemberid_profile.csv
# DO NOT UNCOMMENT UNTIL: figure out which json things we want to port (instead of dateString and sgv) into csv
#ls | while read dir; do
#    echo $dir 
#    gzip -cd $dir/direct-sharing-31/profile.json.gz | jsonv dateString,sgv > $dir/direct-sharing-31/${dir}_profile.csv
#    echo ${dir}_profile.csv
#    mkdir -p ProfileCopies
#    cp ${dir}/direct-sharing-31/${dir}_profile.csv ~/Desktop/TestExampleDataFolder/ProfileCopies/
#    echo "Copy done"
#done

# This loop will unzip the DEVICESTATUS file; convert to json and pipe in dateString and sgv; and rename it as the projectmemberid_devicestatus.csv
# DO NOT UNCOMMENT UNTIL: figure out which json things we want to port (instead of dateString and sgv) into csv
#ls | while read dir; do
#    echo $dir 
#    gzip -cd $dir/direct-sharing-31/devicestatus.json.gz | jsonv dateString,sgv > $dir/direct-sharing-31/${dir}_devicestatus.csv
#    echo ${dir}_devicestatus.csv
#    mkdir -p DeviceStatusCopies
#    cp ${dir}/direct-sharing-31/${dir}_devicestatus.csv ~/Desktop/TestExampleDataFolder/DeviceStatusCopies/
#    echo "Copy done"
#done

# This loop will unzip the TREATMENTS file; convert to json and pipe in dateString and sgv; and rename it as the projectmemberid_treatments.csv
# DO NOT UNCOMMENT UNTIL: figure out which json things we want to port (instead of dateString and sgv) into csv
#ls | while read dir; do
#    echo $dir 
#    gzip -cd $dir/direct-sharing-31/treatments.json.gz | jsonv dateString,sgv > $dir/direct-sharing-31/${dir}_treatments.csv
#    echo ${dir}_treatments.csv
#    mkdir -p TreatmentsCopies
#    cp ${dir}/direct-sharing-31/${dir}_treatments.csv ~/Desktop/TestExampleDataFolder/TreatmentsCopies/
#    echo "Copy done"
#done

