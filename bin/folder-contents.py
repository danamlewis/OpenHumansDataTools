# This script should be run from within a folder that contains project data from an Open Humans project. This expects there to be a list of folders named with the 8-digit project member ID. It looks in each numbered memberID folder; within the direct-sharing-* folder (there might be multiple based on the uploader types; and creates an output CSV file that lists the memberID and each individual file name. The script as written will place the output file on your Desktop; you may want to change the target location for the output CSV file.

import csv
import os

# get the path to the desktop
# NOTE: you may not want to store your output file on the Desktop; if so identify another location to place your output file
desktop_path = os.path.join(os.path.expanduser("~"), "Desktop")

# join the path to the desktop with the desired file name
output_path = os.path.join(desktop_path, "folder-contents-output.csv")
# open the output file for writing
with open(output_path, "w") as output_file:
  # create a CSV writer
  writer = csv.writer(output_file)
  
  # write the header row
  writer.writerow(["memberID", "data_file"])

  # loop through all the directories with 8-digit member IDs
  for member_dir in os.listdir():
    # check if the directory name is 8 digits
    if len(member_dir) == 8 and member_dir.isdigit():
      # enter the member ID directory
      os.chdir(member_dir)

      # loop through all the "direct-sharing-*" directories
      for data_sharing_dir in os.listdir():
        if data_sharing_dir.startswith("direct-sharing-"):
          # enter the data sharing directory
          os.chdir(data_sharing_dir)

          # loop through all the data files in the directory
          for data_file in os.listdir():
            # write the member ID and data file to the CSV file
            writer.writerow([member_dir, data_file])

          # go back to the member ID directory
          os.chdir("..")

      # go back to the parent directory
      os.chdir("..")
