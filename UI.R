library("shiny")
library("shinythemes")
library("plotly")
library("ggplot2")
library("leaflet")
library("purrr")
library("shinycssloaders")
library("gtrendsR")

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
    actionButton(inputId = "go_to_county_cloro", label = "Check Your County")
  ),
  tabPanel(
    title = "County",
    id = "county",
    leafletOutput("county_cloro") %>% withSpinner()
  ),
  tabPanel(
    title = "Deep Learning",
    selectizeInput(inputId = "state", label = "State", choices = state.name, multiple = TRUE),
    plotlyOutput("prediction_plot") %>% withSpinner()
  ),
  tabPanel(
    title = "Google Trends",
    textInput("keyword", "Keyword", placeholder = "Enter a keyword"),
    actionButton("keyword_go", "Search"),
    plotlyOutput("google_trends_plot")  %>% withSpinner()
  ),
  tabPanel("Info")
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
    gtrends(input$keyword, geo, time)
  })
  
  output$google_trends_plot <- renderPlotly({
    ggplot(trends()$interest_over_time, aes(x = date, y = hits)) +
      geom_line()
  })
}

shinyApp(ui = ui, server = server)
