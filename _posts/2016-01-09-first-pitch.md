---
title: "First Pitch"
author: "Paul Teehan"
date: "January 9, 2016"
layout: post

---
![plot of chunk unnamed-chunk-4]({{ site.url }}/images/first-pitch-unnamed-chunk-4-1.png)
Starting off a series of posts about baseball with some visualizations of win-loss data.

---

Today I'm starting a new series of posts in which I visualize and analyze data from my lifelong favourite sport, Major League Baseball.  Baseball is a data scientist's dream.  Unlike real-time games like hockey or basketball, baseball occurs one play at a time, making it possible to precisely record everything that happens in a game in a condensed scoring notation, which provides a wealth of well-structured data.  (Chess is another good example of such a game.)

Thanks to the efforts of countless dedicated fans and archivists we have complete scoring data for every baseball game ever played -- 162 of them per team, per year, going back to the late 1800s.  There is a long tradition of using statistics in baseball to assess players and teams, with historically enshrined stats like batting average and earned run average part of the common fan's vocabulary.  A new field called ["sabremetrics"]( http://sabr.org/sabermetrics), defined as "the search for objective truth in baseball", has developed more sophisticated stats such as like wins-above-replacement and fielding-indepedent-pitching.  Since 2006, the technologically advanced PITCHf/x system has been deployed on the field to record fine-grained data about individual pitches, enabling rich analysis and rich visualizations which you can sometimes see on TV broadcasts.  What's not to love?

I'm starting small and simple with no particular goals, except I am a bit motiviated by having witnessed the sensational run my hometown Toronto Blue Jays pulled off in 2015 and I might give them some preferential treatment.  So far I'm just using win-loss records, courtesy of [retrosheet](http://www.retrosheet.org/); we will leave player data and pitch data till much later.  Here is every game played in the 2015 regular season:

![plot of chunk unnamed-chunk-2]({{ site.url }}/images/first-pitch-unnamed-chunk-2-1.png)

I've plotted wins above .500 over time.  Blue for teams above .500 and red for teams below.  You can see the dominant teams - KCA, the World Series champs, PIT, SLN, CHN, and hey, TOR didn't do too badly, if you ignore the first two-thirds of the season. You can also see it was a really rough year for OAK, PHI, and ATL. 

These kind of look like stock charts, huh?  Which means they are amenable to time-series analysis techniques.  More on this later. 

Let's take a closer look at Toronto, and this time, I'm going to plot their record from every season in franchise history, going back to the beginning at 1977.

![plot of chunk unnamed-chunk-3]({{ site.url }}/images/first-pitch-unnamed-chunk-3-1.png)

Many years of mediocrity.  It's been a long wait since the championship years of 1992 and 1993.  Fortunately things never got as bad as they were in the early years.  It's interesting to see that in terms of raw wins the 1985 and 1987 teams actually out-perform the champsionship teams of 1992 and 1993.  In terms of win-loss record, Toronto has never been as good as they were in 1985:

![plot of chunk unnamed-chunk-4]({{ site.url }}/images/first-pitch-unnamed-chunk-4-1.png)

Also interesting is the boom-bust cycle.  You can see several years where the team nose-dived in the latter third of the season, likely indicating some trade activity in which they dealt away their star players in favour of prospects with an eye to rebuilding.  It would be interesting to see the extent to which you can spot trade activity from the win-loss data alone. 

In the next post, I will dive into the games themselves and see what we can learn about the determinants of who wins and who loses.  Eventually, I'll attempt to build a reasonable probabalistic model of a game, starting simple and adding complexity over time.  If this works, it will open up some rich possibilities for analysis and let us answer questions about which team was better, which trade had the biggest impact, etc.  In the end, I may contribute a little objective truth of my own. 
