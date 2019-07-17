# server_status
Shiny server monitoring app and log scraping script

The basic idea of the app is to read log files which are created by a chron-job that runs an R script (check_server.R). 

Usage:
1. Ensure you have a cron job running the check_server.R script. See below for instructions to set that up.
2. Shiny Server is running and has access to /srv/shiny-server/server_status
3. Access the app as you would any other shiny app.

All credit to the idea/concept and check_server.R script goes to this article https://www.rcharlie.com/post/shiny-monitor/
(explore that site, it's awesome!).


Running the job
  run the following command on your server:
    crontab -e
  then add the following to the job list: 
    * * * * *  sudo /usr/bin/Rscript /srv/shiny-server/server_status/check_server.R
  save the job list - fin.
  


