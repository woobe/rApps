library(shiny)
library(tseries)
library(makeR)
library(abind)
library(png)
library(ggplot2)
library(quantmod)

shinyServer(function(input, output) {
  
  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Static Functions / Objects
  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  ## Blank Theme for ggplot2
  ## http://is-r.tumblr.com/post/32728434389/a-replacement-for-theme-blank
  new_theme_empty <- theme_bw()
  new_theme_empty$line <- element_blank()
  new_theme_empty$rect <- element_blank()
  new_theme_empty$strip.text <- element_blank()
  new_theme_empty$axis.text <- element_blank()
  new_theme_empty$plot.title <- element_blank()
  new_theme_empty$axis.title <- element_blank()
  new_theme_empty$plot.margin <- structure(c(0, 0, -1, -1), unit = "lines", valid.unit = 3L, class = "unit")
  
  ## Calculate Specific Index
  cal_idx <- function(df, name_idx) {
    data <- as.matrix(df[, -1])
    switch(name_idx,
           ADX = as.matrix(ADX(HLC(data))[, "ADX"]),
           ATR = as.matrix(ATR(HLC(data))[, "atr"]),
           Volatility <- as.matrix(volatility(data[,1:4], calc="garman"))
    )
  }
  
  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Reactive Functions
  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  ## Create Data Frame
  create_df1 <- reactive({
    
    ## Define date range
    start_date <- input$start
    start_year <- as.integer(substr(start_date, 1, 4))
    end_date <- paste0((start_year + 5), "-12-31")
    
    ## Download Data
    df <- get.hist.quote(
      instrument = as.character(input$symbol1), 
      start = start_date,
      end = end_date,
      provider = "yahoo",
      quiet = TRUE, 
      drop = TRUE, 
      retclass = "zoo",
      quote = c("Open", "High", "Low", "Close", "Volume", "AdjClose")
    )
    df <- as.data.frame(df)
    df <- data.frame(Date = rownames(df), df)
    
    ## Remove NAs
    rows_noNA <- which(rowSums(is.na(df)) == 0)
    df <- df[rows_noNA,]  
    
    ## Return
    df
    
  })
  
  ## Create Data Frame
  create_df2 <- reactive({
    
    ## Define date range
    start_date <- input$start
    start_year <- as.integer(substr(start_date, 1, 4))
    end_date <- paste0((start_year + 5), "-12-31")
    
    ## Download Data
    df <- get.hist.quote(
      instrument = as.character(input$symbol2), 
      start = start_date,
      end = end_date,
      provider = "yahoo",
      quiet = TRUE, 
      drop = TRUE, 
      retclass = "zoo",
      quote = c("Open", "High", "Low", "Close", "Volume", "AdjClose")
    )
    df <- as.data.frame(df)
    df <- data.frame(Date = rownames(df), df)
    
    ## Remove NAs
    rows_noNA <- which(rowSums(is.na(df)) == 0)
    df <- df[rows_noNA,]  
    
    ## Return
    df
    
  })
  
  ## Create Heat Map One
  create_h1 <- reactive({
    
    ## Create df
    df1 <- create_df1()
    
    ## Extract x
    x <- df1$Date
    
    ## Extract y
    if (input$field1 %in% c("Open", "High", "Low", "Close", "Volume", "AdjClose")) {
      y <- df1[, which(colnames(df1) == input$field1)]
    } else {
      y <- cal_idx(df1, as.character(input$field1))
    }
    
    ## Generate Plot Title
    if (input$field1 == "AdjClose") {
      text_title1 <- paste0(input$symbol1, "'s Adjusted Close")
    } else {
      text_title1 <- paste0(input$symbol1, "'s ", input$field1)
    }
    
    ## Create Calendar Heat Map and Save as PNG
    png(filename = "h1.png", 750, 750, res = 100)
    calendarHeat(x, y, varname = text_title1, ncolors = 99, color = input$colour)
    dev.off()
    
  })
  
  ## Create Heat Map Two
  create_h2 <- reactive({
    
    ## Create df
    df2 <- create_df2()
    
    ## Extract x
    x <- df2$Date
    
    ## Extract y
    if (input$field2 %in% c("Open", "High", "Low", "Close", "Volume", "AdjClose")) {
      y <- df2[, which(colnames(df2) == input$field2)]
    } else {
      y <- cal_idx(df2, as.character(input$field2))
    }
    
    ## Generate Plot Title
    if (input$field2 == "AdjClose") {
      text_title2 <- paste0(input$symbol2, "'s Adjusted Close")
    } else {
      text_title2 <- paste0(input$symbol2, "'s ", input$field2)
    }
    
    ## Create Calendar Heat Map and Save as PNG
    png(filename = "h2.png", 750, 750, res = 100)
    calendarHeat(x, y, varname = text_title2, ncolors = 99, color = input$colour)
    dev.off()
    
  })
  
  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Outputs
  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  ## Heat Map Output
  output$heatmap <- renderPlot({
    
    ## first load or settings are the same as initial values
    if (input$symbol1 == "GOOG" & input$symbol2 == "YHOO" &
        input$field1 == "AdjClose" & input$field2 == "AdjClose" &
        input$start == "2009-01-01" & input$colour == "r2b") {
      
      ## Use previously rendered ggplot2 object for faster display
      load("preloaded.rda")
      
    } else {  
      
      ## if the initial settings have been changed ...
      ## Run reactive functions
      create_h1()
      create_h2()
      
      ## Read rendered PNGs
      img1 <- png::readPNG("h1.png")
      img2 <- png::readPNG("h2.png")
      
      ## Combine PNGs and Convert into Grob
      img <- abind(img1, img2, along = 2)
      g <- rasterGrob(img, interpolate=TRUE)
      
      ## Create ggplot2 object
      gg_heatmap <- qplot(1:10, 1:10, geom="blank") + geom_blank() +
        annotation_custom(g, xmin=-Inf, xmax=Inf, ymin=-Inf, ymax=Inf) +  
        new_theme_empty
    }
    
    ## Return object by printing
    print(gg_heatmap)
    
  }, width = 1500, height = 750)
  
})


## =============================================================================
## Temporary Parameters for Testing Purposes
## =============================================================================

## Not Run:

if (FALSE) {
  
  input <- list(symbol1 = "GOOG",
                symbol2 = "YHOO",
                field1 = "AdjClose",
                field2 = "AdjClose",
                start = "2009-01-01",
                colour = "r2b")
  
}