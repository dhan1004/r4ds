### RELATIONAL DATA

# relational data: multiple tables of data
# filtering join:  filter observations from one data frame based on whether or 
# not they match an observation in the other table
# set operations: treat observations as if they were set elements

library(tidyverse)
library(nycflights13)

# airlines: full carrier name & abbreviated name
airlines

# airports: info about each airport, identified by faa code
airports

# planes: info about each plane, identified by tailnum
planes

# weather: weather at each NYC airport for each hour
weather

flights

# KEYS -------------------------------------------------------------------------

# keys: variables used to connect each pair of tables
# primary key: uniquely identifies variable in its own table (ie planes$tailnum)
# foreign key: uniquely identifies observation in another table

# verify primary keys by count() primary keys & look for entries with n > 2
planes %>% 
  count(tailnum) %>% 
  filter(n > 1)
#> # A tibble: 0 × 2
#> # … with 2 variables: tailnum <chr>, n <int>

weather %>% 
  count(year, month, day, hour, origin) %>% 
  filter(n > 1)
#> # A tibble: 3 × 6
#>    year month   day  hour origin     n
#>   <int> <int> <int> <int> <chr>  <int>
#> 1  2013    11     3     1 EWR        2
#> 2  2013    11     3     1 JFK        2
#> 3  2013    11     3     1 LGA        2

# surrogate key: added key that makes it easier to match observations
# primary key and corresponding foreign key (usually one-to-many) form relation

# MUTATING JOIN ----------------------------------------------------------------

# mutating join: matches observations in 2 data frames by keys then copies 
# variables from one table to another

# create smaller dataset
flights2 <- flights %>% 
  select(year:day, hour, origin, dest, tailnum, carrier)
flights2
# add full airline name using left_join
flights2 %>%
  select(-origin, -dest) %>% 
  left_join(airlines, by = "carrier")
# add full airline name using mutate()
flights2 %>%
  select(-origin, -dest) %>% 
  mutate(name = airlines$name[match(carrier, airlines$carrier)])

x <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  3, "x3"
)
y <- tribble(
  ~key, ~val_y,
  1, "y1",
  2, "y2",
  4, "y3"
)

# inner join matches pairs of observations whenever keys are equal
# results in new dataframe with key, x values, & y values 
# unmatched rows not included (keeps observations from both tables)
x %>% 
  inner_join(y, by = "key")

# outer join keeps observations that appear in at least one table
# left join keeps all in x, right join keeps all in y, full join keeps both
x %>%
  left_join(y, by = "key") # use left_join as default

# one table may have duplicate keys to match with multiple keys in other table
x <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  2, "x3",
  1, "x4"
)
y <- tribble(
  ~key, ~val_y,
  1, "y1",
  2, "y2"
)
left_join(x, y, by = "key")

# constraint of which columns to use as keys is determined by "by =" argument
# by = null uses all variables that appear in both tables
flights2 %>% 
  left_join(weather)

# by = "x" joins by a common variable "x"
flights2 %>% 
  left_join(planes, by = "tailnum")

# by = c("a" = "b") matches variable a in table x to variable b in table y
# variables from x will be used in output
flights2 %>% 
  left_join(airports, c("dest" = "faa"))
flights2 %>% 
  left_join(airports, c("origin" = "faa"))

# FILTERING JOINS --------------------------------------------------------------

# semi-join keeps all observations in x that have a match in y
top_dest <- flights %>%
  count(dest, sort = TRUE) %>%
  head(10)
top_dest
flights %>% 
  semi_join(top_dest)

# anti-join drops all observations in x that have a match in y
flights %>%
  anti_join(planes, by = "tailnum") %>%
  count(tailnum, sort = TRUE)


# EXERCISES --------------------------------------------------------------------

flight_delay_map <- 
  flights %>% 
  group_by(dest) %>% 
  summarize(delay = mean(arr_delay, na.rm = TRUE)) %>%
  inner_join(airports, by = c("dest" = "faa")) %>%
  ggplot(aes(lon, lat)) +
  borders("state") +
  geom_point(aes(color = delay)) +
  coord_quickmap()
flight_delay_map

airports_small <-
  airports %>%
  select(faa, lon, lat)
flight_loc <- 
  flights %>%
  left_join(airports_small, by = c("origin" = "faa")) %>%
  left_join(airports_small, by = c("dest" = "faa"))
view(flight_loc)

flight_weather <-
  flights %>%
  inner_join(weather, by = c(
    "origin" = "origin", 
    "year" = "year",
    "month" = "month",
    "day" = "day",
    "hour" = "hour"))
flight_weather %>% 
  group_by(visib) %>%
  summarise(mean_delay = mean(arr_delay, na.rm = TRUE)) %>%
  ggplot(aes(x = visib, y = mean_delay)) +
  geom_point()

missing <-
  flights %>%
  anti_join(planes, by = "tailnum") %>%
  group_by(carrier)
missing %>%
  summarize(count = n())

hundred <- 
  flights %>%
  group_by(tailnum) %>%
  count() %>%
  filter(n >= 100)
flights %>% 
  semi_join(hundred, by = "tailnum")

worst_delays <-
  flights %>%
  mutate(hour = sched_dep_time %/% 100) %>%
  group_by(origin, year, month, day, hour) %>%
  summarize(dep_delay = mean(dep_delay, na.rm = TRUE)) %>% 
  ungroup() %>%
  arrange(desc(dep_delay)) %>%
  slice(1:48)
weather_delays <-
  weather %>%
  semi_join(worst_delays, by = c("origin", "year", "month", "day", "hour")) %>%
  select(temp, wind_speed, precip, visib)
weather_delays %>%
  ggplot(aes(x = temp, y = precip, color = visib, size = wind_speed)) +
  geom_point()
