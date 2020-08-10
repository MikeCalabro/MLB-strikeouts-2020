# MLB-Strikeouts 2020

Re-creating an old project, equipped with new R and SQL skills

# What is this Repository?

The work in here showcases my attempt to investigate the drastic increase in Strikeouts in the MLB over the past 12 years.

# Important Files

**useful_charts.pdf - cleanly displays the most notable charts I created in journey_to_insight, along with new plots.
Each plot is linked to a specific hypothesis that I was looking into**.  
**Cleanliness - 9/10**  

**journey_to_insight.pdf - displays my process of looking through the data looking for trends.
Also provides better information on the Lahman Baseball Database, and my motivations throughout my Exploratory Data Analysis process.  
Cleanliness - 4/10**

# The Data

There are four sources of data in this repository:

1. lahmans_baseball_db.sqlite -  
contains season hitting and pitching [stats](http://www.seanlahman.com/baseball-archive/statistics/) for every MLB batter and pitcher from 1871-2019

2. fangraphs_batting.csv -  
contains advanced hitting stats for top MLB hitters from 2008-2019
Acquired from the [Fangraphs.com website](https://www.fangraphs.com/leaders.aspx?pos=all&stats=bat&lg=all&qual=y&type=8&season=2020&month=0&season1=2020&ind=0)

3. fangraphs_pitching.csv -  
contains advanced pitching stats for top MLB pitchers from 2007-2019
Acquired from the [Fangraphs.com website](https://www.fangraphs.com/leaders.aspx?pos=all&stats=pit&lg=all&qual=y&type=8&season=2020&month=0&season1=2020&ind=0&team=0&rost=0&age=0&filter=&players=0&startdate=&enddate=)

4. full_savant_data.csv -  
contains pitch by pitch data from May 1 - May 7 for every year from 2008-2019
includes exit velocity and launch angle data for batted balls from 2015-2019
Acquired from the [Baseballsavant.com website](https://baseballsavant.mlb.com/statcast_search), accessed via the baseballr R package
