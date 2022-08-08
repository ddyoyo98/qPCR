# qPCR

## How to run
*All steps are case-sensitive and space-sensitive so input carefully!*
### 1.) Fill in setup_info.txt in following format
Field,Entry <br>
Filename,[name of file without extension] <br>
Filetype,[extension type; can be "txt" or "xls"] <br>
Housekeeping_Gene,[gene name] <br>
NTC_Designation,[What controls are called on the plate; "ntc", "NTC", "NAC", etc.] <br>
Treatment_Control_Designation,[relevant for sample_info.txt; what your control group is called; "Control", "Ctrl", etc.] <br>
Sample_info,["Y" if you're filling in sample_info.txt, blank if not] <br>
#### Example setup_info.txt for "qPCR_data.xls"
Field,Entry <br>
Filename,qPCR_data <br>
Filetype,xls <br>
Housekeeping_Gene,GAPDH <br>
NTC_Designation,NTC <br>
Treatment_Control_Designation,Ctrl <br>
Sample_info,Y <br>

### 1.5) Fill in sample_info.txt in following format; *Optional*
Sample,Designation <br>
[Sample 1],[Treatment group] <br>
[Sample 2],[Treatment group] <br>
[Sample 3],[Treatment group] <br>
... <br>
<br>
*Control treatment group must be same as written in setup_info.txt next to Treatment_Control_Designation field*
#### Example sample_info.txt for "qPCR_data.xls"
Sample,Designation <br>
a100,Ctrl <br>
a101,Ctrl <br>
a102,Ctrl <br>
a103,LPS <br>
a104,LPS <br>
a105,LPS <br>
a106,TCDD <br>
a107,TCDD <br>
a108,TCDD <br>
<br>
*Note that "Ctrl" is same treatment control designation as specified in setup_info.txt* <br>

### 2.) Open qPCR_Analyzer and click "Source" to run; outputs created in new folder