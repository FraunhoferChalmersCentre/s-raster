# retains number of observations
def map_to_tiles(points    : list,
                 precision : int ,
                 tau       : int ) -> (dict, int):
    """
    The key idea behind this function is to reduce the precision of
    spatial coordinates. These coordinates are assigned to the
    bottom-left corner of an imaginary tile, which is defined by the
    reduced precision. For instance, the tile corner (50.0212, 1.1123)
    can be used to reduce all points (50.0212__, 1.1123__) to one
    single point.

    """
    scalar    = 10 ** precision
    allPoints = dict()

    for (lat, lon) in points:
        lat = int(lat * scalar)
        lon = int(lon * scalar)
        point = (lat, lon)

        numPointsInTile  = allPoints.get(point, 0)
        allPoints[point] = numPointsInTile + 1

    # filter results to only retain tiles that contain at lest the
    # provided threshold value of observations
    result = set()
    for k, v in allPoints.items():
        if v >= tau:
            result.add(k)

    return (result, scalar)


def get_neighbors(coordinate: tuple, tiles: set) -> list:
    # neighbor lookup in O(1)

    (x, y) = coordinate
    assert isinstance(x, int)
    assert isinstance(y, int)

    # D_Chebyshev(x, y) = 1
    neighbors  = [(x + 1, y    ),
                  (x - 1, y    ),
                  (x    , y + 1),
                  (x    , y - 1),
                  (x + 1, y - 1),
                  (x + 1, y + 1),
                  (x - 1, y - 1),
                  (x - 1, y + 1)]

    result = []
    for n in neighbors:
        if n in tiles:
            tiles.remove(n) # remove 'n' right away
            result.append(n)

    return result


def raster_clustering_tiles(tiles: set, min_size: int) -> list:
    clusters = []

    while tiles:
        cluster = set()
        visit   = [tiles.pop()] # arbitrary seed for new cluster

        while visit:
            # pop a coordinate off 'visit'; get their neighbors
            val = visit.pop()
            cluster.add(val)
            visit.extend(get_neighbors(val, tiles))

        if len(cluster) >= min_size:
            # add to list of clusters
            clusters.append(cluster)

    return clusters
