#include "SRaster.h"

void SRaster::cluster(Rcpp::NumericMatrix data){
    for(int i = 0; i < data.nrow(); i++) {
        int dz = static_cast<int>(data(i, 2));
        if ( dz > period_j ){
            // κ; cluster
            clusterer();
            period_j = dz;
            // Rprintf("New time: %d\n", period_j);
            int key = period_j - window_size;
            // Remove old entries
            if (windows.count(key) == 1) {
                auto vals = windows[key];
                for (auto const& item: vals) {
                    auto old_count = totals[item.first];  // TODO: is values copied?
                    totals[item.first] -= item.second;
                    auto new_count = totals[item.first];
                    if ( old_count >= threshold && new_count < threshold ) {
                        clusters_out_of_date = true;
                        significant_tiles.erase(item.first); // κ; remove
                    }
                    if (new_count == 0) {
                        totals.erase(item.first); // κ; add
                    }
                }
                windows.erase(key);
            }
        }
        // project
        double x = data(i, 0);
        double y = data(i, 1);
        Tile p {(int)floor(x * scalar), (int)floor(y * scalar)};

        // accumulate
        totals[p] += 1;
        windows[period_j][p] += 1;

        if(totals[p] == threshold) {
            clusters_out_of_date = true;
            significant_tiles.insert(p);
        }
    }
}


void SRaster::clusterer() {
    std::vector<TileVec> clusters_;
    auto to_visit = TileSet(significant_tiles);
    while (!to_visit.empty()) {
        // pop a tile
        auto tile = *to_visit.begin();
        to_visit.erase(to_visit.begin());

        TileVec cluster_build;
        cluster_build.push_back(tile);
        TileVec to_check = pop_neighbors(tile, to_visit);
        while (!to_check.empty()) {
            Tile t = to_check.back();
            to_check.pop_back();
            cluster_build.push_back(t);

            TileVec new_neighbors = pop_neighbors(t, to_visit);
            to_check.insert(
                to_check.end(),
                new_neighbors.begin(),
                new_neighbors.end()
            );
        }

        if (cluster_build.size() >= min_cluster) {
            clusters_.push_back(cluster_build);
        }
    }
    clusters_out_of_date = false;
    this->clusters = clusters_;
}


TileVec SRaster::pop_neighbors(Tile& t, TileSet& tiles) {
    TileVec candidates = {
        Tile(t.x + 1, t.y    ),
        Tile(t.x - 1, t.y    ),
        Tile(t.x    , t.y + 1),
        Tile(t.x    , t.y - 1),
        Tile(t.x + 1, t.y - 1),
        Tile(t.x + 1, t.y + 1),
        Tile(t.x - 1, t.y - 1),
        Tile(t.x - 1, t.y + 1),
    };
    TileVec retur;
    for (auto const& item: candidates) {
        if (tiles.erase(item) == 1) {
            retur.push_back(item);
        }
    }
    return retur;
}

Rcpp::NumericMatrix SRaster::get_microclusters(){
    NumericMatrix mat(significant_tiles.size(), 2);
    int row = 0;
    double offset = 1 / scalar / 2;
    for (auto const& item: significant_tiles) {
        mat(row, 0) = (double)item.x / scalar + offset;
        mat(row, 1) = (double)item.y / scalar + offset;
        row++;
    }
    return mat;
}


Rcpp::IntegerVector SRaster::get_microweights(){
    IntegerVector vec(significant_tiles.size());
    int micro = 0;
    for (auto const& item: significant_tiles) {
        vec[micro++] = totals[item];
    }
    return vec;
}

Rcpp::NumericMatrix SRaster::get_macroclusters(){
    if (clusters_out_of_date) {
        clusterer();
    }
    NumericMatrix mat(clusters.size(), 2);
    int row = 0;
    std::size_t total_size = 0;
    double offset = 1 / scalar / 2;
    for (auto const& cluster: clusters) {
        double sum_x = 0;
        double sum_y = 0;
        for (auto const& tile: cluster) {
            // Rprintf("Tile.x: %d\n", tile.x);
            sum_x += static_cast<double>(tile.x) / scalar;
            sum_y += static_cast<double>(tile.y) / scalar;
        }
        auto size = static_cast<double>(cluster.size());
        double avg_x = sum_x / size;
        double avg_y = sum_y / size;
        mat(row, 0) = avg_x + offset;
        mat(row, 1) = avg_y + offset;
        row++;
    }
    return mat;
}

Rcpp::IntegerVector SRaster::get_macroweights(){
    if (clusters_out_of_date) {
        clusterer();
    }
    IntegerVector vec(totals.size());
    int micro = 0;
    for (auto const& item: totals) {
        vec[micro++] = item.second;
    }
    return vec;
}

Rcpp::IntegerVector SRaster::microToMacro(){ // Not sure if this is every used
    Rprintf("Potajto; Potato\n");
    return IntegerVector::create(1,2,3,4);
}

// Expose fields and methods to R
RCPP_EXPOSED_CLASS(SRaster)

RCPP_MODULE(MOD_SRaster){
    class_<SRaster>("SRaster")
        .constructor<double, int, int, int>()
        .field("prec", &SRaster::prec)
        .field("min_cluster", &SRaster::min_cluster)
        .field("threshold", &SRaster::threshold)
        .field("window_size", &SRaster::window_size)
        .method("get_microclusters", &SRaster::get_microclusters)
        .method("get_microweights", &SRaster::get_microweights)
        .method("get_macroclusters", &SRaster::get_macroclusters)
        .method("get_macroweights", &SRaster::get_macroweights)
        .method("cluster", &SRaster::cluster)
        .method("microToMacro", &SRaster::microToMacro);
}