# Data Playground
# A Place for me to experiment with different tables and plots
# 
# Sorry for the lack of comments - I might add them later, but this is more-so
# a place for me to go ultra focus in experimentation of functions/queries

library(tidyverse)
library(RSQLite)
library(DBI)
library(kableExtra)

# The code below shows my process of acquiring the baseball savant data

library(baseballr)

test_view <- scrape_statcast_savant_batter_all(start_date = "2018-05-01",
                                  end_date = "2018-05-02")

advanced_stats <- function(year) {
  return(
    scrape_statcast_savant_batter_all(start_date = sprintf("%s-05-01", year),
                                      end_date = sprintf("%s-05-07", year)) %>%
      select(pitch_type,
             release_speed,
             game_year,
             launch_speed,
             launch_angle,
             events)
  )
}

pitch_2008 <- advanced_stats("2008")
pitch_2009 <- advanced_stats("2009")
pitch_2010 <- advanced_stats("2010")
pitch_2011 <- advanced_stats("2011")
pitch_2012 <- advanced_stats("2012")
pitch_2013 <- advanced_stats("2013")
pitch_2014 <- advanced_stats("2014")
pitch_2015 <- advanced_stats("2015")
pitch_2016 <- advanced_stats("2016")
pitch_2017 <- advanced_stats("2017")
pitch_2018 <- advanced_stats("2018")
pitch_2019 <- advanced_stats("2019")


full_savant_data <- pitch_2008 %>%
  full_join(pitch_2009) %>%
  full_join(pitch_2010) %>%
  full_join(pitch_2011) %>%
  full_join(pitch_2012) %>%
  full_join(pitch_2013) %>%
  full_join(pitch_2014) %>%
  full_join(pitch_2015) %>%
  full_join(pitch_2016) %>%
  full_join(pitch_2017) %>%
  full_join(pitch_2018) %>%
  full_join(pitch_2019) %>%
  arrange(desc(game_year))

# write.csv / write.table kept messing up becasue of all the NA's for launch stats
# Which is why I had to arrange by year to get the 2019 to the top

glimpse(full_savant_data)

write.table(full_savant_data, sep=" ",
            file="full_savant_data.txt",
            row.names=FALSE,
            na = "NA")

write.csv(full_savant_data,
          file="full_savant_data.csv",
          row.names=FALSE,
          na = "NA")

#The code below shows some experimentation with the baseball savant data





event_list <- c("field_out", "single", "double", "triple", "home_run")

full_savant_data %>%
  filter(launch_speed > 0) %>%
  filter(events %in% event_list) %>%
  ggplot(aes(x = factor(events, level = event_list))) +
  geom_violin(aes(y = launch_speed, color = events),
              draw_quantiles = 0.5) +
  ylim(60, 120)

full_savant_data %>%
  filter(launch_speed > 0) %>%
  filter(events %in% event_list) %>%
  ggplot(aes(x = launch_speed)) +
  geom_freqpoly(aes(color = events))


full_savant_data %>%
  filter(launch_speed > 0) %>%
  ggplot(aes(x = launch_speed)) +
  geom_freqpoly(aes(color = factor(game_year)))

full_savant_data %>%
  filter(launch_speed > 50) %>%
  ggplot(aes(x = factor(game_year))) +
  geom_violin(aes(y = launch_speed), draw_quantiles = 0.5, scale = "count") 







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






# The code below shows some experimentation with certain queries

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




