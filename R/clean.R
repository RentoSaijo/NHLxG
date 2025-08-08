# Load library.
suppressMessages(library(tidyverse))
library(rsample)

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
calculate_time <- function(period, clock) {
  (period-1)*1200 + (1200-clock)
}

# Calculate shot distance and angle, goal-differential, and time for model 1.
espn_shots_1 <- espn_shots_extra %>% 
  filter(team!='O') %>% 
  filter(strength!='EN' & strength!='PS') %>% 
  mutate(
    x=abs(x),
    distance=calculate_distance(x, y),
    angle=calculate_angle(x, y),
    dG=calculate_dG(home_score, away_score, team),
    time=calculate_time(period, clock)
  ) %>% 
  select(
    event,
    goal,
    distance,
    angle,
    type,
    height,
    weight,
    hand,
    time,
    strength,
    dG,
    team
  )

# Split into train and test sets.
split_1 <- rsample::group_initial_split(espn_shots_1, group=event, prop=0.8)
train_1 <- training(split_1) %>% 
  select(-event)
test_1  <- testing(split_1) %>% 
  select(-event)

# Export `train_1` and `test_1`.
write_csv(train_1, 'data/model/train_1.csv')
write_csv(test_1, 'data/model/test_1.csv')
