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

There are eight categories that we use to describe our work:
1. Research Support -  any direct work you are doing for or with a researcher
2. Strategy & Planning - any high-level reports or analysis you are doing for the university
3. Engagement - any presentations to a broad audience (not training) or meetings with prospective clients
4. Training - all the training you do, including preparation time
5. Administration - admin tasks like replying to emails, cleaning your desk 
6. Intersect-internal - tasks for Intersect, like events
7. Consortium - any work for the Intersect membership broadly, like MVRs, weekly meetings and TFTF, conducting training at other universities
8. Personal - personal things like taking leave

Click on the link below to see the accepted codes for assigning these categories.

<a href="https://docs.google.com/spreadsheets/d/e/2PACX-1vQkCcEnzws7OQEydNWCLqhD_vMcXkVUxpMu4dtlXYtpUKzvkhKhUdk_B0ETVoUNChHaQVUjY6_nbZug/pubchart?oid=1565865934&amp;format=interactive">Category ontologies</a>

