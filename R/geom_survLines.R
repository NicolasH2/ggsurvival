# devtools::document()

#' create a the line of a survival curve as a layer ready to be added to a ggplot object
#'
#' Imports:
#' ggplot2
#'
#' @inheritParams geom_surv
#' @inheritParams ggplot2::geom_path
#' @import ggplot2
#'
#' @return a ggplot2 layer object (geom_path for the lines) that can directly be added to a ggplot2 object
#' @details calls the geom_surve function but only uses the lines, not the ticks
#' @export
#' @examples
#' library(ggsurvival)
#' library(ggplot2)
#'
#' survtest <- data.frame(
#'   time = sample(seq(30),50,replace = T),
#'   status = sample(1:2, 50, replace = T),
#'   condition = sample(c("wt","ko"), 50, replace = T)
#' )
#'
#' ggplot() +
#'   geom_survLines(survtest, aes(time, status, color=condition))
#'   geom_survTicks(survtest, aes(time, status, color=condition))
#'
geom_survLines <- function(data, mapping, ...){

  output <- geom_surv(mapping=mapping, data=data, ...)
  output <- output["lines"]
  return(output)

}

