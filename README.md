# qPCR

## How to run
*All steps are case-sensitive and space-sensitive so input carefully!*
### 1.) Fill in setup_info.csv in following format

Field | Entry
--- | ---
Filename | [name of file without extension]
Filetype | [extension type; can be "txt" or "xls"]
Housekeeping_Gene | [housekeeping gene name]
NTC_Designation | [What controls are called on the plate, ie. "ntc", "NTC", "NAC", etc.]
Sample_info | ["Y" if you're filling in sample_info.csv", "N" if not]
Treatment_Control_Designation | [if you filled in sample_info.csv, note what you called your control group, ie. "Control", "Ctrl", "No treatment", etc.]

#### Example setup_info.csv for "080822_GAPDH+IL6_qPCR.xls" file

Field | Entry
--- | ---
Filename | 080822_GAPDH+IL6_qPCR
Filetype | xls
Housekeeping_Gene | GAPDH
NTC_Designation | NTC
Sample_info | N
Treatment_Control_Designation | N/A
<br>
<br>
<br>

#### *Optional*

### 1.5) Fill in sample_info.csv in following format, if you want to; if you fill this out, make sure to put "Y" for "Sample_info" in setup_info.csv

Sample | Designation
--- | ---
[Sample 1] | [Treatment group]
[Sample 2] | [Treatment group]
[Sample 3] | [Treatment group]
... | ...

*Control treatment group must be same as written in setup_info.txt next to Treatment_Control_Designation field*

#### Example sample_info.csv for "080822_GAPDH+IL6_qPCR.xls"

Sample | Designation
--- | ---
Control 1 | Ctrl
Control 2 | Ctrl
LA 8-1 | Lead acetate
LA 2-1 | Lead acetate
LN 5-1 | Lead nitrate
LN 10-1 | Lead nitrate

*Note that since "Ctrl" is the designation given for the control group in the above sample_info.csv example, in setup_info.csv you would then put "Ctrl" for "Treatment_Control_Designation"* <br>
<br>
<br>
<br>
### 2.) Open qPCR_Analyzer and click "Source" to run; outputs created in new folder
