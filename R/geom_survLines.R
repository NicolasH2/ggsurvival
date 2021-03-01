# devtools::document()

#' create a the line of a survival curve as a layer ready to be added to a ggplot object
#'
#' Imports:
#' ggplot2
#'
#' @inheritParams ggplot2::geom_path
#' @import ggplot2
#'
#' @param mapping aes object, created with aes(). Provide x (time) and y (status). Optionally you can provide color and linetype to distinguish conditions. For the status: NA will be irgnored, 1 = dropped out, 2 = dead, any other value = alive.
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
#'   geom_survLines(aes(time, status, color=condition), data=survtest)
#'   geom_survTicks(aes(time, status, color=condition), data=survtest)
#'
geom_survLines <- function(mapping, data, surv_pretty=FALSE, ...){

  output <- geom_surv(mapping=mapping, data=data, surv_pretty=surv_pretty, ...)
  output <- output["lines"]
  return(output)

}

