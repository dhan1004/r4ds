### DATA IMPORT ###

library(tidyverse)

# first argument of read_csv() is path to file being read
read_csv("data/heights.csv")

# inline csv file:
read_csv("a,b,c
1,2,3
4,5,6")
# read_csv() uses the first line of the data for the column names

# use skip = n to skip the first n lines
# use comment = "#" to drop all lines that start with (e.g.) #
read_csv("The first line of metadata
  The second line of metadata
  x,y,z
  1,2,3", skip = 2)

read_csv("# A comment I want to skip
  x,y,z
  1,2,3", comment = "#")

# use col_names = FALSE to tell read_csv() not to treat the 1st row as headings
read_csv("1,2,3\n4,5,6", col_names = FALSE)

# you can pass col_names a vector which will be used as the column names
read_csv("1,2,3\n4,5,6", col_names = c("x", "y", "z"))

# na specifies the value(s) that are used to represent missing values
read_csv("a,b,c\n1,2,.", na = ".")

# parse_*() fxns take a character vector and return a more specialised vector
# ie. a logical, integer, or date
str(parse_logical(c("TRUE", "FALSE", "NA")))
#>  logi [1:3] TRUE FALSE NA
str(parse_integer(c("1", "2", "3")))
#>  int [1:3] 1 2 3
str(parse_date(c("2010-01-01", "1979-10-14")))
#>  Date[1:2], format: "2010-01-01" "1979-10-14"

# 1st argument is a character vector to parse
# na argument specifies which strings should be treated as missing
parse_integer(c("1", "231", ".", "456"), na = ".")

