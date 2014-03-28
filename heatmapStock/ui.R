library(shiny)
library(tseries)
library(makeR)
library(abind)
library(png)
library(ggplot2)
library(quantmod)

shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Stock Market Calendar Heat Map"),
  
  # Sidebar with controls
  sidebarPanel(
    
    wellPanel(
      helpText(HTML("<b>READY?</b>")),
      submitButton(HTML("<h4>Update Heat Maps</h4>"))
      ),
    
    wellPanel(
      helpText(HTML("<b>HEAT MAP ONE</b>")),
      textInput("symbol1", "Symbol:", "GOOG"),
      selectInput("field1", "Field:",
                  c("AdjClose", "Close", "High", "Low", "Volume",
                    "ADX", "ATR", "Volatility"))
      ),
    
    wellPanel(
      helpText(HTML("<b>HEAT MAP TWO</b>")),
      textInput("symbol2", "Symbol:", "YHOO"),
      selectInput("field2", "Field:",
                  c("AdjClose", "Close", "High", "Low", "Volume",
                    "ADX", "ATR", "Volatility"))
    ),
    
    wellPanel(
      helpText(HTML("<b>DATE SETTING</b>")),
      dateInput("start", "Start Date (YYYY-MM-DD):", value = "2009-01-01",
                min = "2000-01-01", max = Sys.Date() - 30),
      helpText(HTML("<b>Note</b>: only showing up to 6 years of records."))
    ),
    
    wellPanel(
      helpText(HTML("<b>COLOUR SETTING</b>")),
      selectInput("colour", "Colour Theme:",
                  list("Red to Blue" = "r2b",
                       "Red to Green" = "r2g",
                       "White to Blue" = "w2b"))
    ),
        
    wellPanel(
      helpText(HTML("<b>CREDITS</b>")),
      HTML('<a href="http://blog.revolutionanalytics.com/2009/11/charting-time-series-as-calendar-heat-maps-in-r.html" target="_blank">Original Code</a> by Paul Bleicher,'),
      HTML("<a href='http://jason.bryer.org/makeR/' target='_blank'> package 'makeR'</a> by Jason Bryer and"),
      HTML("<a href='http://timelyportfolio.blogspot.co.uk/2012/04/piggybacking-and-hopefully-publicizing.html' target='_blank'> blog post'</a> by Timely Portfolio.")
    ),
    
    wellPanel(
      helpText(HTML("<b>VERSION CONTROL</b>")),
      HTML('Version 0.0.2 (prototype)'),
      HTML('<br>'),
      HTML('Deployed on 28-Mar-2014'),
      HTML('<br>'),
      HTML('<a href="http://bit.ly/github_rApps" target="_blank">Code on GitHub</a>')
    ),
    
    wellPanel(
      helpText(HTML("<b>ABOUT ME</b>")),
      HTML('Jo-fai Chow'),
      HTML('<br>'),
      HTML('<a href="http://bit.ly/aboutme_jofaichow" target="_blank">About Me</a>, '),
      HTML('<a href="http://bit.ly/blenditbayes" target="_blank">Blog</a>, '),
      HTML('<a href="http://bit.ly/github_woobe" target="_blank">Github</a>, '),
      HTML('<a href="http://bit.ly/linkedin_jofaichow" target="_blank">LinkedIn</a>, '),
      HTML('<a href="http://bit.ly/kaggle_woobe" target="_blank">Kaggle</a>.'),
      HTML('<a href="http://bit.ly/cv_jofaichow" target="_blank">Résumé</a>.')
    ),
    
    wellPanel(
      helpText(HTML("<b>OTHER STUFF</b>")),
      HTML('<a href="http://bit.ly/bib_crimemap" target="_blank">CrimeMap</a>, '),
      HTML('<a href="http://bit.ly/rCrimemap" target="_blank">rCrimemap</a>.')
    ),
        
    width = 2
    
  ),
  
  # Main Panel
  mainPanel(plotOutput("heatmap"))
  
))