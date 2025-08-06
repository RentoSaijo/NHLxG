# Load libraries.
suppressMessages(library(tidyverse))
suppressMessages(library(jsonlite))
library(nhlscraper)

# Read data.
games <- read.csv('data/games.csv')
events <- read.csv('data/events.csv')

# Set helpers.
get_espn_all_pbps <- function(events) {
  events %>% 
    pmap_dfr(function(season, id) {
      pbp <- get_espn_event_play_by_play(id)
      if (nrow(pbp)==0) {
        return(tibble(
          season=integer(), 
          event=integer(),
          id=character(),
          sequence=character(),
          text=character(),
          away_score=integer(),
          home_score=integer(),
          participants=list(),
          type=character(),
          period=integer(),
          clock=integer(),
          x=integer(),
          y=integer(),
          team=character(),
          strength=character()
        ))
      }
      tibble(
        season=season,
        event=id,
        id=pbp$id,
        sequence=pbp$sequenceNumber,
        text=pbp$text,
        away_score=pbp$awayScore,
        home_score=pbp$homeScore,
        participants=pbp$participants,
        type=pbp$`type.text`,
        period=pbp$`period.number`,
        clock=pbp$`clock.value`,
        x=pbp$`coordinate.x`,
        y=pbp$`coordinate.y`,
        team=pbp$`team.$ref`,
        strength=pbp$`strength.text`
      )
    })
}
flatten_espn_participants <- function(espn_pbps) {
  espn_pbps %>% 
    mutate(
      participants=map_chr(participants, function(x) {
        if (length(x)==0) {
          return(NA_character_)
        }
        toJSON(x, auto_unbox=TRUE)
      })
    )
}

# Get ESPN play-by-plays.
espn_pbps <- get_espn_all_pbps(events)
espn_pbps_copy <- espn_pbps
espn_pbps_flat <- flatten_espn_participants(espn_pbps_copy)
