#######################################################################
#  Compare how long it takes to compute a number of points when
#  they are spread out over a variable number of "days".
source('sraster.r')

nr_repeats = 10L
write("#points per day,window size,run number, user time[s],elapsed time[s],#clusters, #micro clusters", file="daysize_benchmark_results.csv")
write("#points per day,mean elapsed time[s],#clusters", file="mean_daysize_benchmark_results.csv")

timed_datafile <- "data/timed_data_10000.csv"
nr_points <- 500L*10000L
ws = list(
  1000L,
  500L,
  200L,
  100L,
  20L,
  10L,
  2L,
  1L
)

for (w in ws) {
  points_per_day <- as.integer(500L*(1000L/w))
  system2('python3', args = c('change_label.py', timed_datafile, as.character(points_per_day)))

  times <- c()
  clustereds <- c()
  for (run_number in 1:nr_repeats) {
    alg <- DSC_SRaster(p=3.5, window_size = w)

    stream <- DSD_ReadCSV(timed_datafile)
    t <- system.time({ update(alg, stream, nr_points) })
    close_stream(stream)
    times <- c(times, t[3])

    end_clusters <- NROW(get_centers(alg, type='macro'))
    clustereds <- c(clustereds, end_clusters)

    line <- sprintf("%d,%d,%d,%.3f,%.3f,%d", points_per_day, w, run_number, t[1], t[3], end_clusters)
    cat(paste(line, "\n"))
    write(line, file="daysize_benchmark_results.csv", append=TRUE)
  }

  avg_times <- lapply(times, mean)
  avg_clustereds <- lapply(clustereds, mean)

  mean_t = avg_times[[1]]
  mean_c = avg_clustereds[[1]]
  line <- sprintf("%d,%.3f,%d", points_per_day, mean_t, mean_c)
  write(line, file="mean_daysize_benchmark_results.csv", append=TRUE)
}
cat("Done!\n")
