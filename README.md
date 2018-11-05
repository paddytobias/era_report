# eRA monthly report builder

A program written in R to create monthly reports of eRA activities for the benefit of reporting to members. 

The program will create a report based on your calendar events for a specific month. You can give it the month and/or year to report on (e.g., `Rscript era_report.R 07 2018`) or you can use the default (`Rscript eRA_report.R`), which will produce you a report for the month previous from when you run the script.

## Process
This program will:
1. *Take a designated date*. System date is default unless you give it one when calling the script
2. *Create a report*. It will copy from the Google Sheets [template](https://docs.google.com/spreadsheets/d/1VnKspMIR4UgXpV3ZfssZaSQkMUcY_GS96vHGrFHnvWw/edit?usp=sharing) or write over the top of an existing report (produced if you have run the script for this month before)
3. *Access your calendar*, grabbing all events in your Intersect (Gmail) calendar for that month
4. *Fill the report*, inserting all events data into the preformatted Google Sheets 

## Running the script
It is possible to just run `Rscript eRA_report.R`, as long as you want the report generated for the previous month. Otherwise, you can give it month and/or year arguments for the month that you want to report on (e.g., `Rscript eRA_report.R "07" "2018"`).

## Set up (do this before anything else)

Clone this repo: `git clone https://github.com/paddytobias/era_reports`

### Install packages
There's a few dependences for this script. You'll need to install all by running `Rscript set_up.R`

### Config file
Make sure you fill in all the fields in `config.R`, including the unique id of the folder on Intershare you want the report to be placed.

For the Google API credentials, see the instructions below.

### For the Google API authentication
1. Go to [console.developers.google.com](console.developers.google.com) and create a Project (top drop-down)
2. Go into the project and click on `Enable APIs and Services`
3. `Enable` both the `Google Calendar API` and `Google Drive API` for this Project
4. Back at the dashboard, go to `Credentials` and click on `Create credentials` and select `Create OAuth client ID`
5. Select `Web application`. (you may have to set up the OAuth consent screen first, basically just give it a product name)
6. Fill in the details for `Name` and `Authorised redirect URI`. The latter must be `http://localhost:1410/`
7. You'll be presented with the OAuth client id and secret. Copy and paste these into the `gcal_tokens.R` file for the relevant variables. 
8. Finally enter your email address into `gcal_tokens.R`

## Trouble shooting

* Getting ```Error in httpuv::startServer(use$host, use$port, list(call = listen)) : 
Failed to create server``` - this most likely means that you have a zombie port that's open. The Google API relies on talking to port 1410. To kill this zombie port: run `sudo lsof -i :1410` to see which port is open, then run `kill $(lsof -t -i :1410)` to kill it. 
