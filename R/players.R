# Load library.
suppressMessages(library(tidyverse))
library(nhlscraper)

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
