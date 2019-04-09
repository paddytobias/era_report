# Research Support scripts
By Dr Paddy Tobias, 2019

This program is intended to be run on a monthly basis *after* the monthly eRA report has been compiled. 

It uses the latest month's eRA report to collate all events with the *Research support* tag and formats them into rolling report called [Deakin Research Support](https://docs.google.com/spreadsheets/d/1BSzngasM_AYe54xZv6aqBu08_wE_Y_Jmnn9yGaYRL4o/edit#gid=2002578987)

Before inputting the data into Deakin Research Support, the program uses a Python2 script to conduct an LDAP lookup on individual researchers in order to collect school and campus information. 

** This is currently only available for Deakin because of the access to the LDAP directory ** 

## Set up
Prior to running the script for the first time, make sure you do the authentication process. First, you will need to create credentials for the Google APIs. Following [these instructions](https://github.com/paddytobias/era_report#for-the-google-api-authentication). Download the JSON file with the credentials and place it in the base directory. 

Then, run:

	`Rscript scripts/authing.R`

You will need to interactively authenticate with Google. 

## Program execution
Run the program on a monthly basis:

	`Rscript scripts/res_support_script.R`

