# This was designed based on the Nightscout data source type from the Nightscout Data Transfer app
# This script unzips OH data, pulls the timestamp from device status and adds it along with basic timestamp and BGs into an output file
# You can easily sub in different data $type file names in the future based on the project needs 

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
    # I would keep these, as it's helpful when keeping an eye to see if the script exited anywhere before finishing the full folder
    echo ${dir}_entries.json

        mkdir -p ${dir}_entries_csv

    # create headers in csv, this is an example from a particular project but the same format works for creating any headers
    echo 'Timestamp,BG,"Control(True/False)","Intervention(True/False)","Control/Intervention/Non-relevant","Day (TRUE) or Night (FALSE)","Hour of Day",Date,"# of Days Looping","# of days prior to upload","PROJECT_MEMBER_ID","Control exists??"' > ${dir}_entries_csv/${dir}_entries.csv

    # get the timestamp from treatments and put it into csv
    gzcat treatments.json.gz | json | grep timestamp | grep -v Z | head -1 | awk -F : '{print $4}' | grep -o '...$' | sed "s/+//" >> ${dir}_entries_csv/${dir}_entries.csv

    # pipe the json into csv, taking the dateString and sgv datums   
    cat ${dir}_entries.json | jsonv dateString,sgv | egrep ",[0-9]" | egrep "[0-9]T[0-9]" >> ${dir}_entries_csv/${dir}_entries.csv

    #print the csv to confirm it was created
    #again, helpful to keep this to show that it successfully did this particular file in the folder
    echo ${dir}_entries.csv
  
    #IF DESIRED: if not created yet, create a copy at the $dir level for the copies of the csv to go for easier analyzing
    #mkdir -p ../../EntriesCopies
   
    #IF DESIRED: copy the csv into the top level folder
    #cp ${dir}_entries.csv ~/Desktop/TestExampleDataFolderSingle/EntriesCopies/
  
   cd ../../

    # print copy done, so you know that it made it through a full cycle on a single data folder
    #echo "Copy done"

done
