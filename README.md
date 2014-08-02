rApps
=====

This is the repo for all my current and future R applications.

Current applications hosted on **ShinyApps**:  

1. [**CrimeMap**](http://bit.ly/bib_crimemap): UK Crime Data Visualisation
2. [**heatmapStock**](http://bit.ly/bib_heatmapStock): Stock Market Calendar Heat Map (Prototype)
3. [**Oddsimiser**](http://bit.ly/oddsimiser): Stakes Optimisation (Prototype)
4. [**rugsmaps**](http://bit.ly/rugsmaps): Maps of R User Groups Around the World

For latest updates, please check out my blog [**"Blend it like a Bayesian!"**](http://bit.ly/blenditbayes).  

## Crime Data Visualisation ([CrimeMap](http://bit.ly/bib_crimemap))

The maturality and extensive graphical abilities of *R* and its packages make *R* an excellent choice for professional data visualisation. Previous work has shown that it is possible to combine the functionality in packages **ggmap**, **ggplot2**, **shiny** and **shinyapps** for crime data visualization in the form of a web application named **'CrimeMap'** ([Chow, 2013](http://bit.ly/bib_crimemap)). The web application is user-friendly and highly customizable. It allows users to create and customize spatial visualization in a few clicks without prior knowledge in *R* (see screenshot below). Moreover, **shiny** automatcially adjusts the layout of **'CrimeMap'**  for best viewing experience on desktop computers, tablets and smartphones.

For the history and motivation behind the making of **CrimeMap**, please see my [**LondonR presentation**](http://bit.ly/londonr_crimemap).

<center>![crimemap](http://woobe.bitbucket.org/images/github/milestone_2013_11.jpg)</center>


## Stock Market Calendar Heat Map ([heatmapStock](http://bit.ly/bib_heatmapStock))

I recently discovered the [excellent Calender Heat Map example by Paul Bleicher](http://blog.revolutionanalytics.com/2009/11/charting-time-series-as-calendar-heat-maps-in-r.html), the related R package [makeR by Jason Bryer](http://jason.bryer.org/makeR/) and the [blog post by Timely Portfolio](http://timelyportfolio.blogspot.co.uk/2012/04/piggybacking-and-hopefully-publicizing.html). (Well, old news but I knew very little about R before 2013.)

I decided to create a **Shiny** web app to simplify the underlying process, thus allowing users to create heat map comparison with just a few clicks. Yet, this app relies heavily on many of the default settings in **makeR** which means I don't have the full control of graphics. In the future, I intend to experiment with **ggplot2**, **rCharts** as well as **rBlocks**.

<center>![hmStock](http://woobe.bitbucket.org/images/github/heatmapStock_github.png)</center>


## Oddsimiser 注碼優化器 ([oddsimiser](http://bit.ly/oddsimiser))

I created this for my friends in Hong Kong. It is a simple app for stakes optimisation based on genetic algorithm. Quick turnaround (a few seconds) is the main design focus so the optimisation outputs are not optimal but close enough for practical uses. Note that most instructions are written in Chinese.



## Maps of R User Group Around the World ([rugsmaps](http://bit.ly/rugsmaps))

**Note**: code at [github.com/woobe/rugsmaps](https://github.com/woobe/rugsmaps)

This shiny app is my submission to the [visualization contest](http://blog.revolutionanalytics.com/2014/06/contest-prizes-for-best-r-user-groups-plot.html) held by Revolution Analytics. The app is currently hosted on [blenditbayes.shinyapps.io/rugsmaps](https://blenditbayes.shinyapps.io/rugsmaps/). 

You can also run this app locally on your machine using the following code:

```
install.packages("shiny")
shiny::runGitHub("woobe/rugsmaps")
```

![rugsmaps1](https://raw.githubusercontent.com/woobe/rugsmaps/master/image/rugsmap_screenshot_01.png)

