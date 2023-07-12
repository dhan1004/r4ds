### FACTORS

library(tidyverse)

# factors are used to work with categorical variables

# CREATING FACTORS -------------------------------------------------------------

# if you have a variable of type string to record months, you
# 1) may have typos 2) can't sort the months in a useful way
x1 <- c("Dec", "Apr", "Jan", "Mar")

# fix problems by using a factor
# must start creating a factor by creating a list of valid levels 
month_levels <- c(
  "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
)

# create a factor using the levels
y1 <- factor(x1, levels = month_levels)
y1
sort(y1)

# omitting levels => values taken from data in alphabetical order
factor(x1)

# use unique(x) or fct_inorder() to have order of levels match order of first
# appearance in data
f1 <- factor(x1, levels = unique(x1))
f1
f2 <- x1 %>% factor() %>% fct_inorder()
f2

# levels() allows for direct access to set of levels
levels(f2)

# GENERAL SOCIAL SURVEY --------------------------------------------------------

gss_cat

# count() can help you see the levels of factors stored in tibbles
gss_cat %>% count(race)

# a bar chart can also help you see the levels
gss_cat %>%
  ggplot(aes(race)) +
  geom_bar() +
  scale_x_discrete(drop = FALSE)

# MODIFYING FACTOR ORDER -------------------------------------------------------

# can be useful to change the order of factor levels in visualization
relig_summary <- gss_cat %>%
  group_by(relig) %>%
  summarise(
    age = mean(age, na.rm = TRUE),
    tvhours = mean(tvhours, na.rm = TRUE),
    n = n()
  )
ggplot(relig_summary, aes(tvhours, relig)) + geom_point() # doesn't show pattern

# use fct_reorder(), which takes in f (factor to reorder), x (numeric vector to
# reorder levels), and optional fun (function if there are multiple x values per
# level)
ggplot(relig_summary, aes(tvhours, fct_reorder(relig, tvhours))) +
  geom_point()

# more complicated reorders are better in separate mutate() stateent
relig_summary %>%
  mutate(relig = fct_reorder(relig, tvhours)) %>%
  ggplot(aes(tvhours, relig)) +
  geom_point()

# fct_relevel() takes a factor f & the # of levels to move to front
rincome_summary <- gss_cat %>%
  group_by(rincome) %>%
  summarise(
    age = mean(age, na.rm = TRUE),
    tvhours = mean(tvhours, na.rm = TRUE),
    n = n()
  )
ggplot(rincome_summary, aes(age, fct_relevel(rincome, "Not applicable"))) +
  geom_point()

# fct_reorder2() reorders the factor by the y values associated with the 
# largest x values
# makes plots easier to read bc colors match up w/ legend
by_age <- gss_cat %>%
  filter(!is.na(age)) %>%
  count(age, marital) %>%
  group_by(age) %>%
  mutate(prop = n / sum(n))

ggplot(by_age, aes(age, prop, colour = marital)) +
  geom_line(na.rm = TRUE)

ggplot(by_age, aes(age, prop, colour = fct_reorder2(marital, age, prop))) +
  geom_line() +
  labs(colour = "marital")

# use fct_infreq() for bar plots to order levels by increasing frequency
gss_cat %>%
  mutate(marital = marital %>% fct_infreq() %>% fct_rev()) %>%
  ggplot(aes(marital)) +
  geom_bar()

# MODIFYING FACTOR LEVELS

# # fct_recode() allows you to change the value of each level
gss_cat %>% count(partyid)
gss_cat %>%
  mutate(partyid = fct_recode(partyid,
                              "Republican, strong"    = "Strong republican",
                              "Republican, weak"      = "Not str republican",
                              "Independent, near rep" = "Ind,near rep",
                              "Independent, near dem" = "Ind,near dem",
                              "Democrat, weak"        = "Not str democrat",
                              "Democrat, strong"      = "Strong democrat"
  )) %>%
  count(partyid)

# assign multiple levels to the same new level to combine groups
gss_cat %>%
  mutate(partyid = fct_recode(partyid,
                              "Republican, strong"    = "Strong republican",
                              "Republican, weak"      = "Not str republican",
                              "Independent, near rep" = "Ind,near rep",
                              "Independent, near dem" = "Ind,near dem",
                              "Democrat, weak"        = "Not str democrat",
                              "Democrat, strong"      = "Strong democrat",
                              "Other"                 = "No answer",
                              "Other"                 = "Don't know",
                              "Other"                 = "Other party"
  )) %>%
  count(partyid)

# fct_collapse() allows you to collapse a lot of levels
gss_cat %>%
  mutate(partyid = fct_collapse(partyid,
                                other = c("No answer", "Don't know", "Other party"),
                                rep = c("Strong republican", "Not str republican"),
                                ind = c("Ind,near rep", "Independent", "Ind,near dem"),
                                dem = c("Not str democrat", "Strong democrat")
  )) %>%
  count(partyid)

# fct_lump() lumps together small groups to make simpler plots/tables
gss_cat %>%
  mutate(relig = fct_lump(relig)) %>%
  count(relig)

# use n parameter to specify how many groups to collapse to
gss_cat %>%
  mutate(relig = fct_lump(relig, n = 10)) %>%
  count(relig, sort = TRUE) %>%
  print(n = Inf)

# EXERCISES --------------------------------------------------------------------

gss_cat %>%
  ggplot(aes(rincome)) +
  geom_bar()

gss_cat %>% count(relig)
gss_cat %>% count(partyid)

gss_cat %>%
  ggplot(aes(relig, denom)) +
  geom_tile()

gss_cat %>%
  mutate(partyid = fct_collapse(partyid,
                                other = c("No answer", "Don't know", "Other party"),
                                rep = c("Strong republican", "Not str republican"),
                                ind = c("Ind,near rep", "Independent", "Ind,near dem"),
                                dem = c("Not str democrat", "Strong democrat")
  )) %>%
  count(year, partyid) %>%
  group_by(year) %>%
  mutate(prop = n/sum(n)) %>%
  ggplot(aes(year, prop, color = partyid)) +
  geom_line()
