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






dbDisconnect(con)

