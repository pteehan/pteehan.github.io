---
title: "Visualizing runs scored and allowed"
author: "Paul Teehan"
date: "January 23, 2016"
layout: post

---




![plot of chunk unnamed-chunk-2]({{ site.url }}/images/runs-scored-and-allowed-unnamed-chunk-2-1.png)
By looking at the distribution of runs scored and runs allowed, we can visuallly estimate the quality of a team and its liklihood of winning.  

--- 

I'm still thinking about the 2015 Toronto Blue Jays and how they went from mediocre to unstoppable following a few key trades.  This is the holy grail of team management, that every owner and manager in the game reaches for: improving the quality of the team.  Why did those trades make such a big difference?  Why did other trades have less of an effect?  To answer this question, we need to understand more about what we mean by quality.  And it turns out this is quite a rabbit hole. 

The trivial definition is that a high quality team is one that wins a lot, or, has a higher winning percentage.  This doesn't yield us very much insight, because we can only assess quality after the fact -- we can't know if a trade will improve the quality of a team until we see how many games they start winning.  But it is a good starting point from which to look at the data.  

Let's take a look at three teams from 2015: The Kansas City Royals, who were consistently good all year; the Miami Marlins, who were consistently bad; and the Toronto Blue Jays, who started off mediocre and finished strong.  What we're looking at is their winning percentage over the course of the 2015 season.  (I've removed the first 10 games since winning percentage is very unstable early on.)  If quality is consistent over the year, then what we should expect to see is winning percentage swinging up and down but gradually settling close towards the final number, where that final number is what we use to represent the team's quality. 

![plot of chunk unnamed-chunk-3]({{ site.url }}/images/runs-scored-and-allowed-unnamed-chunk-3-1.png)

Indeed there is a lot of bouncing up and down -- it almost looks like oscillations or ringing, which is an intriguing thought -- but in the case of KCA and MIA, the winning percentage doesn't change much after about fifty games into the season.  With TOR it's a different story.  Winning percentage trends upwards, implying a non-stationary process, i.e. something changed, as we expected.

What else can we look at besides wins?  There is a tremendous wealth of data available, but I'm going to keep it simple and introduce two new features: runs scored, and runs allowed.  These two features completely explain wins: you win if you score more runs than your opponent.  Simple enough.  I'm expecting to see some kind of shift or trend in Toronto's data here -- if they started winning more, then that means precisely that they started scoring more runs than their opponents.  Did they start scoring more runs, or allowing fewer runs, or both?  

The raw data is incredibly noisy.  I've done a 30-game rolling mean to smooth out the noise a bit, but that's also hiding a lot of the data, and that's going to turn out to be important.  Anyway, here it is:

![plot of chunk unnamed-chunk-4]({{ site.url }}/images/runs-scored-and-allowed-unnamed-chunk-4-1.png)

Now this is interesting.  Yes, Toronto's offence improved following the trades, and so did its defence.  But looking at this 30-game smoothed data, Toronto was, on average, dominating its opponents all season, outscoring them by a huge margin, despite winning only half their games up until game 100 or so. Were they just unlucky earlier in the season? Kansas City's average runs scored are only sightly above runs allowed, but there is a consistent gap between the two curves.  Remember this Kansas City team won the championship.  Perhaps consistency has something to do with it. 

In the next graphs I've split the season into two halves, and I'm plotting the distribution of runs scored and runs allowed.  I've also dropped Miami to focus in on Toronto and Kansas City.  What you would expect for a high quality team is that the runs scored curve is consistently to the right of runs allowed, because that means the odds are good that they would outscore their opponents, i.e. win.  

![plot of chunk unnamed-chunk-5]({{ site.url }}/images/runs-scored-and-allowed-unnamed-chunk-5-1.png)

Take a look at Toronto in the first half.  Earlier we saw that their average runs scored was much higher than their average runs allowed.  But using only the average masks the actual behavior, which is trimodal: sometimes they scored two or three runs, sometimes six or seven, and often ten or more.  At the same time they were allowing three to five runs in most games.  This means that every time time they scored less than three runs, which happened fairly often, they were likely to lose.   Kansas City, on the other hand, usually allowed only two or three runs in the first half, and were likely to win most of those games.  In the second half, Toronto pushed its runs allowed curve over to the left, and also increased the number of games where they scored more than two runs, which would have translated into many more wins.  

Let's look at the same data, but this time plotted as a head-to-head comparison of both teams:

![plot of chunk unnamed-chunk-6]({{ site.url }}/images/runs-scored-and-allowed-unnamed-chunk-6-1.png)

Who had the better offence?  Clearly Toronto.  The teams were closely matched most of the time, but Toronto had that extra ability to punch out ten or more runs from time to time.  Toronto had a slight edge in defense in the second half.  But Kansas City clearly had the better defence in the first. 

This is the beginning of an argument for using the distribution of runs scored and allowed as a way of assessing team quality and comparing teams.  Unfortunately, distributions are unwieldy to work with, so I'll be experimenting with ways to model the distributions and condense them to summary statistics.  There are already several ways of measuring team quality based on summary stats which I will compare against in subsequent posts. 
