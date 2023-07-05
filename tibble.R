### TIBBLES ###

# Tibbles are data frames, but they tweak some older behaviours to make 
# life a little easier

install.packages("tidyverse")
library(tidyverse)

# as_tibble() changes a dataframe to a tabble
as_tibble(iris)

# create a new tibble from individual vectors with tibble()
tibble(
  x = 1:5, 
  y = 1, 
  z = x ^ 2 + y
)

# Another way to create a tibble is with tribble(), short for transposed tibble
# tribble() is customised for data entry in code: column headings are defined
# by formulas (i.e. they start with ~), and entries are separated by commas

tribble(
  ~x, ~y, ~z,
  #--|--|----
  "a", 2, 3.6,
  "b", 1, 8.5
)

# Tibbles have a refined print method that shows only the first 10 rows
# you can explicitly print() the data frame and control the number of rows (n)
# and the width of the display
nycflights13::flights %>% 
  print(n = 10, width = Inf)

# scrollable view of whole dataset using view()
nycflights13::flights %>% 
  View()

# [[ can extract by name or position; $ only extracts by name 
df <- tibble(
  x = runif(5),
  y = rnorm(5)
)

# Extract by name
df$x
#> [1] 0.73296674 0.23436542 0.66035540 0.03285612 0.46049161
df[["x"]]
#> [1] 0.73296674 0.23436542 0.66035540 0.03285612 0.46049161

# Extract by position
df[[1]]
#> [1] 0.73296674 0.23436542 0.66035540 0.03285612 0.46049161

# To use these in a pipe, you’ll need to use the special placeholder .
df %>% .$x
#> [1] 0.73296674 0.23436542 0.66035540 0.03285612 0.46049161
df %>% .[["x"]]
#> [1] 0.73296674 0.23436542 0.66035540 0.03285612 0.46049161

# --------------------------------------------

# EXERCISES
df <- data.frame(abc = 1, xyz = "a")
df$x
df[, "xyz"]
df[, c("abc", "xyz")]

annoying <- tibble(
  `1` = 1:10,
  `2` = `1` * 2 + rnorm(length(`1`))
)
annoying$`1`
ggplot(data = annoying) + 
  geom_point(mapping = aes(x = `1`, y = `2`))
