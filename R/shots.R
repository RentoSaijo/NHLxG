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
encode_shot_type <- function(text) {
  case_when(
    grepl('Wrist', text)~'wrist',
    grepl('Snap', text)~'snap',
    grepl('Slap', text)~'slap',
    grepl('Tip-In', text)~'tip',
    grepl('Backhand', text)~'backhand',
    grepl('Wrap-around', text)~'wrap',
    grepl('Batted', text)~'bat',
    grepl('Poke', text)~'poke',
    grepl('Deflected', text)~'deflect',
    grepl('Between Legs', text)~'between',
    grepl('Cradle', text)~'cradle',
    TRUE~'other'
  )
}

# Read data.
espn_pbps <- readr::read_csv(
  'data/espn_pbps.csv',
  col_types=cols(
    id=col_character(),
    .default=col_guess()
  )
)

# Only leave shots.
espn_shots <- espn_pbps %>% 
  filter(type=='Shot' | type=='Goal') %>% 
  mutate(goal=play_type_to_goal_boolean(type)) %>% 
  select(-type) %>% 
  mutate(type=encode_shot_type(text)) %>% 
  filter(type!='other') %>% 
  filter(!is.na(x) & !is.na(y))

# Export `espn_shots`.
write_csv(espn_shots, 'data/espn_shots.csv')
