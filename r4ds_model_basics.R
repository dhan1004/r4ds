### MODELS BASICS

library(tidyverse)

library(modelr)
options(na.action = na.warn)

# SIMPLE MODEL -----------------------------------------------------------------

ggplot(sim1, aes(x, y)) + 
  geom_point()

# a linear model family (y = a_0 + a_1 * x) might be a good choice for data
models <- tibble(
  a1 = runif(250, -20, 40),
  a2 = runif(250, -5, 5)
)

ggplot(sim1, aes(x, y)) + 
  geom_abline(aes(intercept = a1, slope = a2), data = models, alpha = 1/4) +
  geom_point() 

# to find best model, can calculate vertical distance data & prediction
# first turn model family into an R function
model1 <- function(a, data) {
  a[1] + data$x * a[2]
}
model1(c(7, 1.5), sim1)

# summarize distance btwn data & prediction using RMSD
measure_distance <- function(mod, data) {
  diff <- data$y - model1(mod, data)
  sqrt(mean(diff ^ 2))
}
measure_distance(c(7, 1.5), sim1)

# use purrr to compute the distance for all models
# helper function bc measure_distance() expects model as numeric vector of 2
sim1_dist <- function(a1, a2) {
  measure_distance(c(a1, a2), sim1)
}

models <- models %>% 
  mutate(dist = purrr::map2_dbl(a1, a2, sim1_dist))
models

# overlay ten best models on the data
ggplot(sim1, aes(x, y)) + 
  geom_point(size = 2, colour = "grey30") + 
  geom_abline(
    aes(intercept = a1, slope = a2, colour = -dist), 
    data = filter(models, rank(dist) <= 10)
  )

# visualize models as a1 against a2
ggplot(models, aes(a1, a2)) +
  geom_point(data = filter(models, rank(dist) <= 10), size = 4, colour = "red") +
  geom_point(aes(colour = -dist))

# rather than use random models, could do a grid search (evely spaced points)
grid <- expand.grid(
  a1 = seq(-5, 20, length = 25),
  a2 = seq(1, 3, length = 25)
) %>% 
  mutate(dist = purrr::map2_dbl(a1, a2, sim1_dist))

grid %>% 
  ggplot(aes(a1, a2)) +
  geom_point(data = filter(grid, rank(dist) <= 10), size = 4, colour = "red") +
  geom_point(aes(colour = -dist)) 

ggplot(sim1, aes(x, y)) + 
  geom_point(size = 2, colour = "grey30") + 
  geom_abline(
    aes(intercept = a1, slope = a2, colour = -dist), 
    data = filter(grid, rank(dist) <= 10)
  )

# minimize distance using Newton-Raphson search by using optim()
best <- optim(c(0, 0), measure_distance, data = sim1)
best$par
ggplot(sim1, aes(x, y)) + 
  geom_point(size = 2, colour = "grey30") + 
  geom_abline(intercept = best$par[1], slope = best$par[2])

# for linear models, R has special lm() function that uses formulas (y~x)
sim1_mod <- lm(y ~ x, data = sim1)
coef(sim1_mod)

# VISUALIZING MODELS -----------------------------------------------------------

# visualize predictions by first generating evenly spaced grid of values that
# covers region where data lies using modelr::data_grid()
grid <- sim1 %>% 
  data_grid(x) 
grid

# use modelr::add_predictions() to add predictions from model as a new column
grid <- grid %>% 
  add_predictions(sim1_mod) 
grid

# plot predictions using ggplot, works for any type of model
ggplot(sim1, aes(x)) +
  geom_point(aes(y = y)) +
  geom_line(aes(y = pred), data = grid, colour = "red", size = 1)

# add residuals to model using modelr::add_residuals() on og dataset
sim1 <- sim1 %>% 
  add_residuals(sim1_mod)
sim1

# can look at residuals by plotting them on a frequency polygon
ggplot(sim1, aes(resid)) + 
  geom_freqpoly(binwidth = 0.5)

# plot residuals rather than predictor
ggplot(sim1, aes(x, resid)) + 
  geom_ref_line(h = 0) +
  geom_point() 

# FORMULAS & MODEL FAMILIES ----------------------------------------------------

# model_matrix() takes a data frame and a formula and returns a tibble that 
# defines the model equation
df <- tribble(
  ~y, ~x1, ~x2,
  4, 2, 5,
  5, 1, 6
)
model_matrix(df, y ~ x1)

# adding a -1 to the formula forces R to drop the intercept of 1
model_matrix(df, y ~ x1 - 1)

# model matrix grows as you add more variables
model_matrix(df, y ~ x1 + x2)

# for categorical variables, R converts categories to respective integers
# if "Sex" is a category, R would convert "male" to 1 and "female" to 0
df <- tribble(
  ~ sex, ~ response,
  "male", 1,
  "female", 2,
  "male", 1
)
model_matrix(df, response ~ sex)

# sim2 dataset is a categorical dataset
ggplot(sim2) + 
  geom_point(aes(x, y))
mod2 <- lm(y ~ x, data = sim2)

# a model with a categorical x will predict the mean value for each category
grid <- sim2 %>% 
  data_grid(x) %>% 
  add_predictions(mod2)
grid
ggplot(sim2, aes(x)) + 
  geom_point(aes(y = y)) +
  geom_point(data = grid, aes(y = pred), colour = "red", size = 4)

# sim3 contains a categorical predictor & a continuous predictor
ggplot(sim3, aes(x1, y)) + 
  geom_point(aes(colour = x2))

# two possible models for the above data
mod1 <- lm(y ~ x1 + x2, data = sim3)
mod2 <- lm(y ~ x1 * x2, data = sim3)

# need to give a data_grid() to both variables
# can use gather_predictions() to add each prediction to a row
grid <- sim3 %>% 
  data_grid(x1, x2) %>% 
  gather_predictions(mod1, mod2)
grid

# visualize results for both models using faceting
ggplot(sim3, aes(x1, y, colour = x2)) + 
  geom_point() + 
  geom_line(data = grid, aes(y = pred)) + 
  facet_wrap(~ model)

# look at residuals to compare models
sim3 <- sim3 %>% 
  gather_residuals(mod1, mod2)

ggplot(sim3, aes(x1, resid, colour = x2)) + 
  geom_point() + 
  facet_grid(model ~ x2)

# model for 2 continuous variables begins similiarly
# use seq_range() for data_grid() to use regularly spaced grid of values
mod1 <- lm(y ~ x1 + x2, data = sim4)
mod2 <- lm(y ~ x1 * x2, data = sim4)

grid <- sim4 %>% 
  data_grid(
    x1 = seq_range(x1, 5), 
    x2 = seq_range(x2, 5) 
  ) %>% 
  gather_predictions(mod1, mod2)
grid

# display models using geom_tile(), but colors are hard to interpret
ggplot(grid, aes(x1, x2)) + 
  geom_tile(aes(fill = pred)) + 
  facet_wrap(~ model)

# look at model from side with multiple slices
ggplot(grid, aes(x1, pred, colour = x2, group = x2)) + 
  geom_line() +
  facet_wrap(~ model)
ggplot(grid, aes(x2, pred, colour = x1, group = x1)) + 
  geom_line() +
  facet_wrap(~ model)

# can perform transformations inside model formula, but must wrap with I()
df <- tribble(
  ~y, ~x,
  1,  1,
  2,  2, 
  3,  3
)
model_matrix(df, y ~ x^2 + x)
model_matrix(df, y ~ I(x^2) + x)

# use transformations to model non-linear functions, like Taylor's theorem
model_matrix(df, y ~ poly(x, 2))
library(splines)
model_matrix(df, y ~ ns(x, 2))

# EXERCISES --------------------------------------------------------------------

sim1a <- tibble(
  x = rep(1:10, each = 3),
  y = x * 1.5 + 6 + rt(length(x), df = 2)
)
sim1a_mod <- lm(y ~ x, data = sim1a)
sim1a_mod$coefficients

measure_distance <- function(mod, data) {
  diff <- data$y - model1(mod, data)
  mean(abs(diff))
}
best_practice <- optim(c(0, 0), measure_distance, data = sim1a)
best_practice$par
ggplot(sim1a, aes(x, y)) +
  geom_point(size = 2, colour = "grey30") +
  geom_abline(intercept = best_practice$par[1], slope = best_practice$par[2])

sim1_loess <- loess(y ~ x, data = sim1)
sim1_loess

ggplot(sim1, aes(x, y)) +
  geom_point(color = "grey30") +
  geom_smooth(method = "loess")

mod2a <- lm(y ~ x - 1, data = sim2)
mod2 <- lm(y ~ x, data = sim2)
grid <- sim2 %>%
  data_grid(x) %>%
  spread_predictions(mod2, mod2a)
grid

mod1 <- lm(y ~ x1 + x2, data = sim4)
mod2 <- lm(y ~ x1 * x2, data = sim4)
sim4_mods <- gather_residuals(sim4, mod1, mod2)

ggplot(sim4_mods, aes(x = resid, colour = model)) +
  geom_freqpoly(binwidth = 0.5) +
  geom_rug()
