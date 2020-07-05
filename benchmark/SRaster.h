#include <Rcpp.h>
#include <unordered_map>
#include <unordered_set>
#include <vector>
#include <cmath>
using namespace Rcpp;

struct Tile {
    int x;
    int y;

    // constructor
	Tile(int x, int y)
	{
		this->x = x;
		this->y = y;
	}

	// operator== is required to compare keys in case of hash collision
	bool operator==(const Tile &p) const
	{
		return x == p.x && y == p.y;
	}
};

// specialized hash function for unordered_map keys
struct HashFn
{
	std::size_t operator() (const Tile &p) const
	{
		std::size_t h1 = std::hash<int>()(p.x);
		std::size_t h2 = std::hash<int>()(p.y);

		return h1 ^ (h2 << 1);
	}
};
typedef std::unordered_map<Tile, int, HashFn> TileCount;
typedef std::unordered_set<Tile, HashFn> TileSet;
typedef std::vector<Tile> TileVec;

class SRaster {

protected:
    double scalar;
    int period_j = -1;  // also known as 'day' or Delta_j
    TileCount totals;
    std::unordered_map<int, TileCount> windows;  // counts sliced up into time periods from 'totals'
    TileSet significant_tiles;
    std::vector<TileVec> clusters;
    bool clusters_out_of_date = false;

public:
    double prec;
    int min_cluster;
    int threshold;
    int window_size;

    SRaster(double precision, int min_cluster_size, int threshold, int window_size):
        prec(precision), min_cluster(min_cluster_size), threshold(threshold), window_size(window_size) 
    {
        scalar = pow(10.0, precision);
        Rprintf("Scalar=%f\n", scalar);
    }

    /**
     * Called from R with update()
     * 
     * @param data: Each row is a data point.
     */
    void cluster(Rcpp::NumericMatrix data);

    /**
     * Removes neighbors to t in tiles and return a vector of those neighbors.
     */
    TileVec pop_neighbors(Tile& t, TileSet& tiles);

    void clusterer();

    /**
     * Called from R with get_centers()
     * 
     * @return A row-wise matrix of points.
     *         Each point is a cluster position.
     */
    Rcpp::NumericMatrix get_microclusters();

    /**
     * Called from R with get_weights()
     * A micro weight is the number of points for a micro cluster.
     * 
     * @return Weight of each micro cluster.
     */
    Rcpp::IntegerVector get_microweights();

    /**
     * Called from R with get_centers()
     * 
     * @return A row-wise matrix of points.
     *         Each point is a cluster position.
     */
    Rcpp::NumericMatrix get_macroclusters();

    /**
     * Called from R with get_weights()
     * 
     * @return Weight of each macro cluster.
     */
    Rcpp::IntegerVector get_macroweights();

    Rcpp::IntegerVector microToMacro(); // Not sure if this is every used

};