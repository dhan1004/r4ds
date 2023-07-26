### FUNCTIONS

# creating a new function: need 1) name, 2) arguments, 3) body in {}
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}
rescale01(c(0, 5, 10))

# FUNCTION ARGUMENTS -----------------------------------------------------------

# arguments either control the data input or details of the computation
# data arguments generally come first & detail arguments at the end
# detail arguments usually have defaults
# Compute confidence interval around mean using normal approximation
mean_ci <- function(x, conf = 0.95) {
  se <- sd(x) / sqrt(length(x))
  alpha <- 1 - conf
  mean(x) + se * qnorm(c(alpha / 2, 1 - alpha / 2))
}

x <- runif(100)
mean_ci(x)
#> [1] 0.4976111 0.6099594
mean_ci(x, conf = 0.99)
#> [1] 0.4799599 0.6276105

# usually omit names of data arguments
# use full name of detail argument if overriding
mean(1:10, na.rm = TRUE)

# check important preconditions & throw error if not true
wt_mean <- function(x, w) {
  if (length(x) != length(w)) {
    stop("`x` and `w` must be the same length", call. = FALSE)
  }
  sum(w * x) / sum(w)
}

# stopifnot() checks that each argument is TRUE, and produces 
# generic error message if not
wt_mean <- function(x, w, na.rm = FALSE) {
  stopifnot(is.logical(na.rm), length(na.rm) == 1)
  stopifnot(length(x) == length(w))
  
  if (na.rm) {
    miss <- is.na(x) | is.na(w)
    x <- x[!miss]
    w <- w[!miss]
  }
  sum(w * x) / sum(w)
}
wt_mean(1:6, 6:1, na.rm = "foo")
#> Error in wt_mean(1:6, 6:1, na.rm = "foo"): is.logical(na.rm) is not TRUE

# "..." captures any number of arguments that aren't otherwise matched
commas <- function(...) stringr::str_c(..., collapse = ", ")
commas(letters[1:10])
#> [1] "a, b, c, d, e, f, g, h, i, j"

rule <- function(..., pad = "-") {
  title <- paste0(...)
  width <- getOption("width") - nchar(title) - 5
  cat(title, " ", stringr::str_dup(pad, width), "\n", sep = "")
}
rule("Important output")

# RETURN VALUES ----------------------------------------------------------------

# may use explicit return statement if arguments are empty or other ifs
complicated_function <- function(x, y, z) {
  if (length(x) == 0 || length(y) == 0) {
    return(0)
  }
  
  # Complicated code here
}

# 2 types of functions: transformations (modified return) & side-efects (return
# first arguemnt)
show_missings <- function(df) {
  n <- sum(is.na(df))
  cat("Missing values: ", n, "\n", sep = "")
  
  invisible(df)
}



# EXERCISES --------------------------------------------------------------------

variance <- function(x, na.rm = TRUE) {
  n <- length(x)
  m <- mean(x, na.rm = TRUE)
  ss <- (x-m)^2
  sum(ss) / (n-1)
}
variance(c(0, 1, 5))

skew <- function(x, na.rm = TRUE) {
  n <- length(x)
  m <- mean(x, na.rm = TRUE)
  cube <- (x-m)^3
  numerator <- sum(cube)/(n-2)
  denominator <- (variance(x, na.rm = TRUE))^(3/2)
  numerator/denominator
}
skew(c(3, 8, 10, 17, 24, 27))
skew(c(1,2,5,100))

both_na <- function(x, y) {
  sum(is.na(x) & is.na(y))
}
both_na(c(1, 4, NA, 3, NA), c(NA, 1, NA, 2, 3))
both_na(c(NA, NA, 1, NA, NA), c(NA, 2, NA, NA, NA))

greeting <- function() {
  time <- lubridate::now()
  hour <- lubridate::hour(time)
  if (hour < 12) {
    print("good morning!")
  }
  else if (hour >= 12 && hour < 18) {
    print("good afternoon!")
  }
  else {
    print("good evening!")
  }
}
greeting()

fizzbuzz <- function(x) {
  if ((x%%3==0) && (x%%5==0)) {
    print("fizzbuzz!")
  }
  else if (x %% 3 == 0) {
    print("fizz!")
  }
  else if (x %% 5 == 0) {
    print("buzz!")
  }
  else {
    print(x)
  }
}
fizzbuzz(18)
fizzbuzz(30)
fizzbuzz(25)
fizzbuzz(8)
