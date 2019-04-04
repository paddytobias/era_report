# eRA monthly report builder

A program written in R to create monthly reports of eResearch Analyst activities for the benefit of reporting to members.

![report_example](img/report_example.png)

## Standard execution
Standard execution:

```cd R/
Rscript era_report.R
```

The program will run looping over all eRAs and generating a report for each. The reports are created for the previous month of work.

### Optional first and second arguments

```cd R/
Rscript era_report.R MM YYYY
```

The program can take arguments for a specific month and year for the specific month you want the report to capture. This ability means that the program can be run retrospective or, e.g., even in a loop of months across a whole year. 

### Optional third argument

You can also give a third argument which is optional, if you want to run the script for just one person. This is how it would look:

```cd R/
Rscript era_report.R MM YYYY era@intersect.org.au
```


## Using your calendar
Please read the advice on using your calendar before doing anything else: [calendar_advice](https://github.com/paddytobias/era_report/blob/master/calendar_advice.md)

## Want to be a part of this?
For all other variables (e.g., your name, institution, etc), the program goes off an authority file on Intershare. Please make sure you have updated your details [there](https://docs.google.com/spreadsheets/d/1G2YadcphdT1xkf6VJLiF-zvaLYd3a113avNJCMsB930/edit?usp=sharing).

## Configuration
If you are going to be the designated "report runner", there's a few things you'll need to do to get set up.

* Clone this repository
* Make sure you have all the required packages, including the correct versions. All dependencies are in `set_up.R`
* Make sure to go through the authentication process below.
* Finally ensure you have added anyone needing a report to your Google Calendar, so they are visible to you.

### For the Google API authentication
1. Go to [console.developers.google.com](console.developers.google.com) and create a Project (top drop-down)
2. Go into the project and click on `Enable APIs and Services`
3. `Enable` the `Google Calendar API`, `Gmail API`, `Google Sheets API` and `Google Drive API` for this Project
4. Back at the dashboard, go to `Credentials` and click on `Create credentials` and select `Create OAuth client ID`
5. Select `Other`.
6. Fill in the details for `Name`.
7. You'll be presented with the OAuth client id and secret. Just press "OK"
8. Go to the credentials just created in the list and click on the download symbol. Download this file to the `era_report` directory and make sure its name starts with `client_secret`.

## First time running the report
You will have to interactively authenticate the program the first time you run it. This effectively just means that you have to press a few buttons in the web browser as it pops up.

To do this, run:
`Rscript authing.R`

## Running the report builder each month
* Navigate to the `R/` directory holding the program in the terminal
* Then run the [standard execution](#standard-execution) for the `era_report.R` script.

If you wish to set this up as a cron job, then you can use the `run_report.sh` script. Running this script will record the time for each runs in `log.txt`.

## History of the program
2.0 now does this for all eRAs and adds the monthly events to a running datasheet that can be used for MVR quarterly and annual reports. 1.0 was designed to only run for one eRA at a time.

Both 1.0 and 2.0 can be run the same way.


---

## Trouble shooting
* Getting ```Error in httpuv::startServer(use$host, use$port, list(call = listen)) :
Failed to create server``` - this most likely means that you have a zombie port that's open. The Google API relies on talking to port 1410. To kill this zombie port: run `sudo lsof -i :1410` to see which port is open, then run `kill $(lsof -t -i :1410)` to kill it.
