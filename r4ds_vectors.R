### VECTORS

library(tidyverse)

# VECTOR BASICS ----------------------------------------------------------------

# 2 types of vectors: atomic (homogenous) & list (heterogenous)
# NULL is used to represent the absence of a vector
# Every vector has a type and length

# ATOMIC VECTORS ---------------------------------------------------------------

# logical vectors are typically constructed with comparision operators
1:10 %% 3 == 0
#>  [1] FALSE FALSE  TRUE FALSE FALSE  TRUE FALSE FALSE  TRUE FALSE

c(TRUE, TRUE, FALSE, NA)
#> [1]  TRUE  TRUE FALSE    NA

# integers and doubles are both numeric vectors; numbers are doubles by default
# make an itneger by placing "L" after the number
typeof(1)
#> [1] "double"
typeof(1L)
#> [1] "integer"
1.5L
#> [1] 1.5

# doubles have four special vaues: NA, NaN, Inf, -Inf
c(-1, 0, 1) / 0
#> [1] -Inf  NaN  Inf

# can use explicit coercion to force one type of vector into another type
# ie. as.logical(), as.interger() (used relatively rarely)

# implicit coercion occurs when a vector is used in a context that expects a
# certain type
x <- sample(20, 100, replace = TRUE)
y <- x > 10
sum(y)  # how many are greater than 10?
#> [1] 38
mean(y) # what proportion are greater than 10?
#> [1] 0.38

# atomic vectors only have one type, so c() with multiple types will have type
# of most complex vector
typeof(c(TRUE, 1L))
#> [1] "integer"
typeof(c(1L, 1.5))
#> [1] "double"
typeof(c(1.5, "a"))
#> [1] "character"

# can use test fxns such as is_logical() to test type of vector

# vector recycling coerces the length of vectors for functions
sample(10) + 100
#>  [1] 107 104 103 109 102 101 106 110 105 108
runif(10) > 0.5
#>  [1] FALSE  TRUE FALSE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE
1:10 + 1:2
#>  [1]  2  4  4  6  6  8  8 10 10 12

# "[" is the subsetting fxn 
# vectors can be subsetted using only integers (+ values are indices to be kept,
# - values are indices dropped, but you can't mix the two)
x <- c("one", "two", "three", "four", "five")
x[c(3, 2, 5)]
#> [1] "three" "two"   "five"
x[c(1, 1, 5, 5, 5, 2)]
#> [1] "one"  "one"  "five" "five" "five" "two"
x[c(-1, -3, -5)]
#> [1] "two"  "four"

# subsetting with a logical vector keeps all values corresponding to a TRUE
x <- c(10, 3, NA, 5, 8, 1, NA)

# All non-missing values of x
x[!is.na(x)]
#> [1] 10  3  5  8  1
# All even (or missing!) values of x
x[x %% 2 == 0]
#> [1] 10 NA  8 NA

# named vector can be subsetted with character vector
x <- c(abc = 1, def = 2, xyz = 5)
x[c("xyz", "def")]
#> xyz def 
#>   5   2

# nothing, x[], returns the complete x
# [[ ]] only extracts a single element & drops names

# RECURSIVE VECTORS (LISTS) ----------------------------------------------------

# create a list using list()
x <- list(1, 2, 3)
x

# using str() focuses on the structure of the list
str(x)

x_named <- list(a = 1, b = 2, c = 3)
str(x_named)

# lists can contai mixes of objects
y <- list("a", 1L, 1.5, TRUE)
str(y)

# lists can also contain other lists
z <- list(list(1, 2), list(3, 4))
str(z)

a <- list(a = 1:3, b = "a string", c = pi, d = list(-1, -5))

# [] extracts a sub-list, always returning a list
str(a[1:2])
str(a[4])

# [[]] subsets a single component from a list, removing a layer of hierarchy
str(a[[1]])
str(a[[4]])

# $ is shorthand for extracting named elements of a list
a$a
a[["a"]]

# ATTRIBUTES -------------------------------------------------------------------

# vectors can contain arbitrary metadata through their attributes
x <- 1:10
attr(x, "greeting")
#> NULL
attr(x, "greeting") <- "Hi!"
attr(x, "farewell") <- "Bye!"
attributes(x)

# 3 important attributes: 1) names of elements of vectors, 2) dimensions, 
# 3) class to implement S3 object orientated system

# classes control how generic functions work 
# generic functions call specific methods based on class of first argument
as.Date
methods("as.Date")

# AUGUMENTED VECTORS -----------------------------------------------------------

# factors and dates are augmented vectors (have additional classes)

# factors represent categorical data that can take on a fixed set of values
x <- factor(c("ab", "cd", "ab"), levels = c("ab", "cd", "ef"))
typeof(x)
attributes(x)

# dates are numeric vectors
x <- as.Date("1971-01-01")
unclass(x)
typeof(x)
attributes(x)

# tibbles are augmented lists 
tb <- tibble::tibble(x = 1:5, y = 5:1)
typeof(tb)
attributes(tb)

# EXERCISES --------------------------------------------------------------------

last_val <- function(x) {
  last_index <- length(x)
  x[last_index]
}
x <- c(3, 5, 9, 0, 2)
last_val(x)

even_indices <- function(x) {
  x[1:length(x) %% 2 ==0]
}
even_indices(x)

except_last <- function(x) {
  x[1:(length(x)-1)]
}
except_last(x)

only_even <- function(x) {
  x_int <- x[!is.na(x)]
  x_int[x_int %% 2 == 0]
}
x <- c(NA, 4, 8, NA)
only_even(x)
