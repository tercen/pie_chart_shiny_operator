library(shiny)
library(tercen)
library(dplyr)
library(tidyr)
library(RColorBrewer)
library(ggplot2)
library(ggforce)

############################################
#### This part should not be modified
getCtx <- function(session) {
  # retreive url query parameters provided by tercen
  query <- parseQueryString(session$clientData$url_search)
  token <- query[["token"]]
  taskId <- query[["taskId"]]
  
  # create a Tercen context object using the token
  ctx <- tercenCtx(taskId = taskId, authToken = token)
  return(ctx)
}
####
############################################

shinyServer(function(input, output, session) {
  dataInput <- reactive({
    getValues(session)
  })
  
  output$reacOut <- renderUI({
    plotOutput("main.plot",
               height = input$plotHeight,
               width = input$plotWidth)
  })
  
  output$main.plot <- renderPlot({
    p()
  })
  
  p <- function() {
    values <- dataInput()
    
    if (length(levels(values$data$label)) > 74) {
      qual_col_pals = brewer.pal.info
    } else {
      qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual', ]
    }
    
    col_vector = unlist(mapply(
      brewer.pal,
      qual_col_pals$maxcolors,
      rownames(qual_col_pals)
    ))
    
    data <- values$data %>%
      mutate(
        end = 2 * pi * cumsum(count) / sum(count),
        start = lag(end, default = 0),
        middle = 0.5 * (start + end),
        hjust = ifelse(middle > pi, 1, 0),
        vjust = ifelse(middle < pi / 2 |
                         middle > 3 * pi / 2, 0, 1)
      )
    
    plt = ggplot(data) +
      geom_arc_bar(aes(
        x0 = 0,
        y0 = 0,
        r0 = input$ringSize,
        r = 1,
        start = start,
        end = end,
        fill = label
      )) +
      geom_text(aes(
        x = 1.05 * sin(middle),
        y = 1.05 * cos(middle),
        label = count,
        hjust = hjust,
        vjust = vjust
      )) +
      coord_fixed() +
      scale_x_continuous(
        limits = c(-1.5, 1.5),
        # Adjust so labels are not cut off
        name = "",
        breaks = NULL,
        labels = NULL
      ) +
      scale_y_continuous(
        limits = c(-1.5, 1.5),
        # Adjust so labels are not cut off
        name = "",
        breaks = NULL,
        labels = NULL
      ) +
      scale_fill_manual(values = col_vector[1:length(unique(data$label))]) +
      labs(fill = input$titleLegend,
           title = input$titlePlot) +
      theme(
        panel.background = element_rect(fill = "transparent"),
        # bg of the panel
        plot.background = element_rect(fill = "transparent", color = NA),
        # bg of the plot
        panel.grid = element_blank(),
        panel.grid.major = element_blank(),
        # get rid of major grid
        panel.grid.minor = element_blank(),
        # get rid of minor grid
        legend.background = element_rect(fill = "transparent"),
        # get rid of legend bg
        legend.box.background = element_rect(fill = "transparent") # get rid of legend panel bg
      )
    
    plt
    
  }
  
  output$downloadPlot <- downloadHandler(
    filename = 'pie.png',
    content = function(file) {
      ggsave(file,
             plot = p(),
             device = "png",
             dpi = 300)
    }
  )
  
})

getValues <- function(session) {
  ctx <- getCtx(session)
  values <- list()
  
  values$data <- ctx$select(c(ctx$labels[[1]], '.y')) %>%
    setNames(c('label', 'count'))
  
  values$data <- as.data.frame(values$data)
  
  return(values)
}