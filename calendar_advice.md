# Getting the most out of your calendar
The report harvests all the events out of your calendar, so, obviously, if you don't use your calendar very much, then your reports are going to look pretty bland. 

It's recommended to get into the habit of using your calendar for more than just scheduling meetings. Instead, record *all* of your day's activities. Even basic tasks like `replying to emails` should be in your calendar. 

From my experience this approach won't just benefit your monthly reports but will help to structure your day - which is always a bit of a challenge in the eRA role. 

I would also recommend entering your calendar events on a daily basis, just to stay on top of them.

## Event title syntax

The scripts understand a few syntax features in the calendar title that allow you to classify activities and specify who the activities was with or for. 

To start with classifying calendar events:
* **Tagging calendar entries** - It can be helpful to categorise your events with a handful of "tags". This helps the aggregations in the report. To do this, in the title of the calendar event, prepend the `tag` name, followed by a `:` then the name of the event. For e.g., `Replying to emails` I would class under `Admin` so I would enter it into the calendar as `Admin: Replying to emails`. In the script, anything before the `:` will be used as the tag name. *See eRA work ontologies below for accepted codes to use*. There is a [little Chrome extentions you can install](https://chrome.google.com/webstore/detail/google-calendar-tags/ncpjnjohbcgocheijdaafoidjnkpajka/) that will help to render this tagging nicely in Google Cals.
* **Assigning an event contact** - Sometimes you will be doing a task for a particular person at your desk and you want their name to appear in the monthly report, but it wouldn't make sense to invite them to the calendar event (because it's not a meeting!). Well, to denote a contact for the activity, add their name to the end of the event title, separated by a `$`. For e.g., I am putting together a report for the DVCR, then I would enter this into the calendar as `Preparing report$DVCR`. If there is no invited person to this event (i.e., it's not a meeting), then whatever is on the righthand side of the `$` will be used as the name of the contact in the report. 

So to recap, the syntax that should be used in your calendar is `[[Tag]]: [[Event Name]]$ [[Contact name (Optional)]]`

## eRA work ontologies and codes


* `RS` or `Research Support` or `Researcher Support` -  any direct work you are doing for or with a researcher
* `SP` or `Strat & Planning` - any high-level reports or analysis you are doing for the university
* `Eng` or `Engagement` - any presentations to a broad audience (not training) or meetings with prospective clients
* `T` or `Training` - all the training you do, including preparation time
* `Me` - personal things like taking leave
* `Admin` - admin tasks like replying to emails, cleaning your desk 
* `Int` or `Intersect` - tasks for Intersect, like MVRs, weekly meetings and TFTF, conducting training at other universities


<a href="https://docs.google.com/spreadsheets/d/e/2PACX-1vQkCcEnzws7OQEydNWCLqhD_vMcXkVUxpMu4dtlXYtpUKzvkhKhUdk_B0ETVoUNChHaQVUjY6_nbZug/pubchart?oid=1344834922&amp;format=interactive"><img src="https://docs.google.com/spreadsheets/d/e/2PACX-1vQkCcEnzws7OQEydNWCLqhD_vMcXkVUxpMu4dtlXYtpUKzvkhKhUdk_B0ETVoUNChHaQVUjY6_nbZug/pubchart?oid=1344834922&amp;format=interactive" width="600" height="371" seamless</a>

**Note: Please use the abbreviations where possible to minimise spelling errors in names and therefore inconsistent data in the reports.**
