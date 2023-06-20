###DATA VISUALIZATION###

install.packages("tidyverse")
library(tidyverse)

# template for ggplot2 with aesthetics, position adjustments, stats,
# coordinate systems, & faceting
# ggplot(data = <DATA>) + 
#   <GEOM_FUNCTION>(
#     mapping = aes(<MAPPINGS>),
#     stat = <STAT>, 
#     position = <POSITION>
#   ) +
#   <COORDINATE_FUNCTION> +
#   <FACET_FUNCTION>

ggplot(data = mpg) + geom_point(mapping = aes(x = displ, y = hwy, alpha = class), 
                                color = "blue")
# template for graphs:
# ggplot(data = <DATA>) +  <GEOM_FUNCTION>(mapping = aes(<MAPPINGS>))
# aesthetics to differentiate 3rd property: color, shape, size, alpha (transparency)
# set aesthetic manually by adding parameter outside of aes() eg. color = "blue"

# facet creates subplots to display data subsets, must be discrete variable
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_wrap(~ class, nrow = 2) 

# facet_grid plots on combination of two variables
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_grid(drv ~ cyl)

# geom is the geometrical object that a plot uses to represent data
# change geom function added to ggplot
ggplot(data = mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy, color= drv))

# map multiple geoms
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(mapping = aes(color = class)) + 
  geom_smooth()
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(mapping = aes(color = class)) + 
  geom_smooth(data = filter(mpg, class == "subcompact"), se = FALSE)

# bar charts bin data
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut))

# every geom has a default stat (statistical transformation)
ggplot(data = diamonds) + 
  stat_count(mapping = aes(x = cut))
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, y = after_stat(prop), group = 1))

# fill aesthetic to another variable
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity))

# position adjustment (identity, fill, or dodge)
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity), position = "fill")

# jitter adds random noise to each point to spread them out
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy), position = "jitter")

# coordinate systems (coord_flip, coord_quickmap, coord_polar)
bar <- ggplot(data = diamonds) + 
  geom_bar(
    mapping = aes(x = cut, fill = cut), 
    show.legend = FALSE,
    width = 1
  ) + 
  theme(aspect.ratio = 1) +
  labs(x = NULL, y = NULL)

bar + coord_flip()
bar + coord_polar() 
