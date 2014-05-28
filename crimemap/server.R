library(shiny)
library(ggplot2)
library(ggmap)
library(jsonlite)
library(png)
library(grid)
library(RCurl)
library(plyr)
library(markdown)

## Define server logic required to summarize and view the selected dataset
shinyServer(function(input, output) {
  
  ## Testing values
  if (FALSE) {
    input <- list(poi = "London Eye",
                  start = "2013-01-01",
                  months = 6,
                  facet = "none",
                  type = "roadmap",
                  res = TRUE,
                  bw = FALSE,
                  zoom = 14,
                  alpharange = c(0.1, 0.4),
                  bins = 15,
                  boundwidth = 0.1,
                  boundcolour = "grey95",
                  low = "yellow",
                  high = "red",
                  watermark = "TRUE")
  }
  
  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Static Functions
  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  ## Get data from API (using jsonlite to flatten list quickly)
  get_data <- function(map.geocode, map.period) {
    
    ## Loop through all months
    for (n_period in 1:length(map.period)) {
      
      ## Create an URL for API
      url_api <- paste0("http://data.police.uk/api/crimes-street/all-crime?",
                        "lat=", map.geocode[2], 
                        "&lng=", map.geocode[1],
                        "&date=", map.period[n_period])
      
      ## Download data
      tmp_dat <- jsonlite::fromJSON(getURL(url_api), flatten = TRUE)
      
      ## Store data
      if (n_period == 1) out_dat <- tmp_dat else out_dat <- rbind(out_dat, tmp_dat)
      
    }
    
    ## Trim and Rename columns
    col_inc <- c("category", "location_type", "id", "month", "location.latitude", 
                 "location.longitude", "location.streed.id",
                 "location.street.name")
    out_dat <- out_dat[, c(1,2,5,7,8,9,10,11)]
    colnames(out_dat) <- c("category", "type", "id", "month", "latitude",
                           "longitude", "street_id", "street_name")
    
    ## Convert characters into numerical values
    out_dat$id <- as.integer(out_dat$id)
    out_dat$latitude <- as.numeric(out_dat$latitude)
    out_dat$longitude <- as.numeric(out_dat$longitude)
    out_dat$street_id <- as.integer(out_dat$street_id)
    
    ## Return
    return(out_dat)
    
  }
  
  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Reactive Functions
  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  ## Get Geocode
  map.geocode <- reactive({
    suppressMessages(data.frame(geocode = geocode(paste(input$poi, "UK"))))
  })
  
  ## Define Period
  map.period <- reactive({
    format(seq(as.Date(input$start), length=input$months, by="months"), "%Y-%m")
  })
  
  ## Create Data Frame
  create.df <- reactive({
    
    ## Use Reactive Functions to download data and create a data frame
    temp.geocode <- map.geocode()
    temp.period <- map.period()
    df <- get_data(temp.geocode, temp.period)
    
    ## Return
    df
    
  })
  
  
  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Output 1 - Data Table
  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  output$datatable <- renderDataTable({
    
    ## Check input
    if (input$poi == "London Eye (Demo)") {
      
      ## Use preloaded data
      load("./demo/demo_london_eye.rda")      
      
    } else {
      
      ## Use reactive function
      df <- create.df()
      
    }
    
    ## Display df
    df
    
  }, options = list(aLengthMenu = c(10, 15, 30, 50, 100, 500), iDisplayLength = 15))
  
  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Output 2 - Heat Map
  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  output$map <- renderPlot({
    
    ## Check input
    if (input$poi == "London Eye (Demo)") {
      
      ## Use preloaded data
      load("./demo/demo_london_eye.rda")
      
    } else {
      
      ## Use reactive functions
      temp.geocode <- map.geocode()
      temp.period <- map.period()
      
      ## Get df
      df <- create.df()
      
      ## Create a data frame for the map center (point of interest)
      center.df <- data.frame(temp.geocode, location = input$poi)
      colnames(center.df) <- c("lon","lat","location")
      
    }
    
    ## Download base map using {ggmap}
    ## Note that a PNG file "ggmapTemp.png" will be created
    ## The PNG is not needed for the analysis, you can delete it later
    
    ## Define colour and scale of base map
    if (input$bw) temp.color <- "bw" else temp.color <- "color"
    if (input$res) temp.scale <- 2 else temp.scale <- 1
    
    map.base <- get_googlemap(
      as.matrix(temp.geocode),
      maptype = input$type, ## Map type as defined above (roadmap, terrain, satellite, hybrid)
      markers = temp.geocode,
      zoom = input$zoom,            ## 14 is just about right for a 1-mile radius
      color = temp.color,   ## "color" or "bw" (black & white)
      scale = temp.scale   ## Set it to 2 for high resolution output
    )
    
    ## Convert the base map into a ggplot object
    ## All added Cartesian coordinates to enable more geom options later on
    map.base <- ggmap(map.base, extend = "panel") + coord_cartesian() + coord_fixed(ratio = 1.5)
    
    ## Main ggplot
    map.final <- map.base  +    
      
      ## Create a density plot
      ## based on the ggmap's crime data example
      stat_density2d(aes(x = longitude, 
                         y = latitude, 
                         fill = ..level.., 
                         alpha = ..level..),
                     na.rm = TRUE,
                     size = input$boundwidth, 
                     bins = input$bins,  ## Change and experiment with no. of bins
                     data = df, 
                     geom = "polygon",
                     colour = input$boundcolour) +
      
      ## Configure the scale and panel
      scale_fill_gradient(low = input$low, high = input$high) +
      scale_alpha(range = input$alpharange) +
      
      ## Title and labels    
      labs(x = "Longitude", y = "Latitude") +
      ggtitle(paste("Crimes in/around ", center.df$location, 
                    " from ", temp.period[1],
                    " to ", temp.period[length(temp.period)], sep="")) +
      
      ## Other theme settings
      theme_bw() +
      theme(
        plot.title = element_text(size = 26, face = 'bold', vjust = 2),
        axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        legend.position = "none",
        strip.background = element_rect(fill = 'grey80'),
        strip.text = element_text(size = 18)
      )
    
    # Use Watermark?  
    if (input$watermark) {
      if (input$facet == "none") {
        map.final <- map.final + annotate("text", x = center.df$lon, y = -Inf, 
                                          label = "www.jofaichow.co.uk",
                                          vjust = -1.5, col = "steelblue", 
                                          cex = 10,
                                          fontface = "bold", alpha = 0.5)
      }
    }
    
    ## Use Facet?
    if (input$facet == "type") {map.final <- map.final + facet_wrap(~ type)}
    if (input$facet == "month") {map.final <- map.final + facet_wrap(~ month)}
    if (input$facet == "category") {map.final <- map.final + facet_wrap(~ category)}
    
    ## Display ggplot2 object
    print(map.final)
    
  }, width = 900, height = 900)
  
  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Output 3 - Trends 1
  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  output$trends1 <- renderPlot({
    
    
    ## Check input
    if (input$poi == "London Eye (Demo)") {
      
      ## Use preloaded data
      load("./demo/demo_london_eye.rda")
      
    } else {
      
      ## Use Reactive Functions
      temp.geocode <- map.geocode()
      temp.period <- map.period()
      
      ## Get df
      df <- create.df()
      
      ## Create a data frame for the map center (point of interest)
      center.df <- data.frame(temp.geocode, location = input$poi)
      colnames(center.df) <- c("lon","lat","location")
      
    }
    
    ## Create bar chart summary
    plot1 <- ggplot(df, aes(x = month, fill = category)) + 
      geom_bar(colour = "black") + facet_wrap(~ category) +
      labs(x = "Months", y = "Crime Records") + 
      ggtitle(paste("Crimes in/around ", center.df$location, 
                    ": Trends from ", temp.period[1],
                    " to ", temp.period[length(temp.period)], sep="")) +
      theme_bw() +
      theme(
        plot.title = element_text(size = 26, face = 'bold', vjust = 2),
        axis.text.x = element_blank(),
        axis.text = element_text(size = 16),
        axis.title.x = element_text(size = 24),
        axis.title.y = element_text(size = 24),
        axis.ticks.x = element_blank(),
        strip.background = element_rect(fill = 'grey80'),
        strip.text.x = element_text(size = 18),
        legend.position = "none",
        panel.grid = element_blank()
      )
    
    ## Print
    print(plot1)
    
  }, width = 1000, height = 900)
  
})