# NHLxG

### Overview



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
3. Retrieve a data frame of all the plays from all the above games. I used 
`get_espn_event_play_by_play()` from `nhlscraper` and grabbed what I determined 
to potentially be the useful information from each play: `sequence`, `text`, 
`away_score`, `home_score`, `participants`, `type`, `period`, `clock`, `x` 
coordinate, `y` coordinate, team, and `strength` state. Since `participants` 
were all `list` classes, I needed to flatten them out using `jsonlite` so that 
they can be written to a `CSV`.
4. 
