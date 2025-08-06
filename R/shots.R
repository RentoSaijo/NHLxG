# Load library.
suppressMessages(library(tidyverse))
library(nhlscraper)

# Set helpers.
play_type_to_goal_boolean <- function(play_type) {
  case_when(
    play_type=='Goal'~1,
    play_type=='Shot'~0,
    TRUE~NA_integer_
  )
}

# Read data.
test <- get_espn_event_play_by_play(401777460)
test_flat <- test %>% 
  mutate(
    participants=map_chr(participants, function(x) {
      if (length(x)==0) {
        return(NA_character_)
      }
      toJSON(x, auto_unbox=TRUE)
    })
  )
espn_pbps <- read.csv('data/espn_pbps.csv')

# Only leave shots.
test_shots <- test_flat %>% 
  filter(type.text=='Shot' | type.text=='Goal') %>% 
  mutate(goal=play_type_to_goal_boolean(type.text)) %>% 
  select(-type.text)
espn_pbps <- espn_pbps %>% 
  filter(type=='Shot' | type=='Goal') %>% 
  mutate(goal=play_type_to_goal_boolean(type)) %>% 
  select(-type)
