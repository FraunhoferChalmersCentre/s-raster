library(stream)
Rcpp::sourceCpp("SRaster.cpp")

DSC_SRaster <- function(p=3, m=4, t=5, window_size=3) {

  SRaster <- SRasterR$new(p, m, t, window_size)

  structure(
    list(
      description = "S-RASTER",
      RObj = SRaster
    ), class = c("DSC_SRaster", "DSC_Micro", "DSC_R", "DSC")
  )
}

SRasterR <- setRefClass("SRaster", fields = list(
  C ="ANY"
))

SRasterR$methods(
  initialize = function(precision, min_size, threshold, window_size){
    ## Exposed C class
    C <<- new(SRaster, precision, min_size, threshold, window_size)
    .self
  })


SRasterR$methods(
  cache = function(){
    stop("SaveDSC not implemented for DSC_BIRCH!")
  })

# CF-Tree insertion: All data objects of a matrix are rowwise inserted into the CF-Tree
SRasterR$methods(
  cluster = function(newdata) {
    .self$C$cluster(as.matrix(newdata))
  })

# This function returns all micro clusters of a given CF-Tree.
SRasterR$methods(
  get_microclusters = function() {
    .self$C$get_microclusters()
  }
)

# This function returns all micro cluster weights of a given CF-Tree.
SRasterR$methods(
  get_microweights = function(){
    .self$C$get_microweights()
  }
)

SRasterR$methods(
  get_macroclusters = function() {
    .self$C$get_macroclusters()
  }
)

SRasterR$methods(
  get_macroweights = function(){
    .self$C$get_macroweights()
  }
)

SRasterR$methods(
  microToMacro = function(micro=NULL, ...){
    .self$C$microToMacro()
  }
)

