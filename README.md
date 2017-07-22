# OpenHumansDataTools

Tools to work with data downloaded from Open Humans research platform

## Tool #1: Unzip, split if needed based on size, and convert json to csv, and do it on a full batch of downloaded data from OH. 

[Unzip-Zip-CSVify-OpenHumans-data.sh](https://github.com/danamlewis/OpenHumansDataTools/blob/master/bin/unzip-split-csvify-OpenHumans-data.sh) Note that this tool was designed for use with the OpenAPS and Nightscout Data Commons, which pulls in Nightscout data as json files to Open Humans. Any users will need to specify the data file types for use in the second "for" loop. (The first for loop is Nightscout specific based on the data type, and uses an alternative json to csv conversion - see tips for other installation requirements).

See [these tips for help, especially related to the first for loop if you will be using entries.json from Nightscout](https://gist.github.com/danamlewis/aab795a7ec0bdd3abbb08b1f9be79663).

This script calls `complex-json2csv` and `jsonsplit.sh`. Both tools are in a package ([see repo here](https://github.com/danamlewis/json)) which can be installed by npm ([see this](https://www.npmjs.com/package/complex-json2csv)).

Progress output from the tool while running, with the script in current form, looks like:
```
########
########_entries.json
########_entries.csv
Starting participant ########
Extracted ########_profile.json; splitting it...
.
Grouping split records into valid json...
-
Creating CSV files...
=
Participant ########: profile CSV files created:       1
Extracted ########_treatments.json; splitting it...
..............
Grouping split records into valid json...
--------------
Creating CSV files...
==============
Participant ########: treatments CSV files created:      14
Extracted ########_devicestatus.json; splitting it...
...................................
Grouping split records into valid json...
-----------------------------------
Creating CSV files...
===================================
Participant ########: devicestatus CSV files created:      35
```

## Tool #2: Unzip, merge, and create output file from multiple data files from an OH download

[Unzip-merge-output.sh](https://github.com/danamlewis/OpenHumansDataTools/blob/master/bin/unzip-merge-output.sh)
Note that this tool was designed for use with the OpenAPS and Nightscout Data Commons, which pulls in Nightscout data as json files to Open Humans. Any users will need to specify the data file types for use in the second "for" loop, but can see this script as a template for taking various pieces of data from multiple files (i.e. timezone from devicestatus and BG data from entries) and creating one file, complete with headers, ready for data analysis.

Per the headers for the file provided as an example in this script, if needed, I have formulas created in excel to calculate if data is from a control or intervention period or neither; the hour of day the data is from to calculate if it is day or nighttime; and also (once looping start date manually added to file) can calculate number of days looping and number of days of data in the upload to calculate the control/intervention time frames based on the project protocol.
