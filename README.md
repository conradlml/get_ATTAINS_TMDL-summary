# get_ATTAINS_TMDL-summary
Script to query TMDLs approved in Idaho by parameter of concern from EPA's ATTAINS database. The script only pulls ATTAINS TMDL data for the State of Idaho and is compatible with querying multiple parameters of concern at a time.  

# Background Information
EPA's ATTAINS database houses information related to all approved TMDLs. This script utilizes the rATTAINS package developed and supported by EPA. 

# Getting Started 
To get started, begin by specifying the user inputs listed at the top of the file: TMDL parameter(s) of interest, and your computer username. Be sure to follow the formatting guidelines provided within the script. The script will only work if you follow the format of the allowable values exactly (per the TMDL_parameters object), enclose each invidual parameter in quotation marks within the parenetheses, and separate multiple parameters by a comma. Once the user-specified inputs are provided, click on "Source" and watch the console to see if you run into any errors. If the script ran successfully, there will be an Excel file for each parameter in your Downloads folder. Within the Excel file, there will be several sheets: 
* __All TMDLS:__ a list of all approved TMDLs written to target the parameter of concern in Idaho with pertinent metadata (link to document, approval date, identifying code, approval letters, etc.).
* __All TMDLs + AUs:__ Approved TMDLs written to target the parameter of concern in with assessment units that were included. Please note that some retired assessment units may not be included in this list. 

Always verify the results of your outputs. 
