---
title: "Simulating seasons from run data"
author: "Paul Teehan"
date: "January 23, 2016"
layout: post

---




![plot of chunk unnamed-chunk-2]({{ site.url }}/images/simulating-seasons-from-run-data-unnamed-chunk-2-1.png)
By simulating seasons from existing data we see that Toronto was the best team in baseball in 2015.  This approach appears to outperform existing methods for win expectation.

In the [previous post](http://pltn.ca/runs-scored-and-allowed/) I plotted runs scored and runs allowed as distributions, and suggested that we could infer something about a team's likelihood of winning from these distributions. I'm going to develop that approach in this post, and compare against some other established methods for inferring likelihood of winning. 

The key assumption is that runs scored and runs allowed are both random quantities that are governed by some kind of underlying statistical distributions, and that if we understand these distributions, we understand some fundamental truths about the team.  I can state that more formally by defining *R* to be a random variable donating the number of runs scored per game for a team, and *A* a random variable denoting the number of runs allowed per game for a team.  Each random variable is governed by a statistical distribution.

We don't actually know what these distributions are, but we do know what happened in the 2015 season.  Here's what it looked like for Cincinatti and for Toronto:

![plot of chunk unnamed-chunk-3]({{ site.url }}/images/simulating-seasons-from-run-data-unnamed-chunk-3-1.png)

Those 162 games are like 162 samples from the underlying distributions of *R* and *A*.  If we squint we can imagine a smooth curve, or perhaps serveral overlayed curves, which is the key fundamental truth we are after: the "true" behavior underneath the randomness.  I am leaving the exploration of candidate mathmetical models for a future post.  

There is a critical question to be answered before we go any further: are these two variables, *R* and *A*, independent, or is there some correlation?  To answer this, we can plot runs scored and allowed against one another.  If they are correlated, we should see a diagonal shape, and if not, we should see a big splat:


![plot of chunk unnamed-chunk-4]({{ site.url }}/images/simulating-seasons-from-run-data-unnamed-chunk-4-1.png)

It looks pretty splattish to me, and, the mean correlation coefficient across all 2015 teams is 0.0336285.  This is very close to zero, so we can conclude that runs scored and runs allowed are not correlated, i.e. that they are independent processes.  In other words, the amount of runs a team scores in one game has no influence on the amount of runs they allow.  This is nice, because it makes the calculations easier.   One way to interpret this result is that runs allowed depends mostly on the opponents; the team's defense may shift the average tendancy up or down, but the result on any given day depends on how well their opponents are hitting.  

I'm going to develop my own metric, as followed.  First, we'll assume *R* and *A* are random variables that have the exact distributions as the record of the 2015 season -- in other words, we take what actually happened as a real measure of the team's offense and defense  -- but unlike the 2015 season in which specific values of *R* and *A* are paired together, we let these two variables float indepedently.  We take 162 samples of these variables to simulate a regular season and figure out the final winning percentage.  The result of this will be an alternate-universe version of what might have happened in the 2015 season had the dice landed differently.  We do this many times and eventually we see a range of outcomes.  The average winning percentage across all of these universes will be our new metric.

It's straightforward to do such a simulation -- we just build an empirical distribution from the 2015 data, sample it, and mark a win if *R* is greater than *A*.  One caveat: ties are not allowed in baseball, so if we land on a tie, we'll throw it away and try again.  Let's simulate 10,000 seasons from the 2015 data.  I'll mark a winning percentage of 0.5 with a dashed line, and the actual 2015 performance with a solid line.

![plot of chunk unnamed-chunk-5]({{ site.url }}/images/simulating-seasons-from-run-data-unnamed-chunk-5-1.png)

Very interesting!  The distributions all look identical, differing only in mean.  We can see whether a team was lucky or unlucky by looking at where their actual performance (solid line) falls in relation to the peak of the distribution.  Some teams performed near the expected average (BAL, ATL, PHI, SEA), some teams were unlucky and lost more games than they should have (TOR, MIL, COL) and some were lucky and won more than they should have (PIT, TEX, CHN).  Of course there are many factors that we haven't accounted for, notably that the distributions change throughout the year as the teams add and remove players, as I discussed in an earlier post.  I think home-field advantage is another factor we could pull out and improve the fidelity of our model.  Plus, we've not corrected for games that were not 9 innings long.  Still, this is pretty illuminating.  And it gives us some strong evidence that Toronto was the best team in baseball in 2015: 

![plot of chunk unnamed-chunk-6]({{ site.url }}/images/simulating-seasons-from-run-data-unnamed-chunk-6-1.png)

We can also see that Toronto was very unlucky in 2015, losing 8 more games than they would have won in an average season.  Oakland was the only team that was unluckier.

![plot of chunk unnamed-chunk-7]({{ site.url }}/images/simulating-seasons-from-run-data-unnamed-chunk-7-1.png)

In a way I've re-invented the wheel here.  There are already formulas for win expectation. The main formula in use is known as Pythagorean Expectation, after it's resemblence to the Pythagorean theorem: 

![Pythagorean Expectation](https://upload.wikimedia.org/math/b/0/d/b0da4b28fff6eb1edcdc59da5cff7934.png)

The gist is, you tally up total runs scored and total runs allowed throughout the season and use the above formula to estimate win percentage.  There are several variations in which the exponent differs; it's 2 above, 1.83 in another formulation, and in some cases it depends on runs scored and allowed again.  The [Wikipedia page](https://en.wikipedia.org/wiki/Pythagorean_expectation) has more, including some discussion on the meaning and theoretical justifications.  

I believe that my new method -- taking the mean of a large number of simulated seasons -- should be more accurate, because it uses more information than the Pythagorean expectation models.  We can test this by examining the error, ie. the difference between win expectation and actual performance, according to the various methods.  A good estimator should have zero average error (i.e. no systematic bias) and should have  root-mean-square error as small as possible.  I'm going to compare the simulated season approach with the basic Pythagorean Expectation formula with exponent 2, the same formula with exponent 1.83, and the "Pythagenpat" formula with an exponent that varies by team according to their runs scored and allowed.  



The mean errors are all close to zero, so each estimator is unbiased: 
[1] "sim: -0.00039;     py2: 0.00105;     py183: 0.00095;     pypat: 0.00068"

And the root-mean-square error for the simulated season approach is significantly less than all three Pythagorean expectation approaches:   

[1] "sim: 0.02582;     py2: 0.02947;     py183: 0.02822;     pypat: 0.02873"


The Pythagorean expectation method flattens the season's runs scored and allowed behavior into two single numbers -- total runs scored and allowed over the course of the season.  It drops all the information about the volatility or consistency of a team's offense or defense, and in fact it's remarkably accurate given how condensed it is.  When we use the entire distributions, we're better able to model the impact of random chance on a team's win-loss record, and this results in a reduction in prediction error.  And, I think we get something useful out of this approach: it's nice to be able to visually see the distributions and look at where a team could have landed in any particular season.

The simulated season approach is cumbersome and computationally expensive.  However, if we can replace the empirical distributions of runs scored and allowed with mathematical approximations, then there may the the possibility for a clean formulation, which could be very useful. I'll be exploring this in the next posts.
