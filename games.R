# Load necessary libraries.
suppressMessages(library(tidyverse))
library(nhlscraper)
library(lubridate)
library(stringr)

# Set helper functions.
to_espn_date <- function(date) {
  date <- ymd_hms(date, tz='UTC')
  as.integer(format(date, '%Y%m%d'))
}
get_espn_event_id <- function(href) {
  event <- str_extract(href, '(?<=/events/)\\d+')
  as.integer(event)
}
get_espn_all_events <- function(all_seasons) {
  all_seasons %>% 
    select(
      season=id,
      espn_start_date,
      espn_end_date
    ) %>% 
    pmap_dfr(function(season, espn_start_date, espn_end_date) {
      events <- get_espn_events(espn_start_date, espn_end_date)
      if (nrow(events)==0) {
        return(tibble(season=integer(), id=integer()))
      }
      tibble(season=season, id=get_espn_event_id(events$`$ref`))
    })
}

# Get all seasons from 2007-2008 to 2024-2025.
all_seasons <- get_seasons() %>% 
  mutate(
    espn_start_date=to_espn_date(startDate),
    espn_end_date=to_espn_date(endDate)
  ) %>% 
  filter(id>=20072008) %>% 
  filter(id<=20242025) %>% 
  arrange(id)

# Get all games and events from 2007-2008 to 2024-2025.
all_games <- get_games() %>% 
  filter(season>=20072008) %>% 
  filter(season<=20242025)
all_events <- get_espn_all_events(all_seasons)

# Export `all_games` and `all_events`.
write.csv(all_games, 'data/all_games.csv')
write.csv(all_events, 'data/all_events.csv')
