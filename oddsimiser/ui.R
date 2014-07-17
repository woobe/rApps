suppressMessages(library(shiny))
suppressMessages(library(combinat))
suppressMessages(library(GA))
suppressMessages(library(MCMCpack))

shinyUI(fluidPage(
  titlePanel("注碼優化器 (Prototype)"),
  
  sidebarLayout(
    sidebarPanel(
      
      helpText(HTML("<h4>簡介:</h4>由於每場賽事的賠率有差異，賠率高的賽事相對需要比較少的注碼.
                    這個 App 自動優化每個組合的最佳注碼, 以求達到最平衡的利潤.")),
      helpText(HTML("<br>")),
      
      helpText(HTML("<h4>使用方法:</h4>假設你要平均投注於三至十場賽事, 輸入總投注額,
                    然後輸入每場賽事的賠率, 再按'自動優化'. 預設顯示組合為'單拖', 可於標籤處選擇'二重彩'組合.")),
      helpText(HTML("<br>")),
               
      helpText(HTML("<h4>註:</h4>")),
      helpText(HTML("1. 如果少於十場賽事，於多餘賽事上輸入賠率 1.")),
      helpText(HTML("2. 利潤計法 - 保守假設只有單組合勝出.")),
      helpText(HTML("3. 二重彩組合比較複雜，所需計算時間相對較長.")),
      helpText(HTML("<br>")),
      
      wellPanel(
        numericInput("stake", 
                     label = "總投注額 (Total Stake) ($)",
                     value = 10),
        helpText(HTML("<br>")),
        
        numericInput("odds1", 
                     label = "第一場賠率 (Game 1 Odds)",
                     value = 7.5),
        numericInput("odds2", 
                     label = "第二場賠率 (etc ...)",
                     value = 8),
        numericInput("odds3", 
                     label = "第三場賠率",
                     value = 9),
        numericInput("odds4", 
                     label = "第四場賠率",
                     value = 10),
        numericInput("odds5", 
                     label = "第五場賠率",
                     value = 15),
        numericInput("odds6", 
                     label = "第六場賠率",
                     value = 1),
        numericInput("odds7", 
                     label = "第七場賠率",
                     value = 1),
        numericInput("odds8", 
                     label = "第八場賠率",
                     value = 1),
        numericInput("odds9", 
                     label = "第九場賠率",
                     value = 1),
        numericInput("odds10", 
                     label = "第十場賠率",
                     value = 1),
        
        
        helpText(HTML("<br>")),
        
        helpText(HTML("輸入完成後按這個")),
        submitButton("自動優化 (Optimise!)")
      )),


    mainPanel(
      tabsetPanel(
        tabPanel("單拖 (Single)", tableOutput("single")),
        tabPanel("二重彩 (Double)", tableOutput("double"))
      )
    )
  )
))