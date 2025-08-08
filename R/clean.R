# Load library.
suppressMessages(library(tidyverse))

# Read data.
espn_shots_extra <- read_csv(
  'data/espn_shots_extra.csv',
  col_types=cols(
    id=col_character(),
    .default=col_guess()
  )
)

# Set helpers.
calculate_distance <- function(x, y) {
  dx <- 89-x
  dy <- 0-y
  sqrt(dx^2 + dy^2)
}
calculate_angle <- function(x, y) {
  vx <- x-89
  vy <- y-0
  cos_theta <- -(vx) / sqrt(vx^2 + vy^2)
  cos_theta <- pmin(pmax(cos_theta, -1), 1)
  acos(cos_theta) * 180/pi
}
calculate_dG <- function(home_score, away_score, team) {
  case_when(
    team=='H'~home_score-away_score,
    team=='A'~away_score-home_score,
    TRUE~NA_integer_
  )
}

# Calculate shot distance and angle and goal-differential for model 1
espn_shots_1 <- espn_shots_extra %>% 
  filter(team!='O') %>% 
  filter(strength!='EN' & strength!='PS') %>% 
  mutate(
    x=abs(x),
    distance=calculate_distance(x, y),
    angle=calculate_angle(x, y),
    dG=calculate_dG(home_score, away_score, team)
  )

# Export `espn_shots_1`.
write_csv(espn_shots_1, 'data/model/espn_shots_1.csv')
