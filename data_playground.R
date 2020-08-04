# Data Playground
# A Place for me to experiment with different tables and plots

library(tidyverse)
library(RSQLite)
library(DBI)
library(kableExtra)

con <- dbConnect(SQLite(), 
                 dbname = "lahmans_baseball_db.sqlite")

dbListTables(con)

tibble(dbGetQuery(con, 
                  "
                  SELECT 
                    yearID,
                    SUM(AB) AS total_at_bats,
                    SUM(SO) AS total_strikeouts,
                    SUM(HR) AS total_homeruns,
                    CAST(SUM(HR) AS FLOAT) / SUM(AB) AS homeruns_per_at_bat,
                    CAST(SUM(SO) AS FLOAT) / SUM(AB) AS strikeouts_per_at_bat
                  FROM batting
                  WHERE yearID > 2004
                  GROUP BY yearID
                  "
                  )) %>%
  ggplot(aes(x = yearID)) +
  geom_line(aes(y = strikeouts_per_at_bat,
                color = "Strikeouts Per AB"),
             size = 0.5) +
  geom_line(aes(y = homeruns_per_at_bat,
                color = "Homeruns Per AB"),
             size = 0.5)


dbGetQuery(con, 
                "
                SELECT *
                FROM people
                LIMIT 5
                ")


tibble(dbGetQuery(con,
                  "
                  SELECT
                    b.playerID,
                    p.nameFirst || ' ' || p.nameLast AS name,
                    SUM(b.HR) AS career_hr
                  FROM batting AS b
                  INNER JOIN people AS p ON p.playerID = b.playerID
                  GROUP BY b.playerID
                  ORDER BY career_hr DESC
                  LIMIT 20
                  "
                  ))

dbGetQuery(con, 
           "
           SELECT *
           FROM salaries
           ORDER BY yearID
           LIMIT 20
           ")


dbDisconnect(con)


library(baseballr)

pitch_2015 <- scrape_statcast_savant_batter_all(start_date = "2015-05-01",
                                              end_date = "2015-05-07") %>%
  select(pitch_type,
         release_speed,
         player_name,
         game_year,
         launch_speed,
         events)

event_list <- c("single", "double", "triple", "home_run")

pitch_2015 %>%
  filter(launch_speed > 0) %>%
  filter(events %in% event_list) %>%
  ggplot(aes(x = factor(events, level = event_list))) +
  geom_violin(aes(y = launch_speed, color = events),
              draw_quantiles = 0.5)

advanced_stats <- function(year) {
  return(
    scrape_statcast_savant_batter_all(start_date = sprintf("%s-05-01", year),
                                      end_date = sprintf("%s-05-07", year)) %>%
      select(pitch_type,
             release_speed,
             player_name,
             game_year,
             launch_speed,
             events)
  )
}

pitch_2016 <- advanced_stats("2016")
pitch_2017 <- advanced_stats("2017")
pitch_2018 <- advanced_stats("2018")
pitch_2019 <- advanced_stats("2019")

pitch_2014 <- advanced_stats("2014")

advanced_data <- pitch_2015 %>%
  full_join(pitch_2016) %>%
  full_join(pitch_2017) %>%
  full_join(pitch_2018) %>%
  full_join(pitch_2019)

advanced_data %>%
  filter(launch_speed > 0) %>%
  filter(events %in% event_list) %>%
  ggplot(aes(x = factor(events, level = event_list))) +
  geom_violin(aes(y = launch_speed, color = events),
              draw_quantiles = 0.5)

advanced_data %>%
  filter(pitch_type == "FF") %>%
  ggplot(aes(x = factor(game_year))) +
  geom_boxplot(aes(y = release_speed),
              draw_quantiles = 0.5)

advanced_data %>%
  group_by(game_year, events) %>%
  summarise(count = n()) %>%
  filter(events == "strikeout")

advanced_data %>%
  group_by(pitch_type, events) %>%
  summarise(count = n()) %>%
  filter(events == "strikeout")

advanced_data %>%
  group_by(game_year, pitch_type, events) %>%
  summarise(count = n()) %>%
  filter(events == "strikeout") %>%
  filter(pitch_type == "SL")

advanced_data %>%
  group_by(game_year, pitch_type) %>%
  summarise(count = n(), avg_speed = mean(release_speed)) %>%
  filter(pitch_type %in% c("SL", "FF")) %>%
  arrange(pitch_type)


