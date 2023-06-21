### EXPLORATORY DATA ANALYSIS ###

library(tidyverse)
diamonds %>% 
  count(cut)
smaller <- diamonds %>% 
  filter(carat < 3)

ggplot(data = smaller, mapping = aes(x = carat)) +
  geom_histogram(binwidth = 0.1)
ggplot(data = smaller, mapping = aes(x = carat)) +
  geom_histogram(binwidth = 0.01)

# look at outliers (variation within a variable)
ggplot(diamonds) + 
  geom_histogram(mapping = aes(x = y), binwidth = 0.5)
ggplot(diamonds) + 
  geom_histogram(mapping = aes(x = y), binwidth = 0.5) +
  coord_cartesian(ylim = c(0, 50))
unusual <- diamonds %>% 
  filter(y < 3 | y > 20) %>% 
  select(price, x, y, z) %>%
  arrange(y)
unusual

# replace outlier values (y < 3 | y > 20) with NA, otherwise keep y as y
diamonds2 <- diamonds %>% 
  mutate(y = ifelse(y < 3 | y > 20, NA, y))

# look at cancelled flights (have NA, missing departure time)
nycflights13::flights %>% 
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100,
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + sched_min / 60
  ) %>% 
  ggplot(mapping = aes(sched_dep_time)) + 
  geom_freqpoly(mapping = aes(colour = cancelled), binwidth = 1/4)

# covariation btwn a categorical variable & a continuous variable
ggplot(data = mpg) +
  geom_boxplot(mapping = aes(x = reorder(class, hwy, FUN = median), y = hwy))

library(nycflights13)
nycflights13::flights

ggplot(data = flights) + 
  geom_boxplot(mapping = aes(x = is.na(dep_time), y = sched_dep_time)) + 
  coord_flip()

# covariation btwn 2 categorical variables
ggplot(data = diamonds) +
  geom_count(mapping = aes(x = cut, y = color))

diamonds %>% 
  count(color, cut) %>%  
  ggplot(mapping = aes(x = color, y = cut)) +
  geom_tile(mapping = aes(fill = n))

flights %>% 
  count(month, dest, dep_delay) %>%
  ggplot(mapping = aes(x = month, y = dest)) +
  geom_tile(mapping = aes(fill = dep_delay))

# covariation btwn 2 continous variables
ggplot(data = diamonds) +
  geom_point(mapping = aes(x = carat, y = price))
ggplot(data = smaller) +
  geom_bin2d(mapping = aes(x = carat, y = price))

# install.packages("hexbin")
ggplot(data = smaller) +
  geom_hex(mapping = aes(x = carat, y = price))
