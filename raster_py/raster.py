"""
Contraction Clustering (RASTER):
Reference Implementation in Python with an Example
(c) 2016 - 2020 Fraunhofer-Chalmers Centre for Industrial Mathematics

Algorithm development and implementation:
Gregor Ulm (gregor.ulm@fcc.chalmers.se)

Requirements:
. Python 3

For a description of the algorithm including relevant theory, please
consult our paper on Contraction Clustering (RASTER).

To run this script, type
> python3 raster.py

"""

import os
import clustering as c

def raster(all_points, precision, threshold, min_size):

    ## Step 1: Projection
    (tiles, scalar) = c.map_to_tiles(all_points, precision, threshold)

    ## Step 2: Agglomeration
    clusters = c.raster_clustering_tiles(tiles, min_size)

    return (clusters, scalar)


if __name__ == "__main__":

    # load input data
    with open("input/sample.csv", "r") as f:
        content = f.readlines()

    all_points = []

    for line in content:

        line   = line.strip()
        (x, y) = line.split(",")
        x      = float(x)
        y      = float(y)

        all_points.append((x, y))


    """
    RASTER clusters:

    RASTER projects points to tiles and disregards the former after the
    projection has been performed. Thus, it requires merely constant
    space, assuming bounded integers or a bounded coordinate system like
    the GPS coordinate system for our planet.

    Input is projected to points that represent tiles.

    """
    precision = 1
    tau       = 5 # threshold
    min_size  = 5

    clusters, scalar = raster(all_points, precision, tau, min_size)
    print("Number of clusters: ", len(clusters))

    output = []
    count  = 1
    for cluster in clusters:
        for (x, y) in cluster:
            x = x / scalar
            y = y / scalar
            output.append((count, x, y))
        count += 1

    f = open("output/clustered.csv", "w")
    f.write("Cluster Number, X-Position, Y-Position\n")
    for (num, x, y) in output:
        f.write(str(num) + ", " + str(x) + ", " + str(y) + "\n")
    f.close()
