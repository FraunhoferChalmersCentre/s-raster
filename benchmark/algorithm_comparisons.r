#######################################################################
# A benchmark script to compare the run time of S-RASTER and three
# other stream algorithms.
source('sraster.r')
printf <- function(...) cat(sprintf(...))

nr_repeats = 10L
n_clusters = 1000L
algorithms <- list(
  "Windowed k-means"=function() { DSC_TwoStage(micro = DSC_Window(horizon = 100),
               macro = DSC_Kmeans(k = 100)) },
  "DStream"=function() { DSC_DStream(gridsize = 0.0003) },
  "DBStream"=function() { DSC_DBSTREAM(r = 0.0002, Cm=0.0, gaptime = 25000) },
  "S-RASTER"=function() { DSC_SRaster(p=3.5, window_size = 10) }
)

write("run number,algorithm, user time[s],elapsed time[s],#clusters, #micro clusters", file="benchmark_results.csv")
write("algorithm,mean elapsed time[s],#clusters", file="mean_benchmark_results.csv")

datafile <- "data/data_10000.csv"
timed_datafile <- "data/timed_data_10000.csv"

for (alg_name in names(algorithms)) {
  alg_fun <- algorithms[[alg_name]]
  times <- c()
  clustereds <- c()
  for (run_number in 1:nr_repeats) {
    alg <- alg_fun()
    if (alg_name == "S-RASTER") {
      cat("Use timed data\n")
      stream <- DSD_ReadCSV(timed_datafile)
    } else {
      cat("Use 2D data\n")
      stream <- DSD_ReadCSV(datafile)
    }
    n_steps <- 10L
    for (x in 1:n_steps) {
      nr_points <- 500L*n_clusters
      t <- system.time({ update(alg, stream, nr_points) })
      times <- c(times, t[3])

      end_clusters <- NROW(get_centers(alg, type='macro'))
      clustereds <- c(clustereds, end_clusters)

      line <- sprintf("%d,%s,%.3f,%.3f,%d", run_number, alg_name, t[1], t[3], end_clusters)
      cat(paste(line, "\n"))
      write(line, file="benchmark_results.csv", append=TRUE)
    }
    close_stream(stream)
    #plot(a, type = "both", weights = FALSE)
  }
  m_times <- matrix(times, nrow = n_steps)
  avg_times <- apply(m_times, 1, mean)
  m_clustereds <- matrix(clustereds, nrow = n_steps)
  avg_clustereds <- apply(m_clustereds, 1, mean)
  for (i in 1:n_steps){
    mean_t = avg_times[[i]]
    mean_c = avg_clustereds[[i]]
    line <- sprintf("%s,%.3f,%.1f", alg_name, mean_t,mean_c)
    write(line, file="mean_benchmark_results.csv", append=TRUE)
  }
}

cat("Done!\n")
