## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Process study trial data from WHO data sources, adding lat, long and other
## required meta data for mapping
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require(dplyr)
require(geonames)
options(geonamesUsername = "andyjgarcia")
require(maps)

## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Import raw data with minimal processing
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
trials <- read.csv("./data/simple_overview.csv", stringsAsFactors = FALSE)
trials[which(trials == "?", arr.ind = TRUE)] <- "Unknown"
df_trials <- trials

## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Add lat, long at the country level for each trial
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
country_locs <- data.frame(Country = unique(df_trials$Country), lat = NA, lon = NA, countryCode = NA)
for (i in 1:nrow(df_trials)) {
  country <- country_locs$Country[i]
  res <- GNsearch(name_equals = country, featureClass = "A", featureCode = "PCLI")
  if(nrow(res) > 0) {
    country_locs$lat[i] <- res$lat[1]
    country_locs$lon[i] <- res$lng[1]
    country_locs$countryCode[i] <- res$countryCode[1]
  }
  if(nrow(res) > 1) {
    warning(paste0("More than one geonames result for ", country))
  }
}
df_trials <-
  tbl_df(df_trials) %>%
  inner_join(country_locs, by = c("Country"))

## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Where possible, add resolution down to site
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
site_locs <- data.frame(unique(df_trials[,c("countryCode", "Site")]), sitelat = NA, sitelon = NA, siteGNId = NA)
for (i in 1:nrow(df_trials)) {
  site <- site_locs$Site[i]
  if(site == "Unknown" || site == "TBD" || is.na(site)) next

  countryCode <- site_locs$countryCode[i]
  res <- GNsearch(name_equals = site, country = countryCode, featureClass = "P")
  if(nrow(res) > 0) {
    site_locs$sitelat[i] <- res$lat[1]
    site_locs$sitelon[i] <- res$lng[1]
    site_locs$siteGNId[i] <- res$geonameId[1]
  }
  if(nrow(res) > 1) {
    warning(paste0("More than one geonames result for ", site, " in ", countryCode))
  }
}
site_locs <-
  tbl_df(site_locs) %>%
  filter(!is.na(siteGNId))

df_trials <-
  tbl_df(df_trials) %>%
  left_join(site_locs, by = c("Site", "countryCode"))

## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Write the final table to CSV
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
df_trials$lat <- round(as.numeric(df_trials$lat, 5))
df_trials$lon <- round(as.numeric(df_trials$lon, 5))
df_trials$sitelat <- round(as.numeric(df_trials$sitelat, 5))
df_trials$sitelon <- round(as.numeric(df_trials$sitelon, 5))
write.csv(df_trials, file ="./data/simple_overview_modified.csv", row.names = FALSE)
