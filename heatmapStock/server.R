library(shiny)
library(tseries)
library(makeR)
library(abind)
library(png)
library(ggplot2)

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
    }
    
    ## Create Calendar Heat Map and Save as PNG
    png(filename = "h1.png", 1500, 1500, res = 200)
    calendarHeat(x, y, varname = paste0(input$field1, " (", input$symbol1, ")"),
                 ncolors = 99, color = "r2b")
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
    }
    
    ## Create Calendar Heat Map and Save as PNG
    png(filename = "h2.png", 1500, 1500, res = 200)
    calendarHeat(x, y, varname = paste0(input$field2, " (", input$symbol2, ")"),
                 ncolors = 99, color = "r2b")
    dev.off()
        
  })
  
  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Outputs
  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  ## Heat Map Output
  output$heatmap <- renderPlot({
    
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
    
    ## Return object by printing
    print(gg_heatmap)
    
  }, width = 3000, height = 1500)
  
})