# Load library.
library(tidyverse)

# Read data.
games <- read.csv('data/games.csv')
events <- read.csv('data/events.csv')

# Set helpers.
encode_espn_strength <- function(strength) {
  case_when(
    strength=='Even Strength'~'ES',
    strength=='Power Play'~'PP',
    strength=='Shorthanded'~'SH',
    TRUE~NA_character_
  )
}
get_espn_all_pbps <- function(events) {
  events %>% 
    pmap_dfr(function(season, id) {
      pbp <- get_espn_event_play_by_play(id)
      if (nrow(pbp)==0) {
        return(tibble(
          season=integer(), 
          event=integer(),
          id=character(),
          away_score=integer(),
          home_score=integer(),
          participants=list(),
          type=character(),
          period=integer(),
          clock=integer(),
          x=integer(),
          y=integer(),
          team=character(),
          strength=character(),
          shot=character()
        ))
      }
      tibble(
        season=season,
        event=id,
        id=pbp$id,
        away_score=pbp$awayScore,
        home_score=pbp$homeScore,
        participants=pbp$participants,
        type=pbp$`type.text`,
        period=pbp$`period.number`,
        clock=pbp$`clock.value`,
        x=pbp$`coordinate.x`,
        y=pbp$`coordinate.y`,
        team=pbp$`team.$ref`,
        strength=pbp$`strength.text`,
        shot=pbp$`shotInfo.text`
      )
    })
}

# Get ESPN play-by-plays.
espn_pbps <- get_espn_all_pbps(events)
espn_pbps_copy <- espn_pbps
espn_pbps_copy <- espn_pbps_copy %>% 
  select(-participants)

# Export `espn_pbps`.
write.csv(espn_pbps_copy, 'data/espn_pbps_no_participants.csv', row.names=FALSE)
