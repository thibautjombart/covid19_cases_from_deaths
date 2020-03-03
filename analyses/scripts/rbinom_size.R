##' Samples size (the number of trials) of a binomial distribution
##'
##' Samples the size parameter from the binomial distribution with fixed x
##' (number of successes) and p (success probability)
##' 
##' @param n number of samples to generate
##' @param x number of successes
##' @param prob probability of success
##' @return sampled sizes
##' @author Sebastian Funk
##' @keywords internal
rbinom_size <- function(n, x, prob) {
    x + stats::rnbinom(n, x + 1, prob)
}
