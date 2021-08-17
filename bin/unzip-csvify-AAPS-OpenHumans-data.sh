#!/bin/bash
  
# The purpose of this script is to 1) unzip the .zip files; 2) convert the zipped json files into csv

# This is designed for the AndroidAPS (aka AAPS) uploader data type from Open Humans, which is under direct-sharing-396. If you have other sub-folders such as direct-sharing-31, you should use the unzip-split-csvify-OpenHumans-data.sh script instead, because of the different file structures from the Nightscout Uploader.

#run from the folder where your OH data is downloaded to

ls -d [0-9]* | while read dir; do

    # Print the directory/folder name you're investigating
    echo $dir

    # Check whether $dir/direct-sharing-396/ exists, and if so, cd into it
    if [ -d "$dir/direct-sharing-396/" ]; then
        cd $dir/direct-sharing-396/

        # exit the script right away if something fails
        set -e

        # unzip each .zip file into a directory of the same name
        ls *.zip | sed "s/.zip//" | while read zipfile; do
            echo $zipfile
            unzip -o -d $zipfile $zipfile.zip >/dev/null

            cd $zipfile

            # if the BgReadings.json file exists, use jq to extract the date and value keys from it
            if [ -f "BgReadings.json" ]; then
               jq -r '.[] | [.date, .value] | @csv' BgReadings.json > BgReadings.csv
            fi

            # use https://www.npmjs.com/package/complex-json2csv to convert all remaining files to CSV
            # syntax is: complex-json2csv inputfile.json > outputfile.csv
            ls *.json | while read jsonfile; do


                # if the file is a BgReadings.json file, skip it
                if [ $jsonfile = "BgReadings.json" ]; then
                    echo -n ""
                else
                    complex-json2csv $jsonfile > ${jsonfile%.json}.csv
                fi
            done

            cd ..

        done

        cd ../..

    else
        echo "No direct-sharing-396 folder found"
        continue
    fi
done
