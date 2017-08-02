#' Pick changepoints from prophet object
#'
#' @param model Prophet model object.
#' @param digits Integer, indicating the number of decimal places to be used. Default 2.
#'
#' @return A data frame consists of changepoints, growth rate and delta (changes in the growth rate).
#'
#' @examples
#' \dontrun{
#' m <- prophet(df)
#' prophet_pick_changepoints(m)
#' }
#'
#' @export
prophet_pick_changepoints <- function(model, digits = 2) {
  delta <- as.vector(model$params$delta)
  cp_names <- model$changepoints
  while(any(abs(delta) < 10^-digits)) {
    ind <- which.min(abs(delta))
    cp_names <- cp_names[-ind]
    value <- delta[ind]
    delta <- delta[-ind]
    if (ind > length(delta)) ind <- ind - 1
    delta[ind] <- delta[ind] + value
  }
  cp_names <- c(model$start, cp_names)
  delta <- c(0, delta)
  growth_rate <- model$params$k + cumsum(delta)
  df <- data.frame(changepoints = cp_names, growth_rate = growth_rate, delta = delta)
  class(df) <- c("prophet_changepoint", class(df))
  df
}