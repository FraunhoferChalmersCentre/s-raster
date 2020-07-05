#include "SWRaster.h"


SWRaster::SWRaster(
    double precision,
    int min_cluster_size,
    int threshold,
    int window_size,
    int period_size
):
    SRaster(
        precision,
        min_cluster_size,
        threshold, window_size
    ),
    period_size(period_size){}


void SWRaster::cluster(Rcpp::NumericMatrix data){
    for(int i = 0; i < data.nrow(); i++) {
        data_count = (data_count + 1) % period_size;
        if ( data_count == 0 ){
            // κ; cluster
            clusterer();
            period_j++;
            // Rprintf("New clustering: %d\n", period_j);
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


// Expose fields and methods to R
RCPP_EXPOSED_CLASS(SWRaster)

RCPP_MODULE(MOD_SWRaster){

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
        .method("microToMacro", &SRaster::microToMacro)
    ;

    class_<SWRaster>("SWRaster")
        .derives<SRaster>("SRaster")
        .constructor<double, int, int, int, int>()
        .field("period_size", &SWRaster::period_size)
        .method("cluster", &SWRaster::cluster)
    ;
}