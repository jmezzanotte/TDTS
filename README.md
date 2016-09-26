# Thinking, Doing, Talking Science 
This repo contains several programs I wrote to automate several survey adminstration tasks on a research and evaluation project I served on. There are 3 scripts (note, some code has been changed or removed to clear any identifying information, however, these modification do not affect the integrity of the code.): 
- tdts_trainer_survey_analysis.do
- tdts_tcr_sch_region_master.py 
- tdts_response_rates.do   

#Written-by : 
John Mezzanotte

#Date Written:
7-20-2016

#Stata Script 1
Stata script to automate the analysis of a trainer survey. The survey was taken by school officials who were training staff members on a school science program our project was doing a study on. The survey being analyzed was taken by those trainers. The survey same survey was given at different points in time, so I wrote a Stata script that would take in the survey data from any time point and run the same analysis. The script also returns formatted output to the user as a .xlsx file.

#Sample Output from Stata Script 1
I have provided a file called "tdts_demo_output.xlsx" to demonstrate what the file analysis files look like. Note, the 
data in this demo will not make sense. This is because I purposely distorted the numbers to the data from the real analysis files. This file is just meant to show how the analysis output is structured by the script.


#tdts_tcr_sch_region_master.py
Python script written using Pandas,  to append and merge several demographic files into a single master dataset. 

#tdts_response_rates.do 
Stata script to calculate response rates from output generated by Survey Gizmo. The script calculates response rates by school as well as school district(region) and produces a clean formatted output file.

#tdts_response_rates_sample_output.xlx
This file provides an example of the output produced by the tdts_response_rates.do script.
