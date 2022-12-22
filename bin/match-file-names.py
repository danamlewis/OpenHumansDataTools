# This python script expects two input files to be piped in on the command line. For example, you would run `python match-file-names.py input-file-1.csv input-file2.csv`

# The script checks whether the list of projectmemberID and file name matches any projectmemberID and file name found in the second file. It generates an output CSV (data-name-matches.csv) file that lists the projectmemberID, filename, and a column titled "Match?" which says "Yes" if they match and "No" if there is no match in the second file.

# Expected use of this script is to check a newer, bigger file as the first input file against the second input file. This will tell you whether the content exist (Yes) in the smaller, older file or not (No). This would aid you in determining which files to then pull from the newer, larger dataset to append to your cleaned, existing older/smaller dataset.

# Note that it's looking for member_ID and data_file in input-file-1; and project_member_id, file_basename in input-file-2. If your input files are differently formatted, adjust accordingly.

import csv
import sys

# check if the correct number of arguments was provided
if len(sys.argv) != 3:
  print("Error: Please provide two input files (input-file-1.csv and input-file-2.csv)")
  sys.exit(1)

# open the output file for writing
with open("data-name-matches.csv", "w") as output_file:
  # create a CSV writer
  writer = csv.writer(output_file)
  
  # write the header row
  writer.writerow(["memberID", "data_file", "Match?"])

  # open the first CSV file for reading
  with open(sys.argv[1], "r") as input_file:
    # create a CSV reader
    reader = csv.reader(input_file)
    
    # skip the first row (header row)
    next(reader)

    # loop through all the rows in the first CSV file
    for row in reader:
      # unpack the member ID and data file from the row
      member_id, data_file = row
      # flag to track whether there is a match
      match = False
      
      # open the second CSV file for reading
      with open(sys.argv[2], "r") as second_file:
        # create a CSV reader
        second_file_reader = csv.reader(second_file)
        
        # skip the first row (header row)
        next(second_file_reader)

        # loop through all the rows in the second CSV file
        for second_file_row in second_file_reader:
          # unpack the project member ID and file basename from the row
          project_member_id, file_basename = second_file_row
          # check if the member ID and data file match the project member ID and file basename
          if member_id == project_member_id and data_file == file_basename:
            # write the member ID, data file, and "Yes" to the output file
            writer.writerow([member_id, data_file, "Yes"])
            # set the match flag to True
            match = True
            # exit the inner loop
            break
      
      # if there was no match, write the member ID, data file, and "No" to the output file
      if not match:
        writer.writerow([member_id, data_file, "No"])
