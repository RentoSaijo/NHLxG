suppressMessages(library(tidyverse))
library(jsonlite)
espn_pbps_copy <- espn_pbps
espn_pbps_flat <- espn_pbps_copy %>% 
  mutate(
    participants=map_chr(participants, function(x) {
      if (length(x)==0) {
        return(NA_character_)
      }
      toJSON(x, auto_unbox=TRUE)
    })
  )
