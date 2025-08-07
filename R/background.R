# Load libraries.
suppressMessages(library(tidyverse))
library(nhlscraper)
library(stringr)

# Read data.
espn_shots <- readr::read_csv(
  'data/espn_shots.csv',
  col_types=cols(
    id=col_character(),
    .default=col_guess()
  )
)

# Set helpers.
extract_espn_athlete <- function(participants) {
  as.integer(str_match(participants, '"playerId":(\\d+)')[,2])
}
get_espn_athlete_info <- function(shooter, season) {
  athlete <- get_espn_athlete(shooter, season)
  paste0(
    'height=',
    athlete$height, 
    ', weight=',
    athlete$weight, 
    ', hand=',
    athlete$hand$abbreviation, 
    ', position=',
    athlete$position$abbreviation
  )
}
extract_espn_team_id <- function(href) {
  team <- str_extract(href, '(?<=/teams/)\\d+')
  as.integer(team)
}
get_espn_event_home_team <- function(event) {
  event <- get_espn_event(event)
  if (event$neutralSite==TRUE) {
    return(NA_integer_)
  }
  as.integer(event$competitors$id[1])
}
encode_espn_team <- function(home_team, team) {
  case_when(
    is.na(home_team)~'O',
    team==home_team~'H',
    TRUE~'A'
  )
}

# Get athlete and team information.
chunk_size <- 100
n <- nrow(espn_shots)

# prepare a fresh output file
outfile <- "data/espn_shots_extra.csv"
if (file.exists(outfile)) file.remove(outfile)

# process in chunks
for (start in seq(1, n, by = chunk_size)) {
  end <- min(start + chunk_size - 1, n)
  message("Processing rows ", start, "–", end, " …")
  
  df_chunk <- espn_shots[start:end, ]
  
  # wrap the heavy work in tryCatch
  chunk_result <- tryCatch({
    df_chunk %>%
      mutate(
        shooter = map_int(participants, extract_espn_athlete),
        season  = season %% 10000,
        info    = map2_chr(shooter, season, get_espn_athlete_info)
      ) %>%
      separate(info, into = c("height","weight","hand","position"),
               sep = ", ", remove = FALSE) %>%
      mutate(
        height   = as.integer(str_remove(height,   "^height=")),
        weight   = as.integer(str_remove(weight,   "^weight=")),
        hand     = str_remove(hand,     "^hand="),
        position = str_remove(position, "^position="),
        team     = map_int(team,   extract_espn_team_id),
        home_team= map_int(event,  possibly(get_espn_event_home_team, NA_integer_)),
        team     = encode_espn_team(home_team, team)
      ) %>%
      select(-participants, -text, -info, -home_team)
  }, error = function(e) {
    warning("Chunk ", start, "-", end, " failed: ", e$message)
    NULL
  })
  
  if (!is.null(chunk_result)) {
    # on the first chunk, write headers; thereafter append
    write_csv(chunk_result, outfile, append = file.exists(outfile))
  }
}
