### TIDY DATA ###

library(tidyverse)

# There are three interrelated rules which make a dataset tidy:
# Each variable must have its own column.
# Each observation must have its own row.
# Each value must have its own cell.

# In practice:
# Put each dataset in a tibble.
# Put each variable in a column.

table1 # example of tidy table
#> # A tibble: 6 × 4
#>   country      year  cases population
#>   <chr>       <int>  <int>      <int>
#> 1 Afghanistan  1999    745   19987071
#> 2 Afghanistan  2000   2666   20595360
#> 3 Brazil       1999  37737  172006362
#> 4 Brazil       2000  80488  174504898
#> 5 China        1999 212258 1272915272
#> 6 China        2000 213766 1280428583

# PIVOTING ---------------------------------------------------------------------

# pivot columns that have names which have names that are values of variables
# into new pair of variables

# eg. move columns "1999" and "2000" into year & cases columns w/ pivot_longer
# pivot_longer() makes datasets longer by increasing the number of rows and 
# decreasing the number of columns
tidy4a <- table4a %>% 
  pivot_longer(c(`1999`, `2000`), names_to = "year", values_to = "cases")

table4b
tidy4b <- table4b %>% 
  pivot_longer(c(`1999`, `2000`), names_to = "year", values_to = "population")
tidy4b

# combine 2 tables
left_join(tidy4a, tidy4b)

# use pivot_wider() when an observation is scattered across multiple rows
table2 %>%
  pivot_wider(names_from = type, values_from = count)

# SEPARATING & UNITING ---------------------------------------------------------

# separate() pulls apart one column into multiple columns
# splits wherever a separator character appears
table3 %>% 
  separate(rate, into = c("cases", "population"))

# separate() uses non alpha-numeric characters to split on by default
# can specify split character
table3 %>% 
  separate(rate, into = c("cases", "population"), sep = "/")

# separate() leaves column types as is
# can convert by using convert = TRUE
table3 %>% 
  separate(rate, into = c("cases", "population"), convert = TRUE)

# passing vector of integers into separate() will be interpreted
# index positions to split at
table3 %>% 
  separate(year, into = c("century", "year"), sep = 2)

# unite() combines multiple columns into a single column
table5 %>% 
  unite(new, century, year)

# default includes underscore between joined values, so use sep = ""
table5 %>% 
  unite(new, century, year, sep = "")

# MISSING VALUES ---------------------------------------------------------------

# values can be missing explicitly (NA in data) or implictly (simply not there)
stocks <- tibble(
  year   = c(2015, 2015, 2015, 2015, 2016, 2016, 2016),
  qtr    = c(   1,    2,    3,    4,    2,    3,    4),
  return = c(1.88, 0.59, 0.35,   NA, 0.92, 0.17, 2.66)
)

# make implicit missing values explicit by passing them in columns
stocks %>% 
  pivot_wider(names_from = year, values_from = return)

# set values_drop_na = TRUE in pivot_longer() 
# to turn explicit missing values implicit
stocks %>% 
  pivot_wider(names_from = year, values_from = return) %>% 
  pivot_longer(
    cols = c(`2015`, `2016`), 
    names_to = "year", 
    values_to = "return", 
    values_drop_na = TRUE
  )

# complete() takes a set of columns, and finds all unique combinations
# ensures original dataset contains all values & fills in explicit NAs
stocks %>% 
  complete(year, qtr)

# NAs can sometime mean that data from previous row is carried over
treatment <- tribble(
  ~ person,           ~ treatment, ~response,
  "Derrick Whitmore", 1,           7,
  NA,                 2,           10,
  NA,                 3,           9,
  "Katherine Burke",  1,           4
)

# fill() fills in NAs by taking most recent non-NA value
treatment %>% 
  fill(person, .direction = "down")

# CASE STUDY -------------------------------------------------------------------

# organize who dataset so that new_sp_m014 column onwards get combined
who1 <- who %>% 
  pivot_longer(
    cols = new_sp_m014:newrel_f65, 
    names_to = "key", 
    values_to = "cases", 
    values_drop_na = TRUE
  )

# key names: 1st three letters denotes new/old cases
# next 2 letters describe rel (relapse), ep (extrapulmonary), 
# sn (smear negative), sp (smear positive)
# 6th letter is sex of patient
# remaining numbers denote age group

# replace newrel with new_rel so names are consistent
who2 <- who1 %>% 
  mutate(key = stringr::str_replace(key, "newrel", "new_rel"))
who2

# separate values in keys
who3 <- who2 %>% 
  separate(key, c("new", "type", "sex_age"), sep = "_")
who3

# drop new column, iso2, & iso3
who4 <- who3 %>% 
  select(-new, -iso2, -iso3)
who4

# full complex pipeline:
who %>%
  pivot_longer(
    cols = new_sp_m014:newrel_f65, 
    names_to = "key", 
    values_to = "cases", 
    values_drop_na = TRUE
  ) %>% 
  mutate(
    key = stringr::str_replace(key, "newrel", "new_rel")
  ) %>%
  separate(key, c("new", "var", "sexage")) %>% 
  select(-new, -iso2, -iso3) %>% 
  separate(sexage, c("sex", "age"), sep = 1)

# EXERCISES --------------------------------------------------------------------

table2
table2_cases <- filter(table2, type == "cases")
table2_population <- filter(table2, type == "population")
table2 %>% mutate(rate = (table2_cases$count/table2_population$count) * 10000)

table3

table4a
table4b

preg <- tribble(
  ~pregnant, ~male, ~female,
  "yes",     NA,    10,
  "no",      20,    12
)
preg %>% pivot_longer(c(male, female), names_to = "sex", values_to = "count")

