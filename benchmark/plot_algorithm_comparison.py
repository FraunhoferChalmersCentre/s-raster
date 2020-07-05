"""
For plotting the results from results/mean_benchmark_results.csv
"""
import matplotlib
import csv
from collections import defaultdict

alg_times = defaultdict(list)
alg_clusters = defaultdict(list)
with open('results/mean_benchmark_results.csv', newline='') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        alg = row['algorithm']
        tim = float(row['mean elapsed time[s]'])
        nclusters = float(row['#clusters'])
        alg_times[alg].append(tim)
        alg_clusters[alg].append(nclusters)


from matplotlib import markers
import matplotlib.pyplot as plt
import numpy as np


############################## Time plot ##############################
fig, (ax, ax2) = plt.subplots(2, 1, sharex=True, figsize=(6.5, 5.5))
x = np.linspace(500_000, 5_000_000, num=10)

# plot the same data on both axes
ax.plot(x, alg_times['DBStream'], label="DBStream", marker='o', color="tab:red")
ax2.plot(x, alg_times['DStream'], label="DStream", marker='s', color="tab:blue")
ax2.plot(x, alg_times['Windowed k-means'], label="Windowed", marker=markers.CARETUP, color="tab:orange")
ax2.plot(x, alg_times['S-RASTER'], label="S-RASTER", marker=markers.CARETDOWN, linestyle="--", color="tab:green")

ax.legend(loc='lower center', fontsize='x-large')
ax2.legend(loc='lower center', fontsize='x-large')

# zoom-in / limit the view to different portions of the data
ax.set_ylim(51.9, 54.5)  # outliers only
ax2.set_ylim(0, 2.6)  # most of the data

ax2.set_ylabel("Time [s]")
ax2.set_xlabel("#Points")
ax.set_title("Run time for each Algorithm", fontsize=16)

# hide the spines between ax and ax2
ax.spines['bottom'].set_visible(False)
ax2.spines['top'].set_visible(False)
ax.xaxis.tick_top()
ax.tick_params(labeltop=False)  # don't put tick labels at the top
ax2.xaxis.tick_bottom()


d = .015  # how big to make the diagonal lines in axes coordinates
# arguments to pass to plot, just so we don't keep repeating them
kwargs = dict(transform=ax.transAxes, color='k', clip_on=False)
ax.plot((-d, +d), (-d, +d), **kwargs)        # top-left diagonal
ax.plot((1 - d, 1 + d), (-d, +d), **kwargs)  # top-right diagonal

kwargs.update(transform=ax2.transAxes)  # switch to the bottom axes
ax2.plot((-d, +d), (1 - d, 1 + d), **kwargs)  # bottom-left diagonal
ax2.plot((1 - d, 1 + d), (1 - d, 1 + d), **kwargs)  # bottom-right diagonal

fig.tight_layout()
fig.savefig("compare_algs_time.png", format="png")


############################# Cluster plot #############################
clust_fig, clust_ax = plt.subplots(figsize=(6.5, 5.5))

# plot the same data on both axes
clust_ax.plot(x, alg_clusters['DBStream'], label="DBStream", marker='o', color="tab:red")
clust_ax.plot(x, alg_clusters['DStream'], label="DStream", marker='s', color="tab:blue")
clust_ax.plot(x, alg_clusters['Windowed k-means'], label="Windowed", marker=markers.CARETUP, color="tab:orange")
clust_ax.plot(x, alg_clusters['S-RASTER'], label="S-RASTER", marker=markers.CARETDOWN, linestyle="--", color="tab:green")

clust_ax.legend(loc='best', fontsize='x-large')

clust_ax.set_ylabel("#clustered")
clust_ax.set_xlabel("#Points")
clust_ax.set_title("Number of clusters found", fontsize=16)

clust_fig.tight_layout()
clust_fig.savefig("compare_algs_clustered.png", format="png")