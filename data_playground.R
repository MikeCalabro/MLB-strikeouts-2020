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

