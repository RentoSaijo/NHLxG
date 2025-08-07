# NHLxG

### Overview

This is a work-in-progress expected-goals (xG) model for the NHL. The logistic 
regression is trained and tested on ~160,000 shots, from the 2023-2024 and 
2024-2025 seasons, downloaded via [nhlscraper](https://rentosaijo.github.io/nhlscraper/).

### Process

There are mainly 3 publicly available sources of play-by-plays: GameCenter 
(acquirable via the NHL API), World Showcase (also acquirable via the NHL API), 
and ESPN (acquirable via the ESPN API). For each of these sources, the wrangling 
process looks a little different, but the core remains the same. I will begin 
with the ESPN ones as the other two seems to be in maintenance.

#### Wrangling for ESPN Play-by-play

1. Manually determine which season they began tracking play-by-plays. The answer 
was the 2007-2008 season for most play types (before then, only goals and 
penalties were tracked for a while). However, beginning in the 2022-2023 
season, they started adding the column `text` for concise annotations; this is 
crucial as beginning in the 2023-2024 season, all shots are annotated with their 
respective shot types (wrist, snap, slap, etc.). Therefore, for this project, I 
determined that play-by-plays from the 2023-2024 season onward were viable. Even 
though this may seem like a small sample size, don't worry as even just 2 
seasons worth of play-by-plays contain ~160000 shots.
2. Retrieve a list of all the Event IDs from the 2023-2024 to 2024-2025 
seasons. I used `get_espn_events()` from `nhlscraper` and some `stringr` 
extraction to retrieve them.
3. Retrieve a `data.frame` of all the plays from all the above games. I used 
`get_espn_event_play_by_play()` from `nhlscraper` and grabbed what I determined 
to potentially be the useful information from each play: `sequence`, `text`, 
`away_score`, `home_score`, `participants`, `type`, `period`, `clock`, `x` and 
`y` coordinates, team, and `strength` state. Since `participants` were all 
`list` classes, I needed to flatten them out using `jsonlite` so that they can 
be written to a `CSV`, which can be downloaded in `data/espn_pbps.csv`.
4. Filter to leave only `Shot` and `Goal` play `type`. With some help from 
`tidyverse`, I quickly filtered out all the other plays (although, in future 
more-complex models, I want to include some, if not, all the other plays as 
exploring sequential patterns may improve the model), encoded shot `type` using
`grepl()` from base `R`, and filtered out 2 rows that were somehow missing `x` and 
`y` coordinates. The complete `CSV` can be downloaded in `data/espn_shots.csv`.
5. Retrieve extra information on each shot. Based on `participants` and `team`, 
I wanted to grab the following extra information: shooter's `height`, `weight`, 
`hand` (handedness), `position`, and whether his `team` was home, away, or other 
(neutral site). I used `get_espn_athlete()` and `get_espn_event()` from 
`nhlscraper` and `case_when()` (switch-case) from base `R` to handle these. The 
complete `CSV` can be downloaded in `data/espn_shots_extra.csv`.

*I highly recommend you to download the `CSV` files instead of running the `R` 
scripts as some of these data mining processes take a long time (12+ hours)!
