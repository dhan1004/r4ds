### ITERATION

library(tidyverse)
library(nycflights13)

# FOR-LOOP ---------------------------------------------------------------------

df <- tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d= rnorm(10)
)

# every for loop has 3 components:
# output: must allocate sufficient space for output before loop using vector()
#   1st argument is type of vector, 2nd is length of vector
# sequence: determines what to loop over, use seq_along()
# body: code that does work!
output <- vector("double", ncol(df))  # 1. output
for (i in seq_along(df)) {            # 2. sequence
  output[[i]] <- median(df[[i]])      # 3. body
}
output

# FOR LOOP VARIATIONS ----------------------------------------------------------

# can use a for loop to modify an existing object (same output as input)
df <- tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}
for (i in seq_along(df)) {
  df[[i]] <- rescale01(df[[i]])
}

# can loop over elements of a vector using for (x in xs)
# can loop over names of a vector using for (nm in names(xs))
results <- vector("list", length(x))
names(results) <- names(x)

# if for loop will have an unknown output length, best runtime is to save 
# results to a list, then combine into a single vector after loop is done
means <- c(0, 1, 2)
out <- vector("list", length(means))
for (i in seq_along(means)) {
  n <- sample(100, 1)
  out[[i]] <- rnorm(n, means[[i]])
}
str(out)
str(unlist(out))

# use a while loop when input sequence length is unknown
# only has 2 parts: condition & body
flip <- function() sample(c("T", "H"), 1)

flips <- 0
nheads <- 0

while (nheads < 3) {
  if (flip() == "H") {
    nheads <- nheads + 1
  } else {
    nheads <- 0
  }
  flips <- flips + 1
}
flips

# FOR LOOPS VS FUNCTIONALS -----------------------------------------------------

# R is a functional programming language, so many for loops get wrapped in fxns
df <- tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)

# you could write a for loop for computing the mean, then put it into a fxn
col_mean <- function(df) {
  output <- vector("double", length(df))
  for (i in seq_along(df)) {
    output[i] <- mean(df[[i]])
  }
  output
}

# if you want to use the for loop for fxns like median, it's easier to write a
# function that takes in the math fxn as an argument
col_summary <- function(df, fun) {
  out <- vector("double", length(df))
  for (i in seq_along(df)) {
    out[i] <- fun(df[[i]])
  }
  out
}
col_summary(df, median)

# MAP FUNCTIONS ----------------------------------------------------------------

# purrr package provides map() functions that loop over a vector, do smth to 
# each element, & save results (ie. map(), map_lgl(), map_int(), etc)
map_dbl(df, mean)

# the second argument, .f, is the function to apply and has various shortcuts
# ie. if you want to split up the mtcars df and apply a linear model to each
models <- mtcars %>% 
  split(.$cyl) %>% 
  map(function(df) lm(mpg ~ wt, data = df))
# shortcut:
models <- mtcars %>% 
  split(.$cyl) %>% 
  map(~lm(mpg ~ wt, data = .))

# you can extract named components using a string
models %>% 
  map(summary) %>% 
  map_dbl("r.squared")

# safely() function helps to return results even with failures

# MAPPING OVER MULTIPLE ARGUMENTS ----------------------------------------------

# map2 iterates over two vectors in parallel
# ie. if you want to vary the mean AND std dev of random samples:
mu <- list(5, 10, -3)
sigma <- list(1, 5, 10)
# arguments that vary for the function come before the fxn, constants come after
map2(mu, sigma, rnorm, n = 5) %>% str()

# pmap iterates over p vectors in parallel
n <- list(1, 3, 5)
args1 <- list(n, mu, sigma)
args1 %>%
  pmap(rnorm) %>% 
  str()

# can store arguments of same length in a data frame
params <- tribble(
  ~mean, ~sd, ~n,
  5,     1,  1,
  10,     5,  3,
  -3,    10,  5
)
params %>% 
  pmap(rnorm)

# can vary functions being called using invoke_map()
f <- c("runif", "rnorm", "rpois")
param <- list(
  list(min = -1, max = 1), 
  list(sd = 5), 
  list(lambda = 10)
)
invoke_map(f, param, n = 5) %>% str()

# WALK -------------------------------------------------------------------------

# walk is used when you are calling a function for its side effects, not return
x <- list(1, "a", 3)
x %>% 
  walk(print)

# walk2() and pwalk() acts on multiple vectors in tandem
library(ggplot2)
plots <- mtcars %>% 
  split(.$cyl) %>% 
  map(~ggplot(., aes(mpg, wt)) + geom_point())
paths <- stringr::str_c(names(plots), ".pdf")

pwalk(list(paths, plots), ggsave, path = tempdir())

# OTHER PATTERNS FOR LOOPS -----------------------------------------------------

# predicate fxns return a single true or false
# keep()/discard() keep elements where the predicate is TRUE/FALSE
iris %>% 
  keep(is.factor) %>% 
  str()
iris %>% 
  discard(is.factor) %>% 
  str()

# some() and every() determine if the predicate is true for any/all elements
x <- list(1:5, letters, list(10))
x %>% 
  some(is_character)
x %>% 
  every(is_vector)

# reduce() takes a “binary” function (i.e. a function with two primary inputs)
# and applies it repeatedly to a list until there is only a single element left
vs <- list(
  c(1, 3, 5, 6, 10),
  c(1, 2, 3, 7, 8, 10),
  c(1, 2, 3, 4, 8, 9, 10)
)
vs %>% reduce(intersect)

# accumulate() is similar but it keeps all the interim results
x <- sample(10)
x
x %>% accumulate(`+`)

# EXERCISES --------------------------------------------------------------------

mtcars
output <- vector("double", ncol(mtcars))
names(output) <- names(mtcars) 
for (i in names(mtcars)) {
  output[i] <- mean(mtcars[[i]])
}
output

output <- vector("list", ncol(nycflights13::flights))
names(output) <- names(nycflights13::flights)
for (i in names(nycflights13::flights)) {
  output[[i]] <- class(nycflights13::flights[[i]])
}
output

output <- vector("double", ncol(iris))
names(output) <- names(iris)
for (i in names(iris)) {
  output[i] <- n_distinct(iris[[i]])
}
output

n <- 10
mu <- c(-10, 0, 10, 100)
output <- vector("list", length(mu))
for (i in seq_along(output)) {
  output[[i]] <- rnorm(n, mean = mu[i])
}
output

df <- iris

output <- vector("double", ncol(df))
names(output) <- names(df)
for (i in names(df)) {
  if (is.numeric(df[[i]])) {
    output[i] <- mean(df[[i]])
  }
}
output

map_dbl(mtcars, mean)

map_chr(nycflights13::flights, typeof)

map_int(iris, n_distinct)

map(c(-10, 0, 10, 100), ~rnorm(n = 10, mean = .))

map_lgl(diamonds, is.factor)

map(x, ~lm(mph ~ wt, data = .))
