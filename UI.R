
library("shiny")
library("shinythemes")
library("plotly")
library("ggplot2")
library("leaflet")
library("purrr")
library("shinycssloaders")
library("gtrendsR")
library("data.table")
library("scales")
library('reticulate')

source_python("Xgboostmodel.py")

states <- geojsonio::geojson_read("https://rstudio.github.io/leaflet/json/us-states.geojson", what = "sp")

bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)
pal <- colorBin("YlOrRd", domain = states$density, bins = bins)

labels <- sprintf(
  "<strong>%s</strong><br/>%g people / mi<sup>2</sup>",
  states$name, states$density
) %>% lapply(htmltools::HTML)


ui <- navbarPage(
  title = "CWDS",
  id = "mytabs",
  theme = shinytheme("united"),
  tabPanel(
    title = "Home",
    tags$h1("Welcome Union County to CWDS"),
    tags$p("By: Akash Koneru, Mohamed Bin Adi, Louie Constable, Shubham Mishra"),
    tags$p("Purpose: The harmful effects of COVID-19 have been felt by all of us. 
       We decided to create this Covid Wastewater Detection System to help prevent COVID-19 cases within Union County and also help educate Union County on the safety precautions that need to be taken. 
       This group also wanted to expose the dangers of this terrible virus to Union County to ensure they take this virus very seriously.")
  ),
  tabPanel(
    title = "Union County",
    id = "county",
    leafletOutput("county_cloro") %>% withSpinner()
  ),
  tabPanel(
    title = "Potenial Spikes",
    selectizeInput(inputId = "state", label = "State", choices = state.name, multiple = TRUE),
    plotlyOutput("prediction_plot") %>% withSpinner()
  ),
  tabPanel(
    title = "Google Trends",
    textInput("keyword", "Keyword", placeholder = "Enter a keyword"),
    actionButton("keyword_go", "Search"),
    plotlyOutput("google_trends_plot")  %>% withSpinner()
  ),
  
  # on this tab panel we are looking at the symptom evaluation panel, machine learning is used to predict if a person has covid
  tabPanel(title = "Symptom Evaluation",
           radioButtons(inputId = "Age",
                              label = "Select your Age Group:",
                              choices = c("0 - 17 years", "18 to 49 years", "50 to 64 years","65+ years"),inline = T),
           
           radioButtons(inputId = "Sex",
                        label = "Select your Sex:",
                        choices = c("Female", "Male", "Unknown","Other"),inline = T),
           
           radioButtons(inputId = "Race",
                        label = "Select your Race:",
                        choices = c("White", "Black", "American Indian/Alaska Native","Asian",'Multiple/Other','Native Hawaiian/Other Pacific Islander' ),inline = T),
           
           radioButtons(inputId = "ethnicity",
                        label = "Select your ethnicity:",
                        choices = c("Hispanic/Latino", "Non-Hispanic/Latino", "Unknown"),inline = T),
           
           radioButtons(inputId = "hospital",
                        label = "Have you been to the hospital:",
                        choices = c("Yes", "No", "Unknown"),inline = T),
           
           radioButtons(inputId = "Covid_exposure",
                        label = "Have you been exposed to someone with covid?:",
                        choices = c("Yes", "No", "Unknown"),inline = T),
           
           radioButtons(inputId = "symptoms",
                        label = "What are your symptoms like?:",
                        choices = c("Symptomatic", "Unknown", "Asymptomatic"),inline = T),
           
           radioButtons(inputId = "underlying_conditions",
                        label = "do you have any underlying conditions?:",
                        choices = c("Yes", "No"),inline = T),
           
           # action button should run the model when pressed. Still working on this 
           actionButton(inputId = "run_model", label = "Run Model"),
           
           # displays output from the python function 
           textOutput('py_output')
           
           
           
           
           
  ),
  tabPanel("Info",
           fluidRow(
             column(
               width = 4,
               wellPanel(
                 tags$h2("Prevention"),
                 tags$p("To prevent the spread of COVID-19, it's important to follow these guidelines:"),
                 tags$ol(
                   tags$li("Wear a mask in public settings and when around people who don't live in your household."),
                   tags$li("Stay at least 6 feet apart from others."),
                   tags$li("Avoid crowds and poorly ventilated indoor spaces."),
                   tags$li("Wash your hands often with soap and water for at least 20 seconds, or use an alcohol-based hand sanitizer that contains at least 60% alcohol."),
                   tags$li("Cover your mouth and nose with your elbow or a tissue when you cough or sneeze."),
                   tags$li("Clean and disinfect frequently touched objects and surfaces daily.")
                 )
                 
               )
             ),
             column(
               width = 4,
               wellPanel(
                 tags$h2("Dangers"),
                 tags$p("COVID-19 is a serious illness that can lead to severe complications and even death. Some of the most common dangers associated with COVID-19 include:"),
                 tags$ul(
                   tags$li("Pneumonia"),
                   tags$li("Acute respiratory distress syndrome (ARDS)"),
                   tags$li("Blood clots"),
                   tags$li("Organ failure"),
                   tags$li("Death")
                 )
                 
               )
             ),
             column(
               width = 4,
               wellPanel(
                 tags$h2("Symptoms"),
                 tags$p("Symptoms of COVID-19 can range from mild to severe and can appear 2-14 days after exposure to the virus. Some of the most common symptoms include:"),
                 tags$ul(
                   tags$li("Fever or chills"),
                   tags$li("Cough"),
                   tags$li("Shortness of breath or difficulty breathing"),
                   tags$li("Fatigue"),
                   tags$li("Muscle or body aches"),
                   tags$li("Headache"),
                   tags$li("New loss of taste or smell"),
                   tags$li("Sore throat")
                 )
               ) #/ fluidRow
               
             )
           )
           
  ) #/Tab Panel
  
) #/ ui


server <- function(input, output, session) {
  
  observeEvent(input$go_to_county_cloro, {
    updateNavbarPage(
      session = session,
      inputId = "mytabs",
      selected = "County"
    )
    
  })
  
  county_data <- reactive({
    x <- 1:1000
    y <- 1.2 * x + 200 * runif(length(x))
    data.frame(x = x, y = y) %>%
      return()
  })
  
  output$prediction_plot <- renderPlotly({
    
    shiny::validate(
      need(input$state, "select one or more states")
    )
    
    county_data() %>%
      ggplot(aes(x, y)) +
      geom_smooth(formula = y ~ x, method = "loess") +
      geom_line() +
      labs(title = paste0(input$state, collapse = ", "))
  })
  
  output$county_cloro <- renderLeaflet({
    
    leaflet(states) %>%
      setView(-96, 37.8, 4) %>%
      addProviderTiles("MapBox", options = providerTileOptions(
        id = "mapbox.light",
        accessToken = Sys.getenv('MAPBOX_ACCESS_TOKEN'))) %>%
      addPolygons(
        fillColor = ~pal(density),
        weight = 2,
        opacity = 1,
        color = "white",
        dashArray = "3",
        fillOpacity = 0.7,
        highlightOptions = highlightOptions(
          weight = 5,
          color = "#666",
          dashArray = "",
          fillOpacity = 0.7,
          bringToFront = TRUE),
        label = labels,
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "15px",
          direction = "auto")) %>%
      addLegend(pal = pal, values = ~density, opacity = 0.7, title = NULL,
                position = "bottomright")
  })
  
  trends <- eventReactive(input$keyword_go, {
    
    shiny::validate(
      need(input$keyword, "Need to enter a keyword!")
    )
    
    # set the parameters for the API call
    geo <- c("US") # geographic locations
    time <- "today+5-y" # time frame
    
    # make the API call
    res <- gtrends(input$keyword, geo, time)
    
    plot_data <- as.data.table(res$interest_over_time)
    plot_data[, hits := as.numeric(hits)]
    plot_data[, date := as.Date(date)]
    
    return(plot_data)
  })
  
  output$google_trends_plot <- renderPlotly({
    
    ggplot(trends(), aes(x = date, y = hits)) +
      geom_line() +
      theme_minimal() +
      scale_x_date(date_breaks = "3 months", date_labels = "%b '%y") +
      scale_y_continuous(labels = scales::comma) +
      theme(
        axis.text.x = element_text(angle = 45),
        axis.title.x = element_blank()
      ) +
      labs(title = paste0(isolate(input$keyword), collapse = ","))
  })
  
  # when the button is pushed the inputs decided are put into the predict function. This is currently not working needs more work
  observeEvent(input$run_model, {
    # Get the input values
    age <- input$Age
    sex <- input$Sex
    race <- input$Race
    ethnicity <- input$ethnicity
    hospital <- input$hospital
    covid_exposure <- input$Covid_exposure
    symptoms <- input$symptoms
    underlying_conditions <- input$underlying_conditions
    
    # Call the predict1 function with the input values
    py_function_output <- predict1(age, sex, race, ethnicity, covid_exposure, symptoms, hospital, underlying_conditions)
    
    # Update the output with the result of the predict1 function
    output$py_output <- renderText({
      py_function_output
    })
  })
  
  
  
  
  
}
  
  


shinyApp(ui = ui, server = server)
