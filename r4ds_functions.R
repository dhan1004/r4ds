### FUNCTIONS

# creating a new function: need 1) name, 2) arguments, 3) body in {}
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}
rescale01(c(0, 5, 10))

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
