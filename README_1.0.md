# eRA monthly report builder

A program written in R to create monthly reports of eRA activities for the benefit of reporting to members. 

The program will create a report based on your calendar events for a specific month. You can give it the month and/or year to report on (e.g., `Rscript era_report.R 07 2018`) or you can use the default (`Rscript eRA_report.R`), which will produce you a report for the month previous from when you run the script.

---
## Workflow Process
This program will:
1. *Take a designated date*. System date is default unless you give it one when calling the script
2. *Create a report*. It will copy from the Google Sheets [template](https://docs.google.com/spreadsheets/d/1VnKspMIR4UgXpV3ZfssZaSQkMUcY_GS96vHGrFHnvWw/edit?usp=sharing) or write over the top of an existing report (produced if you have run the script for this month before)
3. *Access your calendar*, grabbing all events in your Intersect (Gmail) calendar for that month
4. *Fill the report*, inserting all events data into the preformatted Google Sheets 
5. *Send out a notification email*, you have a choice to send an email to yourself and report stakeholder to let them know it's been completed (see `config.R`).

### Running the script
It is possible to just run `Rscript eRA_report.R`, as long as you want the report generated for the previous month. Otherwise, you can give it month and/or year arguments for the month that you want to report on (e.g., `Rscript eRA_report.R "07" "2018"`).

### Getting the most out of your calendar
The report harvests all the events out of your calendar, so, obviously, you don't use your calendar very much, then your reports are going to look pretty bland. 

I recommend getting into the habit of not just using your calendar for scheduling meetings, but to record *all* of your activities in the day. Even basic tasks like `replying to emails` should be in your calendar. From my experience this approach won't just benefit your monthly reports but will help to structure your day - which is always a bit of a challenge in the eRA role. 

I have added a few syntax features into the report build that allow you to classify activities and specify who the activities was with or for. To start with classifying calendar events:
* *Tagging calendar entries* - It can be helpful to categorise your events with a handful of "tags". These should be the common tasks of the eRA role (e.g., mine are: admin, engagement, training, stat&planning, researcher support, Intersect). This helps the aggregations on page 1 of the spreadsheet report. To do this, in the title of the calendar event, prepend the `tag` name, separated by a `:`. For e.g., `Replying to emails` I would class under `Admin` so I would enter it into the calendar as `Admin: Replying to emails`. In the script, anything before the `:` will be used as the tag name. Tip: best to stick to only a few tag names, otherwise they'll be come redundant in the report. There is a [little Chrome extentions you can install](https://chrome.google.com/webstore/detail/google-calendar-tags/ncpjnjohbcgocheijdaafoidjnkpajka/) that will help to render this tagging nicely in Google Cals.
* *Assigning an event contact* - Sometimes you will be doing a task for a particular person at your desk and you want their name to appear in the monthly report, but it wouldn't make sense to invite them to the calendar event (because it's not a meeting!). Well, to denote a contact for the activity, add their name to the end of the event title, separated by a `$`. For e.g., I am putting together a report for the DVCR, then I would enter this into the calendar as `Preparing report$DVCR`. If there is no invited person to this event (i.e., it's not a meeting), then whatever is on the righthand side of the `$` will be used as the name of the contact in the report. 

So to recap, the syntax that should be used in your calendar is `[[Tag]]:[[Event Name]]$[[Contact name]]`

---

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
3. `Enable` the `Google Calendar API`, `Gmail API` and `Google Drive API` for this Project
4. Back at the dashboard, go to `Credentials` and click on `Create credentials` and select `Create OAuth client ID`
5. Select `Web application`. (you may have to set up the OAuth consent screen first, basically just give it a product name)
6. Fill in the details for `Name` and `Authorised redirect URI`. The latter must be `http://localhost:1410/`
7. You'll be presented with the OAuth client id and secret. Copy and paste these into the `gcal_tokens.R` file for the relevant variables. 
8. Finally enter your email address into `gcal_tokens.R`

## Trouble shooting
* Getting ```Error in httpuv::startServer(use$host, use$port, list(call = listen)) : 
Failed to create server``` - this most likely means that you have a zombie port that's open. The Google API relies on talking to port 1410. To kill this zombie port: run `sudo lsof -i :1410` to see which port is open, then run `kill $(lsof -t -i :1410)` to kill it. 
