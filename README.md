# OpenHumansDataTools

Tools to work with data downloaded from Open Humans research platform.

- [Tool #1: Unzip, split if needed based on size, and convert json to csv, and do it on a full batch of downloaded data from OH.](#tool-1-unzip-split-if-needed-based-on-size-and-convert-json-to-csv-and-do-it-on-a-full-batch-of-downloaded-data-from-oh)
- [Tool #2: Unzip, convert json to csv, on data from OH from the AndroidAPS uploader type.](#tool-2-unzip-and-convert-json-to-csv-on-data-from-oh-from-the-androidaps-uploader-type)
- [Tool #3: Unzip, merge, and create output file from multiple data files from an OH download](#tool-3-unzip-merge-and-create-output-file-from-multiple-data-files-from-an-oh-download)
- [Tool #4: Examples and descriptions of the four data file types from Nightscout uploader](#tool-4-examples-and-descriptions-of-the-four-data-file-types-from-nightscout)
- [Tool #5: Examples and descriptions of data structures from AndroidAPS uploader](#tool-5-examples-and-descriptions-of-data-structures-from-androidaps-uploader)
- [Tool #6: Pull ISF from device status](#tool-6-pull-isf-from-device-status)
- [Tool #7: Assess amount of looping data](#tool-7-assess-amount-of-looping-data)
- [Tool #8: Outcomes](#tool-8-outcomes)
- [Tool #9: Suite of glucose varability and demographics analysis scripts](#tool-9-gv-demographics-scripts)
- [Tool #10: Suit of glucose variability analysis scripts for assessing before and after (something)](#tool-10-gv-analytics-for-pre-and-post-analysis)
- [Tool #11: Python Scripts for Checking Between Different Versions of the OpenAPS Data Commons Dataset ](#tool-11-python-scripts-for-checking-between-different-versions-of-the-openaps-data-commons-dataset)

## Tool `#1`: Unzip, split if needed based on size, and convert json to csv, and do it on a full batch of downloaded data from OH. 

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

## Tool `#2`: Unzip and convert json to csv, on data from OH from the AndroidAPS uploader type

[unzip-csvify-AAPS-OpenHumans-data.sh](unzip-csvify-AAPS-OpenHumans-data.sh) checks for the existence of AndroidAPS uploader data (under direct-sharing396 folder, which is the Open Humans designation for this uploader project), unzips the files, puts the BG and timestamp in a simplified csv file (similar to "entries" from the Nightscout uploader type), and converts the remaining files into csv as well. Each .zip file remains, and a folder with the file name is created with all converted json and .csv folders below (see picture below for example). 

## Tool `#3`: Unzip, merge, and create output file from multiple data files from an OH download

[Unzip-merge-output.sh](https://github.com/danamlewis/OpenHumansDataTools/blob/master/bin/unzip-merge-output.sh)
Note that this tool was designed for use with the OpenAPS and Nightscout Data Commons, which pulls in Nightscout data as json files to Open Humans. Any users will need to specify the data file types for use in the second "for" loop, but can see this script as a template for taking various pieces of data from multiple files (i.e. timezone from devicestatus and BG data from entries) and creating one file, complete with headers, ready for data analysis.

Per the headers for the file provided as an example in this script, if needed, I have formulas created in excel to calculate if data is from a control or intervention period or neither; the hour of day the data is from to calculate if it is day or nighttime; and also (once looping start date manually added to file) can calculate number of days looping and number of days of data in the upload to calculate the control/intervention time frames based on the project protocol.

**Mock data in output file along with additional calculations for various variables as defined by a project protocol:**

![Example output file with mock data and formulas embedded for calculating these other fields](https://github.com/danamlewis/OpenHumansDataTools/blob/master/Examples/Example%20output%20file%20from%20unzip-merge-output.png)

## Tool `#4`: Examples and descriptions of the four data file types from Nightscout

[NS-data-types.md](https://github.com/danamlewis/OpenHumansDataTools/blob/master/NS-data-types.md) attemps to explain the nuances and what is contained in each of the four data file types: profile, entries, device status, and treatments. 


## Tool `#5`: Examples and descriptions of data structures from AndroidAPS uploader

Project members who have used the AndroidAPS uploader will have a different series of data files available, although similar data will exist. Depending on what stage of use someone is at (e.g. in "open loop" or early objective stage vs. an advanced user), they may not have all of the files described below.

**ApplicationInfo** - contains information about the version of AndroidAPS

**APSData** - contains information about algorithm predictions, calculations, and decisions. This is similar to "devicestatus" from the Nightscout uploader.

**BgReadings** - contains timestamps and BG value. This is similar to "entries" from the Nightscout uploader.

**CarePortalEvents** - contains information the user or system has entered as a CarePortal event.

**DeviceInfo** - contains information about the mobile device used

**DisplayInfo** - contains information about the size of the display 

**Preferences** - contains information about the preferences used within AndroidAPS. [See the AndroidAPS documentation on preferences](https://androidaps.readthedocs.io/en/latest/Configuration/Preferences.html) for more details about what each of those indicate and the available setting options.

**TemporaryBasals** - contains information about temporary basal rates that have been set. 

**TempTargets** - contains information about temporary targets that have been set.

**Treatments** - contains information about bolus calculations, boluses (manual or SMB), profile changes, etc. 

## Tool `#6`: Pull ISF from device status

Requires `csvkit`, so do `sudo pip install csvkit` to install before running this script. Also, it assumes your NS data files are already in csv format, using tool #1 [Unzip-Zip-CSVify-OpenHumans-data.sh](https://github.com/danamlewis/OpenHumansDataTools/blob/master/bin/unzip-split-csvify-OpenHumans-data.sh).

*Note: depending on your install of `six`, you may get an attribute error. 
Following [this rabbit hole about the error](https://github.com/wireservice/csvkit/issues/747), various combinations of solutions outlined in [this stack overflow article](https://stackoverflow.com/questions/29485741/unable-to-upgrade-python-six-package-in-mac-osx-10-10-2/29666702#29666702) may help.*

The [devicestatus-pull-isf-timestamp.sh](https://github.com/danamlewis/OpenHumansDataTools/blob/master/bin/devicestatus-pull-isf-timestamp.sh) script, when successful, pulls ISF and timestamp to enable further ISF analysis. 

Output file looks like this:
![Example of isf timestamp puller](https://github.com/danamlewis/OpenHumansDataTools/blob/master/Examples/Example_devicestatus_pull_ISF_timestamp.png)

## Tool `#7`: Assess amount of looping data

There are two methods for assessing amounts of data. 
* You can use [howmuchBGdata.sh](https://github.com/danamlewis/OpenHumansDataTools/blob/master/bin/howmuchBGdata.sh) to see how much time worth of BG entries someone has. However, this doesn't necessarily represent time of looping data.
* Or, you can use [howmuchdevicestatusdata.sh](https://github.com/danamlewis/OpenHumansDataTools/blob/master/bin/howmuchdevicestatusdata.sh) to see how much looping data (OpenAPS only for now; someone can add in Loop assessment later with same principle) someone has in the Data Commons.

Before running `howmuchdevicestatusdata.sh`, you'll need to first run [devicestatustimestamp.sh](https://github.com/danamlewis/OpenHumansDataTools/blob/master/bin/devicestatustimestamp.sh) to pull out the timestamp into a separate file. If you haven't, you'll need `csvkit` (see Tool #4 for details). **Also, both of these may need `chmod +x <filename>` before running on your machine.**

Output on the command line of `devicestatustimestamp.sh`:
![Example from command line output of devicestatustimestamp.sh](https://github.com/danamlewis/OpenHumansDataTools/blob/master/Examples/Example_command_line_devicestatustimestamp.sh.png)

Then, run `howmuchdevicestatusdata.sh`, and the output in the command line also shows which files are being processed:
![Example from command line output of howmuchdevicestatusdata.sh](https://github.com/danamlewis/OpenHumansDataTools/blob/master/Examples/Example_command_line_howmuchdevicestatusdata.sh.png)

The original output of `howmuchdevicestatusdata.sh` is a CSV. 
* Due to someone having multiple uploads, there may be multiple lines for a single person. You can use Excel to de-duplicate these.
* Loop users (until someone updates the script to pull in loop/enacted/timestamp) will show up as 0. You may want to remove these before averaging to estimate the Data Commons' total looping data.

![Example CSV output of howmuchdevicestatusdata.sh](https://github.com/danamlewis/OpenHumansDataTools/blob/master/Examples/Example_CSVoutput_howmuchdevicestatusdata.sh.png)

#### TODO for Tool 7: 
1) add Loop/enacted/timestamp to also assess Loop users
2) add a script version to include both BG and looping data in same output CSV)

## Tool `#8`: Outcomes

This script ([outcomes.sh](https://github.com/danamlewis/OpenHumansDataTools/blob/master/bin/outcomes.sh)) assess the start/end of BG and looping data to calculate time spent low (default: <70 mg/dL), time in range (default: 70-180mg/dL), time spent high (default:>180mg/dL), amount of high readings, and the average glucose for the time frame where there is entries data and they are looping. 

*Tl;dr - this analyzes the post-looping time frame.*

## Tool `#9`: GV Demographics scripts

[This folder](https://github.com/danamlewis/OpenHumansDataTools/blob/master/bin/GV-demographics-scripts/) contains a variety of notebooks and other scripts for analyzing glucose variability and performing analysis of demographics, such as within the OpenAPS Data Commons. Note: This folder contains a separate license from the rest of this repository (which is MIT license), please make note of the license that applies to all files within this folder. 

These scripts were used within the paper, "Large-Scale Data Analysis for Glucose Variability Outcomes with Open-Source Automated Insulin Delivery Systems". [This paper is open access and can be read here](https://doi.org/10.3390/nu14091906). 

## Tool `#10`: GV Analytics for Pre and Post Analysis

[This folder](https://github.com/danamlewis/OpenHumansDataTools/tree/master/bin/GV-pre-post-analysis) contains multiple notebooks with scripts for analysing glucose variability for before/after a change, such as a new onset medication that someone wants to assess GV-related changes for following commencement. Note: This folder contains a separate license from the rest of this repository (which is MIT license), please make note of the license that applies to all files within this folder. 

## Tool `#11`: Python Scripts for Checking Between Different Versions of the OpenAPS Data Commons Dataset

There are two useful scripts that enable you to check between the latest version of the OpenAPS Data Commons dataset and the previous version you were working on. Running these two scripts allows you to generate a list of your current and/or the latest dataset and compare between them. This would then allow you to pull out only the files you didn't already have, saving you a lot of time by not downloading duplicate data that you may have already cleaned.

### folder-contents.py

The first, [folder-contents.py](https://github.com/danamlewis/OpenHumansDataTools/blob/master/bin/folder-contents.py), looks through a folder containing an existing version of the OpenAPS Data Commons (or any OH) dataset and outputs a CSV file with a list of the projectmemberID and any of the projectmemberID's file within the sub-folders of various direct-sharing uploaders. To run this script, `python ~/bin/folder-contents.py` from within the data folder (e.g. "OpenAPS Data Commons n=122"). 

This is what the output CSV file will look like:

![Example CSV output of folder-contents.py](https://github.com/danamlewis/OpenHumansDataTools/blob/master/Examples/Example-output-folder-contents-py-script.png)

### match-file-names.py

The second script, [match-file-names.py](https://github.com/danamlewis/OpenHumansDataTools/blob/master/bin/match-file-names.py), checks whether the list of projectmemberID and file name from the first file (typically using the previous script) matches any projectmemberID and file name found in the second file. It generates an output CSV (data-name-matches.csv) file that lists the projectmemberID, filename, and a column titled "Match?" which says "Yes" if they match and "No" if there is no match in the second file.

The expected use of this script is to check a newer, bigger file as the first input file against the second input file. This will tell you whether the content exist (Yes) in the smaller, older file or not (No). This would aid you in determining which files to then pull from the newer, larger dataset to append to your cleaned, existing older/smaller dataset.

To run this script:
`python ~/bin/match-file/names.py Input-File-1-Larger-Newest.csv Input-File-2-Smaller-Older.csv`

Note that it's looking for member_ID and data_file in input-file-1; and project_member_id, file_basename in input-file-2. If your input files are differently formatted, adjust accordingly.

This is what the output CSV file looks like. I've also added conditional formatting after opening the CSV file to identify those files not found in the previous version of the dataset:

![Example output of the match-file-names-py script](https://github.com/danamlewis/OpenHumansDataTools/blob/master/Examples/Example-output-match-file-names-py-script.png)

