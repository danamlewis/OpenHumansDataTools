# HypoGV 

The HypoGV repository (formal name `GV-Hypoglycemia`) contains a Python script for analyzing the impact of hypoglycemia events on glycemic variability for individuals living with insulin-requiring diabetes. The script processes continuous glucose monitor (CGM) data, detects hypoglycemic events, and calculates a set of glycemic variability metrics for periods before and after each event over different time periods.

The script uses the `cgmquantify` library to calculate various glycemic variability metrics including Time in Range (TIR), Time out of Range (TOR), standard deviation, Patient Glycemic Status (POR), J-index, Low Blood Glucose Index (LBGI), High Blood Glucose Index (HBGI), and Glucose Management Indicator (GMI).

The repo includes functions for preprocessing CGM data, detecting hypoglycemic events based on custom glucose level ranges, and calculating and summarizing glycemic variability metrics.

This tool is intended for researchers and others interested in understanding the impact of hypoglycemic events on glycemic variability in people with CGM data (focused on diabetes).
