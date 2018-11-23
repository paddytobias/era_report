# eRA monthly report builder

A program written in R to create monthly reports of eRA activities for the benefit of reporting to members. 

The program will create a report based on your calendar events for a specific month. You can give it the month and/or year to report on (e.g., `Rscript era_report.R 07 2018`) or you can use the default (`Rscript eRA_report.R`), which will produce you a report for the month previous from when you run the script.

1.0 is designed to only run for one eRA at a time. 2.0 now does this for all eRAs and adds the monthly events to a running datasheet that can be used for MVR quarterly and annual reports. 

Both 1.0 and 2.0 can be run the same way. 

---

## Set up (do this before anything else)
Clone 2.0: `git clone https://github.com/paddytobias/era_reports`

### Install packages
There's a few dependences for this script. You'll need to install all by running `Rscript set_up.R`

### Config file
The progam used to use a local config file to set all the global variables. This still exists but is only used for holding the Google API ids (see below). 

For all other variables (e.g., your name, institution, etc), the program goes off an authority file on Intershare. Make sure you have updated your details [there](https://docs.google.com/spreadsheets/d/1G2YadcphdT1xkf6VJLiF-zvaLYd3a113avNJCMsB930/edit?usp=sharing).

### For the Google API authentication
1. Go to [console.developers.google.com](console.developers.google.com) and create a Project (top drop-down)
2. Go into the project and click on `Enable APIs and Services`
3. `Enable` the `Google Calendar API`, `Gmail API` and `Google Drive API` for this Project
4. Back at the dashboard, go to `Credentials` and click on `Create credentials` and select `Create OAuth client ID`
5. Select `Web application`. (you may have to set up the OAuth consent screen first, basically just give it a product name)
6. Fill in the details for `Name` and `Authorised redirect URI`. The latter must be `http://localhost:1410/`
7. You'll be presented with the OAuth client id and secret. Copy and paste these into the `gcal_tokens.R` file for the relevant variables. 
8. Finally enter your email address into `gcal_tokens.R`

## Trouble shooting
* Getting ```Error in httpuv::startServer(use$host, use$port, list(call = listen)) : 
Failed to create server``` - this most likely means that you have a zombie port that's open. The Google API relies on talking to port 1410. To kill this zombie port: run `sudo lsof -i :1410` to see which port is open, then run `kill $(lsof -t -i :1410)` to kill it. 
