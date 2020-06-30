# ChimerMarker output parser

Simply clone this repository into "M:\CHIMERMARKER\" to restore

This is a single script (chimerparse.R) which takes the .xlxs export from ChimerMarker and parses it into a simplified table with the key information.

This is done through the Extraction ID value found in the file and searching specific rows that occur after the Extraction ID. 

The basic table produced can then be uploaded into the FileMaker LIMS.

The "Master Workbook" must contain the word "workbook", and the other patient report files must have a dash "-" in them.

### Requires R (currently installed on the LMH M: drive)

For Windows, this can be found at https://cran.r-project.org/bin/windows/base/

Installed within the "ChimerMarker" folder

### How to run

1) Clone the repo to a local directory which can access R


```git clone https://github.com/Callum-Rakhit/Automated_Chimermarker_Processing.git```


2) Add the files to be processed into the “Place_your_files_in_here” folder.

3) Click the "ClickMe.cmd" file.

4) Processed output will appear in folder




This runs the chimerparse.R script on the input files placed in the "Place_your_files_in_here" folder

These locations are hard coded.
