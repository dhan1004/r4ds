### STRINGS

library(tidyverse)
install.packages("microbenchmark")
library(microbenchmark)

# use writeLines() to see raw contents of strings
x <- c("\"", "\\")
writeLines(x)

# STRING BASICS ----------------------------------------------------------------

# stringr functions are more consistent than base R functions 
str_length(c("a", "R for data science", NA))

# str_c combines multiple strings
str_c("x", "y")
str_c("x", "y", "z")

# sep argument controls how strings are separated
str_c("x", "y", sep = ", ")

# missing values are contagious, must use str_replace_na() to get "NA"
x <- c("abc", NA)
str_c("|-", x, "-|")
str_c("|-", str_replace_na(x), "-|")

# objects of length 0 are dropped silently
name <- "Hadley"
time_of_day <- "morning"
birthday <- FALSE

str_c(
  "Good ", time_of_day, " ", name,
  if (birthday) " and HAPPY BIRTHDAY",
  "."
)

# collapse a vector of strings into a single string using collapse argument
str_c(c("x", "y", "z"), collapse = ", ")

# extract parts of a string using str_sub()
x <- c("Apple", "Banana", "Pear")
str_sub(x, 1, 3)
#> [1] "App" "Ban" "Pea"
# negative numbers count backwards from end
str_sub(x, -3, -1)
#> [1] "ple" "ana" "ear"

# if string is shorter than index positions, str_sub() will just return
# as much as possible
str_sub("a", 1, 5)

# can use str_sub to modify strings
str_sub(x, 1, 1) <- str_to_lower(str_sub(x, 1, 1))
x

# can use locales so that changing cases applies correctly to languages
# Turkish has two i's: with and without a dot, and it
# has a different rule for capitalising them:
str_to_upper(c("i", "ı"))
#> [1] "I" "I"
str_to_upper(c("i", "ı"), locale = "tr")
#> [1] "İ" "I"

# str_sort and str_order take in locales
x <- c("apple", "eggplant", "banana")

str_sort(x, locale = "en")  # English
#> [1] "apple"    "banana"   "eggplant"

str_sort(x, locale = "haw") # Hawaiian
#> [1] "apple"    "eggplant" "banana"

# REGEXS -----------------------------------------------------------------------

# str_view and str_view_all shows how character vector & regex match

# exact match
x <- c("apple", "banana", "pear")
str_view(x, "an")

# "." matches any character
str_view(x, ".a.")

# To create the regular expression, we need \\
dot <- "\\."

# But the expression itself only contains one:
writeLines(dot)
#> \.

# And this tells R to look for an explicit .
str_view(c("abc", "a.c", "bef"), "a\\.c")

# matching "\" requires 4 backslashes to escape
x <- "a\\b"
writeLines(x)
#> a\b

str_view(x, "\\\\")

# anchor ^ to match from start of string, $ to match from end
x <- c("apple", "banana", "pear")
str_view(x, "^a")
str_view(x, "a$")

# using both anchors forces regex to only match complete string
x <- c("apple pie", "apple", "apple cake")
str_view(x, "apple")
str_view(x, "^apple$")

# special character matches
# \d matches any digit
# \s matches any whitespace
# [abc] matches a, b, or c
# [^abc] matches anything except a, b, or c
# Look for a literal character that normally has special meaning in a regex
str_view(c("abc", "a.c", "a*c", "a c"), "a[.]c")

# alternation with "|" allows you to match alternative patterns
str_view(c("grey", "gray"), "gr(e|a)y")

# controlling how many times a pattern matches
# ?: 0 or 1; +: 1 or more; *: 0 or more
x <- "1888 is the longest year in Roman numerals: MDCCCLXXXVIII"
str_view(x, "CC?")
str_view(x, "CC+")

# specify number of matches using interval notation
# {n} is exactly n, {n,m} is between n and m, {n,}, {,m}
str_view(x, "C{2}")

# matches are greedy by default, can make them lazy with "?"
str_view(x, 'C{2,3}?')

# parentheses create numbered capturing group that stores part of the string
# matched by regex inside the parentheses
# refer to the same text by capturing group through backreferences (\1, \2)
str_view(fruit, "(..)\\1", match = TRUE)

# TOOLS ------------------------------------------------------------------------

# use str_detect() to determine if a character vector matches a pattern
# returns logical vector
x <- c("apple", "banana", "pear")
str_detect(x, "e")
#> [1]  TRUE FALSE  TRUE

# logical vectors become 0 (false) and 1 (true), so sum() and mean() can be
# useful for matches across a large vector
# How many common words start with t?
sum(str_detect(words, "^t"))
#> [1] 65
# What proportion of common words end with a vowel?
mean(str_detect(words, "[aeiou]$"))
#> [1] 0.2765306

# may be easier to combine str_detect() with logical operators rather than
# overly complicated regexes
# Find all words containing at least one vowel, and negate
no_vowels_1 <- !str_detect(words, "[aeiou]")
# Find all words consisting only of consonants (non-vowels)
no_vowels_2 <- str_detect(words, "^[^aeiou]+$")
identical(no_vowels_1, no_vowels_2)
#> [1] TRUE

# select elements that match a pattern
words[str_detect(words, "x$")]
#> [1] "box" "sex" "six" "tax"
str_subset(words, "x$")
#> [1] "box" "sex" "six" "tax"

# string will often be one column of a dataset => more useful to filter()
df <- tibble(
  word = words, 
  i = seq_along(word)
)
df %>% 
  filter(str_detect(word, "x$"))

#str_count() tells you how many matches there are in a string
x <- c("apple", "banana", "pear")
str_count(x, "a")
#> [1] 1 3 1

# On average, how many vowels per word?
mean(str_count(words, "[aeiou]"))
#> [1] 1.991837

# can use str_count() with mutate
df %>% 
  mutate(
    vowels = str_count(word, "[aeiou]"),
    consonants = str_count(word, "[^aeiou]")
  )

sentences <- stringr::sentences
head(sentences)

# str_extract extracts the actual text of a match
colors <- c("red", "orange", "yellow", "green", "blue", "purple")
color_match <- str_c("\\b(", str_c(colors, collapse = "|"), ")\\b")
color_match
has_color <- str_subset(sentences, color_match)
matches <- str_extract(has_color, color_match)
head(matches)
more <- sentences[str_count(sentences, color_match) > 1]
str_view_all(more, color_match)
str_extract_all(more, color_match)

# use simplify = TRUE => str_extract_all() will return a matrix with short 
# matches expanded to the same length as the longest
str_extract_all(more, colour_match, simplify = TRUE)
#>      [,1]     [,2] 
#> [1,] "blue"   "red"
#> [2,] "green"  "red"
#> [3,] "orange" "red"

x <- c("a", "a b", "a b c")
str_extract_all(x, "[a-z]", simplify = TRUE)
#>      [,1] [,2] [,3]
#> [1,] "a"  ""   ""  
#> [2,] "a"  "b"  ""  
#> [3,] "a"  "b"  "c"

# use parentheses to extract part of a complex match
noun <- "(a|the) ([^ ]+)"

has_noun <- sentences %>%
  str_subset(noun) %>%
  head(10)
has_noun %>% 
  str_extract(noun)

# string_match() returns a matrix: 1 column for complete match & 1 column/group
has_noun %>% 
  str_match(noun)

# data in tibble may be better for tidyr::extract()
tibble(sentence = sentences) %>% 
  tidyr::extract(
    sentence, c("article", "noun"), "(a|the) ([^ ]+)", 
    remove = FALSE
  )

# str_replace() and str_replace_all() replace matches with new strings
x <- c("apple", "pear", "banana")
str_replace(x, "[aeiou]", "-")
#> [1] "-pple"  "p-ar"   "b-nana"
str_replace_all(x, "[aeiou]", "-")
#> [1] "-ppl-"  "p--r"   "b-n-n-"

# str_replace_all() can do multiple replacements if provided a vector
x <- c("1 house", "2 cars", "3 people")
str_replace_all(x, c("1" = "one", "2" = "two", "3" = "three"))
#> [1] "one house"    "two cars"     "three people"

# can also use back references (ie. flip order of 2nd & 3rd word)
sentences %>% 
  str_replace("([^ ]+) ([^ ]+) ([^ ]+)", "\\1 \\3 \\2")

# str_split() splits a string to pieces
sentences %>%
  head(5) %>% 
  str_split(" ")

"a|b|c|d" %>% 
  str_split("\\|") %>% 
  .[[1]]
#> [1] "a" "b" "c" "d"

# returns a list, can use SIMPLIFY = TRUE to return a matrix
sentences %>%
  head(5) %>% 
  str_split(" ", simplify = TRUE)

# can request maximum number of pieces 
fields <- c("Name: Hadley", "Country: NZ", "Age: 35")
fields %>% str_split(": ", n = 2, simplify = TRUE)

# can split by character, line, sentence, & word boundarys
x <- "This is a sentence.  This is another sentence."
str_view_all(x, boundary("word"))

# str_locate() & str_locate_all() give starting & ending positions of each match

# OTHER TYPES OF PATTERNS ------------------------------------------------------

# patterns that are a string get automatically wrapped into a regex call
# The regular call:
str_view(fruit, "nana")
# Is shorthand for
str_view(fruit, regex("nana"))

# ignore_case = TRUE ignores upper/lower case
bananas <- c("banana", "Banana", "BANANA")
str_view(bananas, "banana")
str_view(bananas, regex("banana", ignore_case = TRUE))

# multiline = TRUE allows ^ and $ to match the start and end of each line
x <- "Line 1\nLine 2\nLine 3"
str_extract_all(x, "^Line")[[1]]
str_extract_all(x, regex("^Line", multiline = TRUE))[[1]]

#comments = TRUE allows you to use comments and white space to make complex 
# regular expressions more understandable
phone <- regex("
  \\(?     # optional opening parens
  (\\d{3}) # area code
  [) -]?   # optional closing parens, space, or dash
  (\\d{3}) # another three numbers
  [ -]?    # optional space or dash
  (\\d{3}) # three more numbers
  ", comments = TRUE)

str_match("514-791-8141", phone)

# dotall = TRUE allows . to match everything, including \n

# fixed(): matches exactly the specified sequence of bytes
microbenchmark::microbenchmark(
  fixed = str_detect(sentences, fixed("the")),
  regex = str_detect(sentences, "the"),
  times = 20
)

# coll(): compare strings using standard collation rules
# useful for doing case insensitive matching
# That means you also need to be aware of the difference
# when doing case insensitive matches:
i <- c("I", "İ", "i", "ı")
i
#> [1] "I" "İ" "i" "ı"

str_subset(i, coll("i", ignore_case = TRUE))
#> [1] "I" "i"
str_subset(i, coll("i", ignore_case = TRUE, locale = "tr"))
#> [1] "İ" "i"

# OTHER REGEX EXPRESSIONS ------------------------------------------------------

# apropos() searches all objects available from the global environment
apropos("replace")

# dir() lists all the files in a directory
head(dir(pattern = "\\.R$"))

# EXERCISES --------------------------------------------------------------------

x <- c("a", "abc", "abcd", "abcde", "abcdef")
L <- str_length(x)
m <- ceiling(L / 2)
str_sub(x, m, m)
#> [1] "a" "b" "b" "c" "c"

strfxn <- function(x) {
  n <- length(x)
  if (n == 0) {
    ""
  }
  else if (n == 1) {
    x
  }
  else if (n == 2) {
    str_c(x[1], "and", x[2], sep = " ")
  }
  else {
    not_last <- str_c(x[seq_len(n-1)], ",")
    last <- str_c("and", x[[n]], sep = " ")
    str_c(c(not_last, last), collapse = " ")
  }
}

x <- "$^$"
str_view(x, "\\$\\^\\$")
x <- stringr::words
str_view(x, "^y")
str_view(x, "x$")
str_view(x, "^...$")
str_view(x, ".......")

str_view(x, "^(a|e|i|o|u)")
str_view(x, "[aeiou]", match = FALSE)
str_view(x, "[^e]ed$")
str_view(x, "(ing|ise)$")
str_view(x, "cei|[^c]ie")
str_view(x, "cie|[^c]ei")
str_view(x, "qu")
str_view(x, "q[^u]")

str_view(x, "^[^(aeiou)]{3}")
str_view(x, "[aeiou]{3,}")
str_view(x, "([aeiou][^(aeiou)]){2,}")

str_view(x, "^(.)((.*\\1$)|(\\1?$))", match = TRUE)
str_view(x, "([A-Za-z][A-Za-z]).*\\1")
str_view(x, "([A-Za-z]).*\\1.*\\1")

x[str_detect(x, "^x|x$")]
x_start <- str_detect(x, "^x")
x_end <- str_detect(x, "x$")
words[x_start | x_end]

x[str_detect(x, "^[aeiou].*[^(aeiou)]$")]
vowel_start <- str_detect(x, "^[aeiou]")
consonant_end <- str_detect(x, "[^(aeiou)]$")
words[vowel_start & consonant_end]

x[str_detect(x, "a+e+i+o+u+")]
contains_a <- str_detect(x, "a+")
contains_e <- str_detect(x, "e+")
contains_i <- str_detect(x, "i+")
contains_o <- str_detect(x, "o+")
contains_u <- str_detect(x, "u+")
words[contains_a & contains_e & contains_i & contains_o & contains_u]

vowels <- (str_count(x, "[aeiou]"))
x[which(vowels == max(vowels))]

prop <- (vowels/str_length(x))
x[which(prop == max(prop))]

first_word <- str_extract(sentences, "[A-Za-z']+")
first_word
ing_end <- str_extract(sentences, "\\b[A-Za-z]+(ing)\\b")
unique(ing_end)
plurals <- str_extract(sentences, "\\b[A-Za-z]+s\\b")
unique(unlist(plurals))

after_number <- "(one|two|three|four|five) ([^ ]+)"
has_after_number <- sentences %>%
  str_subset(after_number)
has_after_number %>% str_extract(after_number)

test_string <- "users/sissy/desktop/cs"
str_replace_all(test_string, "/", "\\\\")

replacements <- c("A" = "a", "B" = "b", "C" = "c", "D" = "d", "E" = "e",
                  "F" = "f", "G" = "g", "H" = "h", "I" = "i", "J" = "j", 
                  "K" = "k", "L" = "l", "M" = "m", "N" = "n", "O" = "o", 
                  "P" = "p", "Q" = "q", "R" = "r", "S" = "s", "T" = "t", 
                  "U" = "u", "V" = "v", "W" = "w", "X" = "x", "Y" = "y", 
                  "Z" = "z")
str_replace_all(sentences, pattern = replacements)

words <- stringr::words
str_replace_all(words, "^([A-Za-z])(.*)([A_Za-z])$", "\\3\\2\\1")

string <- "apples, pears, and bananas"
str_split(string, ", +(and +)?")
