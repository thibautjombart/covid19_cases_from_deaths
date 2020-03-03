
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
  ## Call Mathjax once to display equations throughout the document
  withMathJax(),
  
  ## Application title
  titlePanel("Infering COVID-19 cases from deaths of confirmed cases"),
  
  ## Author list and disclaimer
  withTags({
    div(
        HTML("<p><strong>Authors</strong>: 
          Thibaut Jombart, Sam Abbott, Amy Gimma, Kevin Zandvoort,
          Christopher Jarvis, Timothy Russel, Sebastian Funk, Hamrish Gibbs, 
          Rosalind Eggo, Adam Kucharski, <i>CMMID COVID-19 Working Group*</i>,
          John Edmunds</p>"),
        HTML("<p><strong>Disclaimer:</strong> 
          This model is not peer-reviewed. The results generated here should not be
          interpreted to predict exact numbers of cases. Please 
          visit the <a href='https://cmmid.github.io/topics/covid19/'>
          LSHTM CMMID website</a> for more resources on the COVID-19 
          outbreak.<p>")
    )
  }),
  
  ## Inputs for the model below
  sidebarLayout(
    sidebarPanel(
      h2("Data input"),
      textInput("date_death",
                paste("Enter dates of death here on separate lines,",
                      "using 'yyyy-mm-dd' format, e.g. 2020-02-18:"),
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
    clean_date[!is.na(clean_date)]
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

