library(shiny)
library(shinyjs)

ui <- shinyUI(
  fluidPage(
    shinyjs::useShinyjs(),
    tags$script(
      HTML(
        'setInterval(function(){ $("#hiddenButton").click(); }, 1000*30);'
      )
    ),
    tags$footer(shinyjs::hidden(
      actionButton(inputId = "hiddenButton", label = "hidden")
    )),
    
    titlePanel("Pie Chart"),
    
    sidebarPanel(
      textInput("titlePlot", "Plot title", NULL),
      textInput("titleLegend", "Legend title", NULL),
      sliderInput("plotWidth", "Plot width (px)", 200, 2000, 500),
      sliderInput("plotHeight", "Plot height (px)", 200, 2000, 500),
      sliderInput("ringSize", "Inner ring size (R0)", 0, 1, 0.8),
      downloadButton('downloadPlot', 'Download Plot')
    ),
    
    mainPanel(uiOutput("reacOut"))
    
  )
)
