suppressMessages(library(shiny))
suppressMessages(library(tseries))
suppressMessages(library(makeR))
suppressMessages(library(abind))
suppressMessages(library(png))
suppressMessages(library(ggplot2))
suppressMessages(library(quantmod))

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
      textInput("symbol1", "Symbol:", "MSFT"),
      selectInput("field1", "Field:",
                  c("AdjClose", "Close", "High", "Low", "Volume",
                    "ADX", "ATR", "Volatility"))
      ),
    
    wellPanel(
      helpText(HTML("<b>HEAT MAP TWO</b>")),
      textInput("symbol2", "Symbol:", "IBM"),
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
      HTML('Version 0.0.4'),
      HTML('<br>'),
      HTML('Deployed on 09-Apr-2014')
    ),
    
    wellPanel(
      helpText(HTML("<b>SOURCE CODE</b>")),
      HTML('<a href="http://bit.ly/github_rApps" target="_blank">Code on GitHub</a>')
    ),
    
    wellPanel(
      helpText(HTML("<b>ABOUT ME</b>")),
      HTML('Jo-fai Chow'),
      HTML('<br>'),
      HTML('<a href="http://bit.ly/jofaichow" target="_blank">www.jofaichow.co.uk</a>')
    ),
    
    wellPanel(
      helpText(HTML("<b>OTHER LINKS</b>")),
      HTML('<a href="http://bit.ly/blenditbayes" target="_blank">Blog</a>, '),
      HTML('<a href="http://bit.ly/github_woobe" target="_blank">Github</a>, '),
      HTML('<a href="http://bit.ly/linkedin_jofaichow" target="_blank">LinkedIn</a>, '),
      HTML('<a href="http://bit.ly/kaggle_woobe" target="_blank">Kaggle</a>, '),
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