# devtools::document()

#' create a survival curve as a layer ready to be added to a ggplot object
#'
#' Imports:
#' ggplot2
#'
#' @inheritParams ggplot2::geom_path
#' @inheritParams ggplot2::geom_segment
#' @import ggplot2
#'
#' @param mapping aes object, created with aes(). Provide x (time) and y (status). Optionally you can provide color and linetype to distinguish conditions. For the status: NA will be irgnored, 1 = dropped out, 2 = dead, any other value = alive.
#' @param surv_pretty, boolean, if TRUE sets certain options to make the plot more pretty
#' @return a list of two ggplot2 layer objects (geom_path for the lines and geom_segment for the ticks) that can directly be added to a ggplot2 object
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
#' ggplot() + geom_surv(aes(time, status, color=condition), data=survtest)
#'
geom_surv <- function(mapping=NULL, data=NULL, surv_pretty=FALSE, ...){
  
  calculation <- .survconditions(data=data, mapping=mapping)
  plotLines <- calculation[["plotLines"]]
  plotTicks <- calculation[["plotTicks"]]
  mapping$x[[2]] <- expr(time)
  mapping$y[[2]] <- expr(proportion)
  
  output1 <- ggplot2::layer(
    data=plotLines,
    mapping=mapping,
    geom="path",
    stat="identity",
    position="identity",
    params=list(...)
  )
  
  mapping$linetype <- NULL
  mapping$xend <- mapping$x
  mapping$yend <- mapping$y
  mapping$yend[[2]] <- expr(proportion + 0.8)
  
  
  output2 <- ggplot2::layer(
    data=plotTicks,
    mapping=mapping,
    geom="segment",
    stat="identity",
    position="identity",
    show.legend=FALSE,
    params=list(...)
  )
  output <- list(lines=output1, ticks=output2)
  
  if(surv_pretty){
    colors <- rep(c("blue","red","purple","orange","cyan4","green"), 10)
    colorcolumn <- as.character(mapping$colour[[2]])
    ncolors <- length(unique(plotLines[,colorcolumn]))
    
    output <- c(
      output,
      list(scale_color_manual(values=colors[1:ncolors]),
           scale_x_continuous(expand=c(0,0)),
           scale_y_continuous(expand=c(0,0)),
           theme_classic())
    )
  }
  
  return(output)
  
}

#separate the input by conditions and apply the .survcalc function to each
.survconditions <- function(data, mapping){

  time <-     as.character( mapping$x[[2]] )
  status <-   as.character( mapping$y[[2]] )
  color <-    as.character( mapping$colour[[2]] )
  linetype <- as.character( mapping$linetype[[2]] )

  data <- data[,c(time,status,color,linetype)]
  data <- as.data.frame(na.omit(data))

  if(length(color)>0 | length(linetype)>0){
    data$cOnDiTiOnS <- paste0(data[,color], data[,linetype])
  }else{
    data$cOnDiTiOnS <- "normal"
  }
  conditions <- unique(data$cOnDiTiOnS)

  tables <- lapply(conditions, function(x) subset(data, cOnDiTiOnS %in% x))
  names(tables) <- conditions

  #use the .survcalc function for each condition
  tables2 <- lapply(tables, function(x) .survcalc(data=x, time=time, status=status, color=color, colorcondition=x[1,color], linetype=linetype, linetypecondition=x[1,linetype]))

  #combine the data.frame for lines and ticks separately
  linelist <- lapply(tables2, function(x) x[["plotLines"]])
  ticklist <- lapply(tables2, function(x) x[["plotTicks"]])
  linetable <- do.call(rbind, linelist)
  ticktable <- do.call(rbind, ticklist)

  return( list(plotLines=linetable, plotTicks=ticktable) )

}

#calculate 2 tables with x and y coordinates that can be used as a direct input for geom_path (survival curve) and geom_segment (dropout indicators)
.survcalc <- function(data, time, status, color, colorcondition, linetype, linetypecondition){

  freqTable <- as.data.frame(table(data[,time]))
  colnames(freqTable) <- c("time","freq")
  freqTable$time <- as.numeric(as.character(freqTable$time))

  plotLines <- data.frame(x=0, y=100)
  plotTicks <- data.frame(x=NA, y=NA)
  nsamps <- nrow(data)
  nremain <- nsamps

  for(i in 1:nrow(freqTable)){
    iy <- tail(plotLines$y, n=1) #surviving fraction
    ix <- freqTable$time[i] #time

    isamples <- data[ data[,time]==ix , ]
    idropouts <- nrow( isamples[ isamples[,status] %in% "1" , ] )
    ideaths <-   nrow( isamples[ isamples[,status] %in% "2" , ] )

    nremain <- nremain-idropouts
    iy2 <- iy - (ideaths * iy/nremain) #iy2=iy if there were only dropouts and no deaths; iy2<i< if there were deaths
    nremain <- nremain-ideaths

    plotLines <- rbind(plotLines, data.frame(x=rep(ix, 2), y=c(iy, iy2)) )
    if(idropouts>0) plotTicks <- rbind(plotTicks, data.frame(x=ix, y=iy))
  }

  colnames(plotLines) <- c("time", "proportion")
  colnames(plotTicks) <- colnames(plotLines)
  plotLines[,color] <- as.character(colorcondition)
  plotTicks[,color] <- as.character(colorcondition)
  plotLines[,linetype] <- as.character(linetypecondition)
  plotTicks[,linetype] <- "solid"

  plotLines <- as.data.frame(na.omit(plotLines))
  plotTicks <- as.data.frame(na.omit(plotTicks))

  return(list(plotLines=plotLines, plotTicks=plotTicks))

}
