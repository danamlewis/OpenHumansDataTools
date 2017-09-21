# Description of the four data type files and what they may or may not contain

## Four types of files from Nightscout

There are 4 kinds of data files that are available in the Nightscout and/or OpenAPS Data Commons, with Nightscout as the data source:

•	Profile

•	Entries

•	Device status

•	Treatments

### Profile 

This is the Nightscout profile that people can fill in. It is mostly used to VISUALIZE only in NS, i.e. draw the lines where basal rates are. It is not used in calculations for DIY closed loops. (Although, you can use it as a reasonable proxy for background settings – but be aware DIY loopers are probably using autotune and other tools and adjusting these, so don’t overly rely on this for accurate info about baseline settings).

**Note**: everyone’s profile, because they have different named entries for various Profile categories, i.e. Sarah’s Basal Profile, will have different headers.

![Example profile file](https://github.com/danamlewis/OpenHumansDataTools/blob/master/Examples/Example_Nightscout_profile.png)

### Entries
This is the core file where BG (blood glucose) values are. Anyone with Nightscout will have data in this file. BG data points usually are every 5 minutes or so.

![Example of entries file - basic BG and timestamp](https://github.com/danamlewis/OpenHumansDataTools/blob/master/Examples/Example_Nightscout_entries.png)

### Device status
For individuals with DIY closed loops, these will be big files, and contain information about what the system knows; what it is calculating will happen in the future; and what the system is recommending/trying to do. This data is very rich.

![Example of device status file with looper data](https://github.com/danamlewis/OpenHumansDataTools/blob/master/Examples/Example_Nightscout_devicestatus_looper.png)

**Note**: because the data is so rich, and so varied, headers in the columns in these files will vary individual to individual, (and based on the splitter we have to use to make these files open-able, might even vary within an individual’s multiple device status files). However, you should be able to write a script to grep for the headers once you know what they’re likely called, and pull them together in an easier format. 

For individuals without DIY closed loops, this file may be empty, or have a tiny bit of data – that’s usually individuals using xdrip(+), which are flavors of DIY CGM receivers/collectors. It’s usually xdrip or uploader battery status.

![Example of device status file for a non-looper; likely xdrip or rig uploader battery status](https://github.com/danamlewis/OpenHumansDataTools/blob/master/Examples/Example_Nightscout_devicestatus_xdrip.png)

### Treatments
This data will vary person to person based on what kind of info they log in Nightscout. You can see there are a variety of treatments that can be logged:

![List of treatment type possibilities](https://github.com/danamlewis/OpenHumansDataTools/blob/master/Examples/Example_Nightscout_treatment_types.png)

You can also filter for these in Excel, to make it easier to highlight the data for each of these categories.

![Example of filtered treatments file looking at Exercise treatments only](https://github.com/danamlewis/OpenHumansDataTools/blob/master/Examples/Example_Nightscout_treatment_types_filter_exercise.png)
