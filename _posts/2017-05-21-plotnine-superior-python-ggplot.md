---
title: "Plotnine is the best Python implementation of R's ggplot2"
author: "Paul Teehan"
date: "May 21, 2017"
layout: post
---

Longtime R users who move to Python acutely feel the loss of R's [ggplot2](http://ggplot2.tidyverse.org/index.html) plotting library, which is unmatched in fluidity and expressiveness in the data science community.  Contenders like [Altair](https://altair-viz.github.io/), [Seaborn](https://seaborn.pydata.org/), [Bokeh](http://bokeh.pydata.org/en/latest/), [plot.ly](https://plot.ly/python/), and [Matplotlib](https://matplotlib.org/) all have plenty to offer, but for rapid exploratory visualization none are a perfect replacement, either due to lack of maturity as in Altair, a focus on lower-level APIs as in Seaborn and Matplotlib, or optimizing for different use cases as in plot.ly and Bokeh.  (Here's a [great article](https://dsaber.com/2016/10/02/a-dramatic-tour-through-pythons-data-visualization-landscape-including-ggplot-and-altair/) summarizing some of these differences.)  
![png]({{site_url}}/images/output_7_0.png)
----

ggplot is a rewarding library to use, because it allows you to construct plots using a high-level grammar without thinking about the implementation details.  As you master it, it fades away, until you are interacting directly with your data.  No one library in Python achieves this, though Altair might in its next major release.  Until then, Python users are forced to carry the extra cognitive load of learning several visualization libraries, learning their implementation details, and working around their limitations.

[yhat's Python port of ggplot](http://ggplot.yhathq.com/) (originally also named ggplot and since renamed ggpy) has promised to fill this gap, but personally I find it frustrating to use due to subtle API differences, missing features, and occasional bugs, which serve to create more cognitive load and erase the benefits of the ggplot grammar.  Recently, a new library called [plotnine](https://github.com/has2k1/plotnine) was announced, written by Hassan Kibirige, which is also a Python port of ggplot and appears to offer a more complete and robust implementation.  I'm very excited about plotnine, because so far it seems to match the functionality of R's ggplot very well.

In this notebook I've done a quick comparison of R's ggplot, yhat's ggpy, and plotnine, to show how the three libraries differ in their APIs and their outputs.  This is a quick illustrative comparison only, and it already exposes some issues with ggpy, and shows good results from plotnine.  For new Python users coming from an R background looking to replace ggplot, I recommend plotnine!

# Facetted geom_point

First we'll try a basic facet_wrap plot.  Here's R's ggplot2:


```python
%load_ext rpy2.ipython
%R require(ggplot2)
```


```python
%%R 
ggplot(mtcars, aes(x=hp, y=wt, color=mpg)) + geom_point() + facet_wrap(~cyl) + theme_bw()
```


![png]({{site_url}}/images/output_4_0.png)


Nice and clean, as usual.  Here's plotnine:


```python
from plotnine import *
from plotnine.data import *
```


```python
ggplot(mtcars, aes(x='hp', y='wt', color='mpg')) + geom_point() +\
facet_wrap("~cyl") + theme_bw()
```


![png]({{site_url}}/images/output_7_0.png)

    <ggplot: (8768644790853)>



A great plot, very clean.  As an R user, it worked exactly as I expected it would. I guessed the `facet_wrap("~cyl")` syntax on the first try.  The color scheme is the improved [viridis](http://bids.github.io/colormap/) scheme. 

Here's ggpy:


```python
from ggplot import *
```


```python
ggplot(mtcars, aes(x='hp', y='wt', color='mpg')) +\
geom_point() + facet_wrap("cyl", nrow=1) + theme_bw()
```


![png]({{site_url}}/images/output_10_0.png)

    <ggplot: (8768640840513)>



Already big problems!  First the facet_wrap syntax was different - "cyl" instead of "~cyl".  By default it produced two rows (two charts on top and one on bottom), but when I force it to one row, the legend gets screwed up.  The styling is less readable too, and the choices for y-axis labels are less appropriate.  

# Facet_wrap density plot

This one is also straightforward - a density plot, facetted on two variables, with free-floating y-axes.  (As an aside, here is a good example of the power of ggplot2.  It's a short one-liner, yet would be difficult to achieve in most Python plotting libraries.) 


```python
%%R 
ggplot(diamonds, aes(x=depth)) + geom_density() + facet_grid("cut~color", scales="free_y")
```


![png]({{site_url}}/images/output_13_0.png)


A great, readable graph, which makes it easy to compare the different series.

Here's plotnine's version of the same: 


```python
from plotnine import *
```


```python
ggplot(diamonds, aes(x='depth')) + geom_density() +\
facet_grid("cut~color", scales="free_y")
```


![png]({{site_url}}/images/output_16_0.png)

    <ggplot: (8768640644621)>



 Another great plot.  The text is a tad crowded, but still readable. 
 
 Finally, here's ggpy:


```python
from ggplot import *
ggplot(diamonds, aes(x='depth')) + geom_density() +\
 facet_grid("cut", "color", scales="free_y")
```


![png]({{site_url}}/images/output_18_0.png)





    <ggplot: (8768636221693)>



Disappointing.  Again I got tripped up by the API difference requiring seperate arguments in `facet_grid` and had to go look up the correct form, which would break my flow.  The plot has serious issues with the y axis labels; unlike plotnine's and R's ggplot, ggpy did not reuse the common axis and instead drew the y labels on each axes, sometimes with different tick marks and grid lines, and often crashing into the adjacent axes.  The result is a lot of visual noise.  Also, the baseline at y=0 is not drawn which I think takes away from the chart's impact.

# Stat_summary

One final example, this time using stat_summary:


```python
%%R
ggplot(aes(x=cut, y=carat), data=diamonds) + 
stat_summary(fun.y = median, fun.ymin=min, fun.ymax=max)
```


![png]({{site_url}}/images/output_20_0.png)



```python
from plotnine import *
import numpy as np
ggplot(aes(x='cut', y='carat'), data=diamonds) + stat_summary(fun_y = np.median, 
                                                              fun_ymin=np.min,
                                                              fun_ymax=np.max)
```


![png]({{site_url}}/images/output_21_0.png)

    <ggplot: (8768644797997)>



Again, plotnine's implementation is flawless.  

Here unfortunately we cannot complete the comparsion, because **ggpy does not include stat_summary**.   In fact, while plotnine currently implements seventeen of ggplot's `stat_` transformation functions, ggpy implements only three.  

# Conclusion

The choice is clear.  plotnine is a high-quality Python implementation of ggplot2, and after some quick experimentation, it appears the API and outputs closely match the R library, much more so than ggpy.  For Python users looking for a grammar of graphics plotting library, or especially for seasoned users of ggplot2 moving into the Python ecosystem, give plotnine a try.

