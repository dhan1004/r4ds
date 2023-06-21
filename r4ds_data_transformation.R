### DATA TRANSFORMTION ###

library(tidyverse)
install.packages("nycflights13")
library(nycflights13)

nycflights13::flights

# dplyr functions: 1st argument is data frame, 2nd argument is what to do w/ 
# data frame, using variable names w/o quotes => new data frame
jan1 <- filter(flights, month == 1, day == 1)

# use near() to compare floating numbers instead of "=="
near(sqrt(2) ^ 2,  2)
#> [1] TRUE
near(1 / 49 * 49, 1)
#> [1] TRUE

# missing values (aka NAs) are usually excluded by filter() unless explicitely
# asked for
df <- tibble(x = c(1, NA, 3))
filter(df, x > 1)
#> # A tibble: 1 × 1
#>       x
#>   <dbl>
#> 1     3
filter(df, is.na(x) | x > 1)
#> # A tibble: 2 × 1
#>       x
#>   <dbl>
#> 1    NA
#> 2     3

# arrange() works similarly to filter() except that instead of selecting rows, 
# it changes their order
arrange(flights, year, month, day)

# select helper functions: starts_with("abc"), ends_with("xyz"), contains("ijk"),
# matches("(.)\\1"), num_range("x", 1:3)

# rename() allows for renaming of variables
rename(flights, tail_num = tailnum)

# everything() helper is useful when you want to move some variables to the front
select(flights, time_hour, air_time, everything())

# mutate() adds new columns that are functions of exisiting columns
flights_sml <- select(flights, 
                      year:day, 
                      ends_with("delay"), 
                      distance, 
                      air_time
)
mutate(flights_sml,
       gain = dep_delay - arr_delay,
       hours = air_time / 60,
       gain_per_hour = gain / hours
)

# transmute allows you to keep only new variables
transmute(flights,
          gain = dep_delay - arr_delay,
          hours = air_time / 60,
          gain_per_hour = gain / hours
)

# summarize() collapses a dataframe to a single row
by_day <- group_by(flights, year, month, day)
summarise(by_day, delay = mean(dep_delay, na.rm = TRUE))
#> `summarise()` has grouped output by 'year', 'month'. You can override using the
# data frame grouped by date => get the average delay per date

# na.rm is removes missing values

# _________________________________________

# EXERCISES

filter(flights, arr_delay >= 120)
filter(flights, dest == "IAH" | dest == "HOU")
filter(flights, carrier %in% c("UA", "AA", "DL"))
filter(flights, month %in% c(7, 8, 9))
filter(flights, dep_delay == 0 & arr_delay > 120)
filter(flights, dep_delay >= 60 & arr_delay <= dep_delay - 30)
filter(flights, dep_time >= 0000 & dep_time <= 0600)
filter(flights, between(dep_time, 0000, 0600)) # same as above line of code
filter(flights, is.na(dep_time))

arrange(flights, desc(is.na(flights)))
arrange(flights, desc(dep_delay))

vars <- c("year", "month", "day", "dep_delay", "arr_delay")
select(flights, any_of(vars))
select(flights, contains("TIME"))

mutate(flights, dep_time = (dep_time %/% 100) + (dep_time %% 100))

flights %>% group_by(carrier) %>% summarize(n())
flights %>% group_by(tailnum) %>% arrange(arr_delay)
flights %>% group_by(hour) %>% filter(rank(desc(arr_delay)) < 10)
