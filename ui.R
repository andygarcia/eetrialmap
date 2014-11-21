library(shiny)
library(rMaps)
library(rCharts)
library(ggmap)
library(markdown)

navbarPage(title = "Ebola Trial Locations",

  # Use a customized bootstrap theme
  theme = 'bootstrap.css',
  collapsable = TRUE,

  tabPanel("About", includeMarkdown("doc/intro.md")),

  tabPanel("Map",
           tags$style('.leaflet {height: 800px;}'),
           mapOutput('map_all')),

  navbarMenu("Data",
    tabPanel("Data (Original)",
             HTML("<h3>Original Trial Data from WHO</h3>"),
             downloadButton('dl_ori', 'Download CSV'),
             HTML("<p> <br></p>"),
             dataTableOutput("data_original")
    ),
    tabPanel("Data (Modified)",
             HTML("<h3>Processed Trial Locations with Lat/Lon Info</h3>"),
             downloadButton('dl_mod', 'Download CSV'),
             HTML("<p> <br></p>"),
             dataTableOutput("data_modified")
    )
  ),

  tabPanel("Code", includeMarkdown("doc/code.md"))
)
