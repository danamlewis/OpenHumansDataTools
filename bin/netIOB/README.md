 # Insulin Data Processing and netIOB Computation

This repository contains a Jupyter Notebook that demonstrates how to:

1. **Ingest and clean insulin data** from two sheets (Basal and Bolus) in an Excel file.
2. **Chunk basal insulin records** into flexible intervals (≤ 6 minutes) to compute insulin amounts delivered during this time.
3. **Merge bolus data** with the chunked basal data and export the merged dataset to CSV.
4. **Generate daily basal profiles** (JSON) for use with netIOB calculations (because we don't have access to the user's profile values, and the profile may have changed throughout the dataset)
5. **Compute net Insulin On Board (netIOB)** for each 5‐minute row using [OpenAPS `oref0-calculate-iob`](https://github.com/openaps/oref0) scripts.

This example is for a Tidepool data export (xlsx) and a Tandem-based insulin pump. This can be extended for other data types as well and similarly, other formats of data in CSV or XLSX form.

Below is an overview of the key steps, dependencies, and usage instructions.

---

## Table of Contents
- [Background](#background)
- [Dependencies](#dependencies)
- [Notebook Workflow](#notebook-workflow)
  - [1. Ingest & Clean the Data](#1-ingest--clean-the-data)
  - [2. Chunk Basal Data into ≤6-Minute Intervals](#2-chunk-basal-data-into-6-minute-intervals)
  - [3. Merge Chunked Basal with Bolus Data](#3-merge-chunked-basal-with-bolus-data)
  - [4. Create Daily Basal Profiles (JSON)](#4-create-daily-basal-profiles-json)
  - [5. Install and Use `oref0` Scripts](#5-install-and-use-oref0-scripts)
  - [6. Compute netIOB for Each 5-Minute Record](#6-compute-netiob-for-each-5-minute-record)
- [Outputs](#outputs)
- [Notes and Troubleshooting](#notes-and-troubleshooting)

---

## Background

**Basal insulin** is usually recorded as a rate (units per hour), while **bolus insulin** is usually delivered at discrete time points (e.g., for meals or corrections). The goal of this workflow is to create a unified 5‐minute dataset of insulin delivery (both basal and bolus) and then compute how much insulin remains active in the body over time (Insulin on Board, or IOB). Specifically, we calculate the **netIOB** using [OpenAPS `oref0`][oref0-link] logic, incorporating day‐specific basal profiles. This is useful for evaluating **netIOB in systems that do not use netIOB.** 

[oref0-link]: https://github.com/openaps/oref0

---

## Dependencies

1. **Python 3.7+** with the following libraries:
   - `pandas`
   - `numpy`
   - `openpyxl` (for reading Excel files)
   - `datetime`
   - `json`
   - `math`
   - `subprocess`
   - `multiprocessing`
   
2. **Jupyter Notebook** (optional, but recommended) to run the `.ipynb` notebook interactively.

3. **Node.js** (required by `oref0-calculate-iob`):
   - Version 10–16 is recommended by `oref0`, but newer versions _may_ work.
   - You can check your version with `node -v`.

4. **OpenAPS `oref0`** scripts (specifically `oref0-calculate-iob.js`):
   - Cloned from [https://github.com/openaps/oref0](https://github.com/openaps/oref0).
   - The notebook automatically attempts `git clone https://github.com/openaps/oref0.git` into a local `oref0/` folder.
   - Install needed node dependencies in that folder with `npm install`.

---

## Notebook Workflow

### 1) Ingest & Clean the Data

- We read **basal** and **bolus** insulin records from an Excel file (`NAMED-FILE.xlsx`) containing two sheets:
  - **Basal** sheet
  - **Bolus** sheet
- The code selects the relevant columns from each sheet, converts timestamps to `datetime`, and ensures numeric columns (Rate, Duration, Normal) are correctly typed.
- The result is two cleaned `DataFrame`s: `basal_df` and `bolus_df`.

**Key variables:**
- `basal_sheet_name` (default `"Basal"`)
- `bolus_sheet_name` (default `"Bolus"`)

### 2) Chunk Basal Data into ≤6-Minute Intervals

- Basal insulin is often logged as a single entry with a given `Rate` (U/hr) and a `Duration (mins)`.
- To create a uniform time series, each record is **split** into smaller sub-entries such that each sub‐entry is no longer than 6 minutes. 
- This step computes:
  - **Chunk Duration (minutes)** = the original entry’s duration / number of chunks.
  - **Chunked “Amount”** of insulin in that chunk, derived as `Rate/60 * chunk_duration`.
  - The original `Rate` is labeled as `"Temp rate"` for reference.

A helper function `chunk_basal_flexible()` handles the splitting. The output is a new `DataFrame`, `chunked_basal_df`.

### 3) Merge Chunked Basal with Bolus Data

- **Bolus** data is left as-is, except we rename the `Normal` column to `Amount` and set `Duration (mins)` blank (since boluses are instantaneous).
- We **concatenate** `chunked_basal_df` and the renamed bolus `DataFrame`, sort by time, and reset the index.
- The merged dataset is then **exported to CSV**, e.g. `insulin_5min_merged-input-netIOB.csv`.

At this stage, you have a 5‐minute (or smaller) resolution dataset containing both basal and bolus records.

### 4) Create Daily Basal Profiles (JSON)

We then build daily basal profiles to feed into the netIOB calculation. 

Specifically:

1. **Filter** the merged dataset to keep only the basal rows.
2. **Group** by date (`Date`) and hour (`Hour`).
3. **Compute the average “Suppressed Rate”** per hour for each date.
4. **Forward‐fill and backward‐fill** any missing hourly rates so each day has a full 24‐hour profile.
5. Export each daily profile as a JSON file in the `daily_profiles` folder.

Each profile JSON file has the structure:

```json
{
  "dia": 5,
  "basalprofile": [
    {
      "i": <hour_index>,
      "start": "HH:00:00",
      "minutes": <hour_index * 60>,
      "rate": <average_rate>
    },
    ...
  ]
}
```

Note that in the original oref0 code, it uses a single `profile.json` file. Here, we are computing a profile for every single day (by observing the 'supressed' or scheduled basal rate throughout the data) and comparing the insulin delivered against the daily profile. This is a crucial step for being able to calculate netIOB. 

### 5) Install and Use oref0 Scripts

Code is included to check and see if you have the oref0 code downloaded so you can call this script.

- The Notebook clones the oref0 GitHub repo and checks for the existence of `oref0-calculate-iob.js`.
- It then performs an `npm install` to ensure you have required Node.js libraries (like `moment-timezone`).
- Important: If you use Node.js 18+ you may see warnings about unsupported Node versions. These warnings can often be ignored, but if you encounter errors, consider using Node.js 14 or 16.

### 6) Compute netIOB for Each 5-Minute Record
1.	We **read** the merged 5‐minute CSV.
2.	For each day:
- Build a “pump history” JSON by collecting events (basal chunks and boluses) from (**day_start - 24h) to day_end**.
  - The netIOB calculation looks backwards up to 24 hours.
- Sort the events in *descending order* (matching oref0 expectations) and save to a temporary file (e.g., pumphistory_YYYY-MM-DD.json). If you don't do **descending order**, it won't calculate correctly!
- Load the daily basal profile for that day (e.g., profile_YYYY-MM-DD.json).
- For each 5‐minute timestamp within the day, create a “clock” JSON file that sets the time reference for `oref0-calculate-iob`.
- Call `oref0-calculate-iob.js` with the pump history, the day’s basal profile JSON, and the clock file:
```
node oref0/bin/oref0-calculate-iob.js pumphistory_YYYY-MM-DD.json profile_YYYY-MM-DD.json clock.json
```
- Parse the output to extract the iob field. This is assigned as netIOB.

3.	Save partial day outputs to `partial_outputs/`, then merge all days into a final CSV (`insulin_5min_merged-output-with-netIOB.csv`).

## Outputs

1. **`insulin_5min_merged-input-netIOB.csv`**  
   Initial merged data with chunked basal and bolus records (5‐minute or smaller resolution).

2. **Daily Basal Profiles** in `daily_profiles/profile_YYYY-MM-DD.json`  
   Each file contains a JSON structure used by netIOB computations.

3. **`partial_outputs/` folder**  
   Intermediate CSV files for each day with computed `netIOB`.

4. **`insulin_5min_merged-output-with-netIOB.csv`**  
   Final dataset including a `netIOB` column.

---

## Notes

1. **Performance Considerations**  
   - For large datasets with thousands of rows per day, chunking basal data and computing netIOB can be time‐consuming.  
   - The notebook uses **multiprocessing** for netIOB computation. If you encounter memory issues, adjust your approach (e.g., process fewer days at once).

2. **Other Dependencies**  
   - Ensure pandas can read Excel files. If you see an error like  
     ```  
     ImportError: Missing optional dependency 'openpyxl'
     ```  
     install it with  
     ```bash
     pip install openpyxl
     ```  
   - If you see a similar issue with numpy, install via  
     ```bash
     pip install numpy
     ```
