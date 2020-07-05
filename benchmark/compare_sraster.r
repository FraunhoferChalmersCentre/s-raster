#######################################################################
# A visual and qualitative comparison with SW-RASTER
# This is basically an addition to a benchmark performed in
# "Introduction to stream: An Extensible Framework for Data Stream Clustering Research with R"
# — by Hahsler, M., Bolanos, M. and Forrest, J.
set.seed(1000)
library("stream")
if(!exists('SWRaster', mode='character')) source('swraster.r')

# Store stream to memory so that it can be reset for each algorithm
stream <- DSD_Memory(DSD_BarsAndGaussians(noise=0.1), n = 2000)

algorithms <- list(
  # 'Sample'= DSC_TwoStage(micro = DSC_Sample(k = 100),
  #                        macro = DSC_Kmeans(k = 4)),
  'Window'= DSC_TwoStage(micro = DSC_Window(horizon = 100),
                         macro = DSC_Kmeans(k = 4)),
  'D-Stream' = DSC_DStream(gridsize = 0.7, Cm = 1.5),
  # 'BICO' = DSC_BICO(k = 3, p = 10, space = 100, iterations = 10),
  'DBSTREAM' = DSC_DBSTREAM(r = 0.55),
  'SW-RASTER' = DSC_SWRaster(0.3, m=5, t=7, window_size=3, period_size = 1000)
)

# Clustering
for(a in algorithms) {
  reset_stream(stream)
  t <- system.time({update(a, stream, 2000) })
  print(a)
  print(t)
}

# Plotting
op <- par(no.readonly = TRUE)
layout(mat = matrix(1:length(algorithms), ncol = 2))
for(a in algorithms) {
  reset_stream(stream)
  plot(a, stream, main = description(a), assignment = FALSE, weights = FALSE, type = "both")
}
par(op)

# Evaluations
res <- sapply(algorithms, nclusters, type = "micro")
print(res)

evaluations <- sapply(algorithms, FUN=function(a) {
  reset_stream(stream, pos = 1001)
  evaluate(
    a, stream,
    measure = c("numMacroClusters", "numMicroClusters", "purity", "SSQ", "cRand", "silhouette", "Manhattan"),
    type = "micro",
    n = 500
  )
})
print(evaluations)
