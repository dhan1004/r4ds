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

# PARSING NUMBERS ------------------------------------------

# readr “locale” specifies parsing options that differ from place to place
# override number parsing default decimal point of "." using locale
parse_double("1.23")
parse_double("1,23", locale = locale(decimal_mark = ","))

# parse_number() ignores non-numeric numbers before or after number
parse_number("$100")
#> [1] 100
parse_number("20%")
#> [1] 20
parse_number("It cost $123.45")
#> [1] 123.45

# use of parse_number() and locale will ignore grouping mark
# Used in America
parse_number("$123,456,789")
#> [1] 123456789
# Used in many parts of Europe
parse_number("123.456.789", locale = locale(grouping_mark = "."))
#> [1] 123456789
# Used in Switzerland
parse_number("123'456'789", locale = locale(grouping_mark = "'"))
#> [1] 123456789

# PARSING CHARACTERS -------------------------------------------

x1 <- "El Ni\xf1o was particularly bad this year"
x2 <- "\x82\xb1\x82\xf1\x82\xc9\x82\xbf\x82\xcd"

# specify encoding in parse_character()
parse_character(x1, locale = locale(encoding = "Latin1"))
#> [1] "El Niño was particularly bad this year"
parse_character(x2, locale = locale(encoding = "Shift-JIS"))
#> [1] "こんにちは"

# guess_encoding() can help figure out correct encoding of characters
guess_encoding(charToRaw(x1))
#> # A tibble: 2 × 2
#>   encoding   confidence
#>   <chr>           <dbl>
#> 1 ISO-8859-1       0.46
#> 2 ISO-8859-9       0.23
guess_encoding(charToRaw(x2))
#> # A tibble: 1 × 2
#>   encoding confidence
#>   <chr>         <dbl>
#> 1 KOI8-R         0.42

# PARSING DATES & TIMES -------------------------------------------------

# parse_datetime() expects an ISO8601 date-time (year, month, day, hour, minute, second)
parse_datetime("2010-10-01T2010")
#> [1] "2010-10-01 20:10:00 UTC"
# If time is omitted, it will be set to midnight
parse_datetime("20101010")
#> [1] "2010-10-10 UTC"

# parse_date() expects a four digit year, a - or /, the month, a - or /, then the day
parse_date("2010-10-01")
#> [1] "2010-10-01"

# you can supply your own date-time format built up of specific pieces

# PARSING A FILE ---------------------------------------------------------

# readr uses a heuristic to figure out the type of each column from first 1000 rows

# problems arise if file's first 1000 rows are too specific or containing NAs
challenge <- read_csv(readr_example("challenge.csv"))

# last few rows of y column are dates stored in character vectors
problems(challenge)
tail(challenge)

# specify col_types
challenge <- read_csv(
  readr_example("challenge.csv"), 
  col_types = cols(
    x = col_double(),
    y = col_date()
  )
)
tail(challenge)
problems(challenge)

# could just read in all columns as character vectors
challenge2 <- read_csv(readr_example("challenge.csv"), 
                       col_types = cols(.default = col_character())
)

df <- tribble(
  ~x,  ~y,
  "1", "1.21",
  "2", "2.32",
  "3", "4.56"
)
df
#> # A tibble: 3 × 2
#>   x     y    
#>   <chr> <chr>
#> 1 1     1.21 
#> 2 2     2.32 
#> 3 3     4.56

# Note the column types
type_convert(df)
#> 
#> ── Column specification ────────────────────────────────────────────────────────
#> cols(
#>   x = col_double(),
#>   y = col_double()
#> )
#> # A tibble: 3 × 2
#>       x     y
#>   <dbl> <dbl>
#> 1     1  1.21
#> 2     2  2.32
#> 3     3  4.56

# WRITING A FILE ----------------------------------------------------------

# write_csv() and write_tsv() write data back to the disc
# argument x (data frame to save from) & path (location to save it)
write_csv(challenge, "challenge.csv")
