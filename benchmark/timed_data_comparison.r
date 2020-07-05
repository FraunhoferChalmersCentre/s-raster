#######################################################################
# A benchmark script for S-RASTER with different window sizes and
# increasing data files
source('sraster.r')
printf <- function(...) cat(sprintf(...))

nr_repeats = 5
n_clusters = list(100, 1000, 10000, 100000)
ws = list(10, 100, 1000, 10000, 100000)

write("#clusters,window size,user time[s],elapsed time[s],#clustered in the end", file="timed_benchmark_results.csv")
write("#clusters,window size,mean elapsed time[s],#runs", file="timed_mean_benchmark_results.csv")

for (n in n_clusters) {
  filename <- sprintf("timed_data_%d.csv", n)
  for (w in ws) {
    if(w > n) break
    times <- c()
    for (repeatme in 1:nr_repeats) {
      raster <- DSC_SRaster(p=3.5, window_size = w)
      
      stream <- DSD_ReadCSV(filename)
      t <- system.time({ update(raster, stream, 500*n) })
      close_stream(stream)
      times <- c(times, t[3])

      end_clusters <- NROW(get_centers(raster, type='macro'))
      line <- sprintf("%d,%d,%.3f,%.3f,%d", n, w, t[1], t[3], end_clusters)
      cat(paste(line, "\n"))
      write(line, file="timed_benchmark_results.csv", append=TRUE)
    }
    mean_t <- sum(times) / length(times)
    line <- sprintf("%d,%d,%.3f,%d", n, w, mean_t, length(times))
    write(line, file="timed_mean_benchmark_results.csv", append=TRUE)
  }
}