# Load library.
suppressMessages(library(tidyverse))

# Set helpers.
encode_espn_strength <- function(strength) {
  case_when(
    strength=='Even Strength'~'ES',
    strength=='Power Play'~'PP',
    strength=='Shorthanded'~'SH',
    strength=='Empty Net'~'EN'
    TRUE~NA_character_
  )
}
  