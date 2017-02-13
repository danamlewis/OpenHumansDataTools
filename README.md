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
