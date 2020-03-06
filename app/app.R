## load required libraries
library(shiny)
library(ggplot2)
library(magrittr)
library(incidence)
library(projections)
library(distcrete)
library(DT)


## load simulator
simulate_cases <- readRDS("rds/simulate_cases.rds")
scripts <- list.files("scripts", pattern = "[.]R$", full.names = TRUE)
lapply(scripts, source)

## Define UI for application that draws a histogram
ui <- fluidPage(
  tags$base(target = "_parent"),
  ## Call Mathjax once to display equations throughout the document
  withMathJax(),
  
  ## Application title
  titlePanel("Inferring COVID-19 cases from deaths of confirmed cases"),
  
  ## Author list and disclaimer
  withTags({
    div(
        HTML("<p style='max-width:95%;'><strong>Authors</strong>: 
          Thibaut Jombart, Sam Abbott, Amy Gimma, Kevin Zandvoort, Sam Clifford,
          Christopher Jarvis, Timothy Russell, Sebastian Funk, Hamrish Gibbs, 
          Rosalind Eggo, Adam Kucharski, 
          <a href='https://cmmid.github.io/groups/ncov-group'>
          <i>CMMID COVID-19 Working Group*</i></a>,
          John Edmunds</p>"),
        HTML("<p style='margin-bottom:14px;max-width:95%;'>
          <strong>Disclaimer:</strong> 
          This model is not peer-reviewed. The results generated here should not 
          be interpreted to predict exact numbers of cases. Please read the 
          <a href='https://cmmid.github.io/topics/covid19/current-patterns-transmission/cases-from-deaths.html'>
          study summary</a> on the
          <a href='https://cmmid.github.io/topics/covid19/'>
          LSHTM CMMID website</a>.<p>")
    )
  }),
  
  ## Inputs for the model below
  sidebarLayout(
    sidebarPanel(
      h2("Data input"),
      textInput("date_death",
                paste("Dates of Death",
                      "(Format 'yyyy-mm-dd', e.g. 2020-02-18,",
                      "separated by spaces or new lines. The date range
                      must be 7 days or less):"),
                paste(Sys.Date(), "...")),
      verbatimTextOutput("date_clean"),
      h2("Model input"),
      sliderInput("R",
                  "Reproduction number (R):",
                  min = 1,
                  max = 4,
                  value = 2,
                  step = 0.1),
      sliderInput("cfr",
                  "Case Fatality Ratio (CFR), in %:",
                  min = 0.1,
                  max = 10,
                  value = 2,
                  step = 0.1),
      sliderInput("duration",
                  "Duration of simulations (days after last death):",
                  min = 1,
                  max = 14,
                  value = 1,
                  step = 1),
      sliderInput("n_sim",
                  "Number of simulation (50 trajectories per simulations):",
                  min = 10,
                  max = 200,
                  value = 100,
                  step = 10),
      actionButton("go", "Simulate")
    ),
    
    ## Show a plot of the generated distribution
    mainPanel(
      
      tabsetPanel(
        tabPanel("Explanations",
                 includeMarkdown("include/description.md")
        ),
        tabPanel("Graphics",
                 ## main plot
                 h2("Simulation results: new cases per day"),
                 plotOutput("projections_plot"),
                 h2("Simulation results: cumulative cases"),
                 plotOutput("projections_plot_cumul"),
        ),
        tabPanel("Summary table",
                 h2("Summary table: cumulative case counts"),
                 DT::dataTableOutput("summary_table", width = "75%"),
                 br(),
                 br()
        )
      )
    )
  )
)

## Define server logic required to draw a histogram
server <- function(input, output) {
  
  ## auxiliary function used to generate the table summary
  summary_function <- function(x) {
    c(q_025 = round(quantile(x, 0.025)),
      q_25 = round(quantile(x, 0.25)),
      q_75 = round(quantile(x, 0.75)),
      q_95 = round(quantile(x, 0.975)))
  }
  
  
  ## capture date of death, clean input, convert to Date
  date_death <- eventReactive(input$go, {
    date_txt <- unlist(strsplit(input$date_death,
                                split = "[[:blank:][:space:],;]+"))
    clean_date <- gsub("[.]", "", date_txt)
    clean_date <- as.Date(unlist(clean_date))
    clean_date <- clean_date[!is.na(clean_date)]
    clean_date <- clean_date[order(clean_date)]
    date_range <- clean_date[length(clean_date)] - clean_date[1]
    
    if(as.numeric(date_range) > 7) {
      showModal(modalDialog(
        title = "Error: Date range is more than 7 days",
        "The date range is limited to 7 day or less. We assume constant 
        transmissibility (R) over time, which implies that behaviour change and 
        control measures have not taken place yet, and that there is no 
        depletion of susceptible individuals. Consequently, our method should 
        only be used in the early stages of a new epidemic, where these 
        assumptions are reasonable. Similarly, the assumption that each death 
        reflects independent, additive epidemic trajectories is most likely to 
        hold true early on, when reported deaths are close in time (e.g. no more 
        than a week apart). Used over longer time periods, our approach is 
        likely to overestimate epidemic sizes.",
        easyClose = TRUE))
    }
    clean_date
   
  }, ignoreNULL = FALSE)
  
  
  ## simulator part
  x <- eventReactive(input$go, {
    if (length(date_death())) {
      simulate_cases(date_death(),
                     R = input$R,
                     cfr = input$cfr / 100,
                     duration = input$duration,
                     n_sim = input$n_sim)
    } else {
      NULL
    }
  }, ignoreNULL = FALSE)
  
  output$projections_plot <- renderPlot({
    if (!is.null(x)) {
      x()$plot_projections
    }
  })
  
  output$projections_plot_cumul <- renderPlot({
    if (!is.null(x)) {
      x()$plot_projections_cumul
    }
  })
  
  
  output$summary_table <- DT::renderDataTable({
    if (!is.null(x)) {
      cumulative_counts <- cumulate(x()$projections)
      summary_table <- t(apply(cumulative_counts, 1, summary_function))

      ## Make dates a variable
      dates <- rownames(summary_table)
      summary_table <- as.data.frame(summary_table)
      rownames(summary_table) <- NULL
      summary_table$date <- as.Date(dates)
      
      ##Sort variables
      summary_table <- summary_table[, c(ncol(summary_table), 1:(ncol(summary_table) - 1))]
    
      colnames(summary_table) <- c("Date",
                                   "lower 95%",
                                   "lower 50%",
                                   "upper 50%",
                                   "upper 95%")
      summary_table
    }
  })
  
}

## Run the application 
shinyApp(ui = ui, server = server)