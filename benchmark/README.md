# S-RASTER in _stream_ (the R Library)

## Versions
There are two versions of S-RASTER:
* one called S-RASTER which is the single-threaded version of the algorithm described in the paper
* and similar one called SW-RASTER which doesn't have the notion of time but the number of points instead

The biggest difference between these is the input.
SW-RASTER takes 2D data points and S-RASTER takes 3D data points where the third dimension is a "day counter".
The 3D data is sometimes referred to as _time annotated_ data.

## Data
The data was created like it was for previous RASTER paper except it wasn't _shuffled_ (see  `../1_Data_Generator_Big/`).
The fact that is not shuffled is important for the time annotated data to guarantee that clusters disappear/move.

The R scripts assume the data to be in the `data/` folder.
The `change_label.py` script is used for changing how many points there are per day in a time annotated data file.
But this script can also be used for creating a time annotated data file from a 2D csv file.

## Results
The `results/` folder contains saved results from the scripts:
* `algorithm_comparisons.py` -> `benchmark_results.csv` and `mean_benchmark_results.csv`.
  This used annotated data with 10 cluster (5000 points) per day
* `compare_sraster.r`-> `replication_scores.txt` (console print), `replication_benchmark.png` (plot saved) and `replication_benchmark_weighted.png` (plot saved)
* `plot_algorithm_comparison.py` -> `compare_algs_time.png` and `compare_algs_clustered.png`
* `plot_stepsize_comparison.py`-> `stepsize_plot.png`
* `stepsize_comparison.r` -> `mean_daysize_benchmark_results.csv` and `daysize_benchmark_results.csv`
* `timed_data_comparison.r` -> `timed_mean_benchmark_results.csv` and `timed_benchmark_results.csv`.
  This used annotated data with 500 points (1 cluster) per day

## Requirements
* R
* [stream](https://www.rdocumentation.org/packages/stream)
* Rcpp
* gcc
* Python
