# eRA monthly report builder

A program written in R to create monthly reports of eRA activities for the benefit of reporting to members. 

Standard execution: `Rscript era_report.R MM YYYY era@intersect.org.au`. The third argument is optional if you want to run the script for just one person. 

The program will create a report based on your calendar events for a specific month. You can give it the month and/or year to report on (e.g., `Rscript era_report.R 07 2018`) or you can use the default (`Rscript eRA_report.R`), which will produce you a report for the month previous from when you run the script.

1.0 is designed to only run for one eRA at a time. 2.0 now does this for all eRAs and adds the monthly events to a running datasheet that can be used for MVR quarterly and annual reports. 

Both 1.0 and 2.0 can be run the same way. 


## Using your calendar
Please read the advice on using your calendar before doing anything else: [calendar_advice](https://github.com/paddytobias/era_report/blob/master/calendar_advice.md)

## Configuration
For all other variables (e.g., your name, institution, etc), the program goes off an authority file on Intershare. Please make sure you have updated your details [there](https://docs.google.com/spreadsheets/d/1G2YadcphdT1xkf6VJLiF-zvaLYd3a113avNJCMsB930/edit?usp=sharing).


---

## Trouble shooting
* Getting ```Error in httpuv::startServer(use$host, use$port, list(call = listen)) : 
Failed to create server``` - this most likely means that you have a zombie port that's open. The Google API relies on talking to port 1410. To kill this zombie port: run `sudo lsof -i :1410` to see which port is open, then run `kill $(lsof -t -i :1410)` to kill it. 
