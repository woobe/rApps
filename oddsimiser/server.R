suppressMessages(library(shiny))
suppressMessages(library(combinat))
suppressMessages(library(GA))
suppressMessages(library(MCMCpack))

shinyServer(function(input, output) {
  
  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Optimiser (Single)
  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  optimise_single <- reactive({
    
    odds_all <- c()  
    if (input$odds1 > 1) odds_all <- c(odds_all, input$odds1)
    if (input$odds2 > 1) odds_all <- c(odds_all, input$odds2)
    if (input$odds3 > 1) odds_all <- c(odds_all, input$odds3)
    if (input$odds4 > 1) odds_all <- c(odds_all, input$odds4)
    if (input$odds5 > 1) odds_all <- c(odds_all, input$odds5)
    if (input$odds6 > 1) odds_all <- c(odds_all, input$odds6)
    if (input$odds7 > 1) odds_all <- c(odds_all, input$odds7)
    if (input$odds8 > 1) odds_all <- c(odds_all, input$odds8)
    if (input$odds9 > 1) odds_all <- c(odds_all, input$odds9)
    if (input$odds10 > 1) odds_all <- c(odds_all, input$odds10)
    as.matrix(odds_all)
    
        
    ## Evaluate Function
    eval_odds <- function(inp_p) {
      total_p <- sum(inp_p)
      rtn <- odds_all * as.matrix(inp_p) - total_p
      #return(min(rtn))
      return(1-(max(rtn)-min(rtn))/max(rtn))
    }
    
    ## Define parameters for GA
    para_ga_min <- rep(0, length(odds_all))
    para_ga_max <- rep(1, length(odds_all))
    
    ## Optimise with GA
    set.seed(1234)
    model <- ga(type = "real-valued",
                fitness = eval_odds, monitor = FALSE,
                min = para_ga_min, max = para_ga_max,
                popSize = 10, maxiter = 1000)
    
    ## Normalise and save results
    best_p <- summary(model)$solution / sum(summary(model)$solution)
    
    ## Create summary df
    sum_df <- data.frame(matrix(NA, nrow = 4, ncol = length(odds_all)))
    colnames(sum_df) <- paste0("賽事", 1:length(odds_all))
    rownames(sum_df) <- c("賠率", "注碼", "回報", "利潤")  
    sum_df[1,] <- odds_all
    sum_df[2,] <- best_p * input$stake
    sum_df[3,] <- odds_all * best_p * input$stake
    sum_df[4,] <- (odds_all * best_p - 1) * input$stake
    
    ## Return
    t(sum_df)
    
  })
  
  
  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Optimiser Double
  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  optimise_double <- reactive({
    
    odds_all <- c()  
    if (input$odds1 > 1) odds_all <- c(odds_all, input$odds1)
    if (input$odds2 > 1) odds_all <- c(odds_all, input$odds2)
    if (input$odds3 > 1) odds_all <- c(odds_all, input$odds3)
    if (input$odds4 > 1) odds_all <- c(odds_all, input$odds4)
    if (input$odds5 > 1) odds_all <- c(odds_all, input$odds5)
    if (input$odds6 > 1) odds_all <- c(odds_all, input$odds6)
    if (input$odds7 > 1) odds_all <- c(odds_all, input$odds7)
    if (input$odds8 > 1) odds_all <- c(odds_all, input$odds8)
    if (input$odds9 > 1) odds_all <- c(odds_all, input$odds9)
    if (input$odds10 > 1) odds_all <- c(odds_all, input$odds10)
    as.matrix(odds_all)
      
    games_all <- paste0("賽事", 1:length(odds_all))
    games_double <- combn(games_all, 2)
    
    cbn_double <- combn(odds_all, 2)
    odds_all <- cbn_double[1, ] * cbn_double[2, ]
    
    ## Evaluate Function
    eval_odds <- function(inp_p) {
      total_p <- sum(inp_p)
      rtn <- odds_all * as.matrix(inp_p) - total_p
      #return(min(rtn))
      return(1-(max(rtn)-min(rtn))/max(rtn))
    }
    
    ## Define parameters for GA
    para_ga_min <- rep(0, length(odds_all))
    para_ga_max <- rep(1, length(odds_all))
    
    ## Optimise with GA
    set.seed(1234)
    model <- ga(type = "real-valued",
                fitness = eval_odds, monitor = FALSE,
                min = para_ga_min, max = para_ga_max,
                popSize = 20, maxiter = 2000)
    
    ## Normalise and save results
    best_p <- summary(model)$solution / sum(summary(model)$solution)
    
    ## Create summary df
    sum_df <- data.frame(matrix(NA, nrow = 4, ncol = length(odds_all)))
    
    names_double <- c()
    for (n in 1:length(odds_all)) {
      names_double <- c(names_double, paste0(games_double[1,n], "x", games_double[2,n]))
    }
    colnames(sum_df) <- names_double
    
    rownames(sum_df) <- c("賠率", "注碼", "回報", "利潤")  
    sum_df[1,] <- odds_all
    sum_df[2,] <- best_p * input$stake
    sum_df[3,] <- odds_all * best_p * input$stake
    sum_df[4,] <- (odds_all * best_p - 1) * input$stake
    
    ## Return
    t(sum_df)
    
  })
  
  
  
  ## Outputs
  
  output$single <- renderTable({
    print(as.data.frame(optimise_single()))
  })
  
  output$double <- renderTable({
    print(as.data.frame(optimise_double()))
  })
  
  
})