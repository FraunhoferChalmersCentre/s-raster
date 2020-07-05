library(stream)
Rcpp::sourceCpp("SWRaster.cpp")

DSC_SWRaster <- function(p=3, m=4, t=5, window_size=3, period_size=500) {

  SWRaster <- SWRasterR$new(p, m, t, window_size, period_size)

  structure(
    list(
      description = "SW-RASTER",
      RObj = SWRaster
    ), class = c("DSC_SWRaster", "DSC_Micro", "DSC_R", "DSC")
  )
}

SWRasterR <- setRefClass("SWRaster", fields = list(
  C ="ANY"
))

SWRasterR$methods(
  initialize = function(precision, min_size, threshold, window_size, period_size){
    ## Exposed C class
    C <<- new(SWRaster, precision, min_size, threshold, window_size, period_size)
    .self
  })


SWRasterR$methods(
  cache = function(){
    stop("SaveDSC not implemented for DSC_BIRCH!")
  })

# CF-Tree insertion: All data objects of a matrix are rowwise inserted into the CF-Tree
SWRasterR$methods(
  cluster = function(newdata) {
    .self$C$cluster(as.matrix(newdata))
  })

# This function returns all micro clusters of a given CF-Tree.
SWRasterR$methods(
  get_microclusters = function() {
    .self$C$get_microclusters()
  }
)

# This function returns all micro cluster weights of a given CF-Tree.
SWRasterR$methods(
  get_microweights = function(){
    .self$C$get_microweights()
  }
)

SWRasterR$methods(
  get_macroclusters = function() {
    .self$C$get_macroclusters()
  }
)

SWRasterR$methods(
  get_macroweights = function(){
    .self$C$get_macroweights()
  }
)

SWRasterR$methods(
  microToMacro = function(micro=NULL, ...){
    .self$C$microToMacro()
  }
)

