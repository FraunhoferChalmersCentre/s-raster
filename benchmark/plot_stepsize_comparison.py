"""
For plotting the results from results/mean_daysize_benchmark_results.csv
"""
import matplotlib
import csv
from collections import defaultdict

alg_times = defaultdict(list)
alg_clusters = defaultdict(list)
times = []
stepsizes = []
with open('results/mean_daysize_benchmark_results.csv', newline='') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        stepsize = row['#points per day']
        tim = float(row['mean elapsed time[s]'])
        times.append(tim)
        stepsizes.append(stepsize)


from matplotlib import markers
import matplotlib.pyplot as plt
import numpy as np


fig, ax = plt.subplots()
ax.plot(stepsizes, times, marker='*', color="tab:green")

ax.set_ylabel("Time [s]")
ax.set_xlabel("Step size (points per day)")
ax.set_title("S-Raster: step size vs window size", fontsize=18)

axT = ax.twiny()
# the first label was not visible for some reason
axT.set_xticklabels([0]+[ int(500_000/int(s)) for s in stepsizes])
axT.set_xlim(ax.get_xlim())
axT.set_xlabel("Window size")

fig.tight_layout()
# plt.show()

plt.savefig("stepsize_plot.png", format="png")