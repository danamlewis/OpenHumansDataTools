#!/bin/bash

# This was designed based on the Nightscout data source type from the Nightscout Data Transfer app
# This script unzips OH data, pulls the timestamp from device status and adds it along with basic timestamp and BGs into an output file
# You can easily sub in different data $type file names in the future based on the project needs
# This script has been updated to support both the original NS data transfer tool file naming (file.json) and the fall 2017 updated naming (file_date_to_date.json)

#run from the folder where your OH data is downloaded to

# exit the script right away if something fails
set -eu

ls -d [0-9]* | while read dir; do

    # Print the directory/folder name you're investigating
    echo $dir

    cd $dir/direct-sharing-31/
    
    #unzip and create entries.json; if it doesn't exist, continue
    gzip -cd entries.json.gz > ${dir}_entries.json || echo "No entries.json.gz found; continuing"
    mkdir -p ${dir}_entries_csv

    #look for new datestring-style files; unzip and create similarly named json
    ls entries*.gz | sed "s/entries//" | sed "s/.json.gz//" | grep _ | while read datestring; do
        gzip -cd entries${datestring}.json.gz > ${dir}_entries${datestring}.json
    done
    
    #list so you know what it's working on
    ls ${dir}_entries*


    # create headers in csv, this is an example from a particular project but the same format works for creating any headers
    echo 'Timestamp,BG,"Control(True/False)","Intervention(True/False)","Control/Intervention/Non-relevant","Day (TRUE) or Night (FALSE)","Hour of Day",Date,"# of Days Looping","# of days prior to upload","PROJECT_MEMBER_ID","Control exists??"' > ${dir}_entries_csv/${dir}_entries.csv

    # pull the timestamp from treatments files, regardless of name style
    gzcat treatments*.json.gz | jq . | grep timestamp | grep -v Z | head -1 | awk -F : '{print $4}' | grep -o '...$' | sed "s/+//" >> ${dir}_entries_csv/${dir}_entries.csv

    # pipe the json into a temporary file.data.csv, taking the dateString and sgv datums
    cat ${dir}_entries.json | jsonv dateString,sgv | egrep ",[0-9]" | egrep "[0-9]T[0-9]" >> ${dir}_entries_csv/${dir}_entries.data.csv || echo "Could not csv-ify ${dir}_entries.json; continuing"
    ls entries*.gz | sed "s/entries//" | sed "s/.json.gz//" | grep _ | while read datestring; do
        cat ${dir}_entries${datestring}.json | jsonv dateString,sgv | egrep ",[0-9]" | egrep "[0-9]T[0-9]" >> ${dir}_entries_csv/${dir}_entries.data.csv
    done

    #put all entries into the entries.csv; sort them; and de-duplicate them
    cat ${dir}_entries_csv/${dir}_entries.data.csv | sort -r | uniq >> ${dir}_entries_csv/${dir}_entries.csv

    #print the csv to confirm it was created
    ls ${dir}_entries_csv/${dir}_entries.csv

    #IF DESIRED: if not created yet, create a copy at the $dir level for the copies of the csv to go for easier analyzing
    mkdir -p ../../EntriesCopies

    #IF DESIRED: copy the csv into the top level folder
    cp ${dir}_entries_csv/${dir}_entries.csv ../../EntriesCopies/

    cd ../../

    # print copy done, so you know that it made it through a full cycle on a single data folder
    echo "Copy done"

done
