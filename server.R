library(shiny)
library(rMaps)
library(rCharts)
library(ggmap)
library(markdown)
library(dplyr)

shinyServer(function(input, output, session) {

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # [Function]: Fixing invalid multibyte strings (needed for HTML output)
  # Source: http://tm.r-forge.r-project.org/faq.html#Encoding
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  fix_mbs <- function(x) iconv(enc2utf8(x), sub = "byte")


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # [Function]: Setting the approximate map center
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  set_center <- function(loc = 'all') {
    if (loc == 'all') return(data.frame(lon = 10, lat = 15))
  }


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # [Main Function]: Create Leaflet rMaps
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  create_map <- function(map_region = NULL,
                         map_country = NULL,
                         map_zoom = 2,
                         map_type = 'Stamen.TonerLite',
                         map_width = 1100,
                         map_height = 600) {

    # load data
    trials <- read.csv("./data/simple_overview_modified.csv", stringsAsFactors=FALSE)

    # eventually subset trials for this specific map render based on filters
    row_subset <- 1:nrow(trials)
    trials <- trials[row_subset, ]

    # center map on world for now
    geo_center <- set_center('all')


    # create and config map_base
    map_base <- rMaps::Leaflet$new()
    map_base$params$width <- map_width
    map_base$params$height <- map_height
    map_base$tileLayer(provider = map_type)
    map_base$setView(c(geo_center$lat, geo_center$lon), map_zoom)


    # per site markers with multiple trials
    sites <-
      tbl_df(trials) %>%
      filter(!is.na(siteGNId))

    unique_sites <-
      sites %>%
      select(Country, Site, sitelat, sitelon, siteGNId) %>%
      distinct()

    for(i in 1:nrow(unique_sites) ) {
      site <- unique_sites[i, ]
      trial <- sites %>% filter(siteGNId == site$siteGNId)

      site.label <- paste0("Site: <b>", site$Site, ", ", site$Country, "</b><br><br>")
      trial.labels <- paste0("Intervention: <b>", trial$Product, "</b><br>",
                             "Phase: <b>", trial$Phase, "</b><br>",
                             "PI: <b>", trial$PI, "</b><br>", collapse="<br>")
      popup.label <- paste0(site.label, trial.labels)
      map_base$marker(c(site$sitelat, site$sitelon), bindPopup = popup.label)
    }

    # per country markers with multiple trials
    countries <-
      tbl_df(trials) %>%
      filter(is.na(siteGNId))

    unique_countries <-
      countries %>%
      select(Country, lat, lon, countryGNId) %>%
      distinct() %>%
      filter(!is.na(countryGNId))

    for(i in 1:nrow(unique_countries) ) {
      country <- unique_countries[i, ]
      trial <- countries %>% filter(countryGNId == country$countryGNId)

      country.label <- paste0("Country: <b>", country$Country, "</b><br><br>")
      trial.labels <- paste0("Intervention: <b>", trial$Product, "</b><br>",
                             "Phase: <b>", trial$Phase, "</b><br>",
                             "PI: <b>", trial$PI, "</b><br>", collapse="<br>")
      popup.label <- paste0(country.label, trial.labels)
      map_base$marker(c(country$lat, country$lon), bindPopup = popup.label)
    }

    return(map_base)
  }


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # [Output]: Interactive Map (All Groups)
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  output$map_all <- renderUI({

    # Create map_base
    map_base <- create_map(NULL, NULL, 2)

    # Generate HTML code, fix invalid multibyte strings and return
    html_out <- HTML(map_base$html(chartId = "map_all"))
    html_out <- fix_mbs(html_out)
    html_out
  })


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # [Output]: Interactive Map (By Region: Asia)
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  output$map_asia <- renderUI({

    # Create map_base
    map_base <- create_map(map_region = 'Asia', map_zoom = 4)

    # Generate HTML code, fix invalid multibyte strings and return
    html_out <- HTML(map_base$html(chartId = "map_asia"))
    html_out <- fix_mbs(html_out)
    html_out
  })

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # [Output]: Interactive Map (By Region: Europe)
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  output$map_europe <- renderUI({

    # Create map_base
    map_base <- create_map(map_region = 'Europe', map_zoom = 4)

    # Generate HTML code, fix invalid multibyte strings and return
    html_out <- HTML(map_base$html(chartId = "map_europe"))
    html_out <- fix_mbs(html_out)
    html_out
  })

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # [Output]: Interactive Map (By Region: North America)
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  output$map_n_america <- renderUI({

    # Create map_base
    map_base <- create_map(map_region = 'North America', map_zoom = 4)

    # Generate HTML code, fix invalid multibyte strings and return
    html_out <- HTML(map_base$html(chartId = "map_n_america"))
    html_out <- fix_mbs(html_out)
    html_out
  })

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # [Output]: Interactive Map (By Region: Middle East or Africa)
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  output$map_mea <- renderUI({

    # Create map_base
    map_base <- create_map(map_region = 'Middle East or Africa', map_zoom = 3)

    # Generate HTML code, fix invalid multibyte strings and return
    html_out <- HTML(map_base$html(chartId = "map_mea"))
    html_out <- fix_mbs(html_out)
    html_out
  })

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # [Output]: Interactive Map (By Region: Oceania)
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  output$map_oceania <- renderUI({

    # Create map_base
    map_base <- create_map(map_region = 'Oceania', map_zoom = 4)

    # Generate HTML code, fix invalid multibyte strings and return
    html_out <- HTML(map_base$html(chartId = "map_oceania"))
    html_out <- fix_mbs(html_out)
    html_out
  })

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # [Output]: Interactive Map (By Region: South or Central America)
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  output$map_sc_america <- renderUI({

    # Create map_base
    map_base <- create_map(map_region = 'South or Central America', map_zoom = 3)

    # Generate HTML code, fix invalid multibyte strings and return
    html_out <- HTML(map_base$html(chartId = "map_sc_america"))
    html_out <- fix_mbs(html_out)
    html_out
  })



  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # [Output]: Interactive Map (United States)
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  output$map_usa <- renderUI({

    # Create map_base
    map_base <- create_map(map_country = 'United States', map_zoom = 4)

    # Generate HTML code, fix invalid multibyte strings and return
    html_out <- HTML(map_base$html(chartId = "map_usa"))
    html_out <- fix_mbs(html_out)
    html_out
  })

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # [Output]: Interactive Map (Canada)
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  output$map_canada <- renderUI({

    # Create map_base
    map_base <- create_map(map_country = 'Canada', map_zoom = 4)

    # Generate HTML code, fix invalid multibyte strings and return
    html_out <- HTML(map_base$html(chartId = "map_canada"))
    html_out <- fix_mbs(html_out)
    html_out
  })

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # [Output]: Interactive Map (Australia)
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  output$map_australia <- renderUI({

    # Create map_base
    map_base <- create_map(map_country = 'Australia', map_zoom = 4)

    # Generate HTML code, fix invalid multibyte strings and return
    html_out <- HTML(map_base$html(chartId = "map_australia"))
    html_out <- fix_mbs(html_out)
    html_out
  })

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # [Output]: Interactive Map (Germany)
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  output$map_germany <- renderUI({

    # Create map_base
    map_base <- create_map(map_country = 'Germany', map_zoom = 6)

    # Generate HTML code, fix invalid multibyte strings and return
    html_out <- HTML(map_base$html(chartId = "map_germany"))
    html_out <- fix_mbs(html_out)
    html_out
  })

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # [Output]: Interactive Map (India)
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  output$map_india <- renderUI({

    # Create map_base
    map_base <- create_map(map_country = 'India', map_zoom = 5)

    # Generate HTML code, fix invalid multibyte strings and return
    html_out <- HTML(map_base$html(chartId = "map_india"))
    html_out <- fix_mbs(html_out)
    html_out
  })

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # [Output]: Interactive Map (Japan)
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  output$map_japan <- renderUI({

    # Create map_base
    map_base <- create_map(map_country = 'Japan', map_zoom = 6)

    # Generate HTML code, fix invalid multibyte strings and return
    html_out <- HTML(map_base$html(chartId = "map_japan"))
    html_out <- fix_mbs(html_out)
    html_out
  })

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # [Output]: Interactive Map (United Kingdom)
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  output$map_uk <- renderUI({

    # Create map_base
    map_base <- create_map(map_country = 'United Kingdom', map_zoom = 6)

    # Generate HTML code, fix invalid multibyte strings and return
    html_out <- HTML(map_base$html(chartId = "map_uk"))
    html_out <- fix_mbs(html_out)
    html_out
  })

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # [Output]: Download Buttons for Original Data
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  csv_ori <- reactive({
    read.csv("./data/simple_overview.csv", stringsAsFactors = FALSE)
  })

  output$dl_ori <- downloadHandler(
    filename = function() {'simple_overview.csv'},
    content = function(file) {write.csv(csv_ori(), file)}
  )

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # [Output]: Download Buttons for Modified Data
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    csv_mod <- reactive({
      read.csv("./data/simple_overview_modified.csv", stringsAsFactors = FALSE)
    })

    output$dl_mod <- downloadHandler(
      filename = function() {'simple_overview_modified.csv'},
      content = function(file) {write.csv(csv_mod(), file)}
    )


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # [Output]: Table - Original Data
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  output$data_original <- renderDataTable({

    # Read Original CSV
    original <- read.csv("./data/simple_overview.csv", stringsAsFactors=FALSE)

    # Return
    original[, c("Product", "Phase", "Country", "Site", "PI")]

  }, options = list(paging = FALSE, searching = FALSE))


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # [Output]: Table - Modified Data
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  output$data_modified <- renderDataTable({

    # Read modified CSV
    modified <- read.csv("./data/simple_overview_modified.csv", stringsAsFactors=FALSE)

    # Return
    modified[, c("Product", "Phase", "Country", "Site", "PI", "lat", "lon", "sitelat", "sitelon")]

  }, options = list(paging = FALSE, searching = FALSE))
})
