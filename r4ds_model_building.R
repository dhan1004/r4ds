### MODEL BUILDING

library(tidyverse)
library(modelr)
options(na.action = na.warn)

library(nycflights13)
library(lubridate)

# DIAMONDS ---------------------------------------------------------------------

# low quality diamonds have high prices
ggplot(diamonds, aes(cut, price)) + geom_boxplot()
ggplot(diamonds, aes(color, price)) + geom_boxplot()
ggplot(diamonds, aes(clarity, price)) + geom_boxplot()

# it appears that lower quality diamonds have higher prices because weight 
# (carats) of a diamond is a confounding factor
# weight of a diamonds is the most important factor in determining its price
ggplot(diamonds, aes(carat, price)) + 
  geom_hex(bins = 50)

# to make dataset easier to work with: 1) limit weight to 2.5 carats, 2) log
# transform carat & price variables
diamonds2 <- diamonds %>% 
  filter(carat <= 2.5) %>% 
  mutate(lprice = log2(price), lcarat = log2(carat))
ggplot(diamonds2, aes(lcarat, lprice)) + 
  geom_hex(bins = 50)

# fitting a linear model to data
mod_diamond <- lm(lprice ~ lcarat, data = diamonds2)

# undo log transformation so predictions are over original data
grid <- diamonds2 %>% 
  data_grid(carat = seq_range(carat, 20)) %>% 
  mutate(lcarat = log2(carat)) %>% 
  add_predictions(mod_diamond, "lprice") %>% 
  mutate(price = 2 ^ lprice)

ggplot(diamonds2, aes(carat, price)) + 
  geom_hex(bins = 50) + 
  geom_line(data = grid, colour = "red", size = 1)

# residuals can tell us that we have moved the strong residual pattern
diamonds2 <- diamonds2 %>% 
  add_residuals(mod_diamond, "lresid")

ggplot(diamonds2, aes(lcarat, lresid)) + 
  geom_hex(bins = 50)

# can now plots resids against quality instead
# higher resids for better diamonds = higher price of better diamonds
ggplot(diamonds2, aes(cut, lresid)) + geom_boxplot()
ggplot(diamonds2, aes(color, lresid)) + geom_boxplot()
ggplot(diamonds2, aes(clarity, lresid)) + geom_boxplot()

# could include color, cut, & clarity in the model to explicitly show effect
# of these variables
mod_diamond2 <- lm(lprice ~ lcarat + color + cut + clarity, data = diamonds2)

grid <- diamonds2 %>% 
  data_grid(cut, .model = mod_diamond2) %>% 
  add_predictions(mod_diamond2)
grid

ggplot(grid, aes(cut, pred)) + 
  geom_point()

diamonds2 <- diamonds2 %>% 
  add_residuals(mod_diamond2, "lresid2")

ggplot(diamonds2, aes(lcarat, lresid2)) + 
  geom_hex(bins = 50)

# DAILY FLIGHTS ----------------------------------------------------------------

# count number of flights per day & visualize
daily <- flights %>% 
  mutate(date = make_date(year, month, day)) %>% 
  group_by(date) %>% 
  summarise(n = n())
daily

ggplot(daily, aes(date, n)) + 
  geom_line()

# there’s a very strong day-of-week effect that dominates the subtler patterns
# look at the distribution of flight numbers by day-of-week
daily <- daily %>% 
  mutate(wday = wday(date, label = TRUE))
ggplot(daily, aes(wday, n)) + 
  geom_boxplot()

# can remove strong weekday pattern using a model
# overlay predictions over original data to check predictions
mod <- lm(n ~ wday, data = daily)

grid <- daily %>% 
  data_grid(wday) %>% 
  add_predictions(mod, "n")

ggplot(daily, aes(wday, n)) + 
  geom_boxplot() +
  geom_point(data = grid, colour = "red", size = 4)

# compute & visualize residuals
daily <- daily %>% 
  add_residuals(mod)
daily %>% 
  ggplot(aes(date, resid)) + 
  geom_ref_line(h = 0) + 
  geom_line()

# above model starts failing around May/June
# plotting resids by day of the week shows patterns that were not captured
ggplot(daily, aes(date, resid, colour = wday)) + 
  geom_ref_line(h = 0) + 
  geom_line()

# some days have far fewer days than predicted (esp holidats)
daily %>% 
  filter(resid < -100)

# there is some sort of smoother, long-term trend 
daily %>% 
  ggplot(aes(date, resid)) + 
  geom_ref_line(h = 0) + 
  geom_line(colour = "grey50") + 
  geom_smooth(se = FALSE, span = 0.20)

# first go back and look at raw data from Saturdays
daily %>% 
  filter(wday == "Sat") %>% 
  ggplot(aes(date, n)) + 
  geom_point() + 
  geom_line() +
  scale_x_date(NULL, date_breaks = "1 month", date_labels = "%b")

# suggests that flights on Saturdays may be related to school terms
term <- function(date) {
  cut(date, 
      breaks = ymd(20130101, 20130605, 20130825, 20140101),
      labels = c("spring", "summer", "fall") 
  )
}

daily <- daily %>% 
  mutate(term = term(date)) 

daily %>% 
  filter(wday == "Sat") %>% 
  ggplot(aes(date, n, colour = term)) +
  geom_point(alpha = 1/3) + 
  geom_line() +
  scale_x_date(NULL, date_breaks = "1 month", date_labels = "%b")

# look at effects of term variable compared to all days of week
daily %>% 
  ggplot(aes(wday, n, colour = term)) +
  geom_boxplot()

# plotting the residuals shows that our model is better, but still missing smth
mod1 <- lm(n ~ wday, data = daily)
mod2 <- lm(n ~ wday * term, data = daily)

daily %>% 
  gather_residuals(without_term = mod1, with_term = mod2) %>% 
  ggplot(aes(date, resid, colour = model)) +
  geom_line(alpha = 0.75)

# overlaying predictions onto data shows that models don't account for outliers
grid <- daily %>% 
  data_grid(wday, term) %>% 
  add_predictions(mod2, "n")

ggplot(daily, aes(wday, n)) +
  geom_boxplot() + 
  geom_point(data = grid, colour = "red") + 
  facet_wrap(~ term)

# use model MASS::rlm(), which is robust to effect of outliers
mod3 <- MASS::rlm(n ~ wday * term, data = daily)

daily %>% 
  add_residuals(mod3, "resid") %>% 
  ggplot(aes(date, resid)) + 
  geom_hline(yintercept = 0, size = 2, colour = "white") + 
  geom_line()

# bundle the creation of variables up into a function to prevent accidental
# transformations
compute_vars <- function(data) {
  data %>% 
    mutate(
      term = term(date), 
      wday = wday(date, label = TRUE)
    )
}

# could also try a more flexible model to capture patterns
library(splines)
mod <- MASS::rlm(n ~ wday * ns(date, 5), data = daily)

daily %>% 
  data_grid(wday, date = seq_range(date, n = 13)) %>% 
  add_predictions(mod) %>% 
  ggplot(aes(date, pred, colour = wday)) + 
  geom_line() +
  geom_point()
