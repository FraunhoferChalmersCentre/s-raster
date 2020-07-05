#include "SRaster.h"

class SWRaster: public SRaster {

protected:
    int data_count = 0;  // a cyclic value

public:
    int period_size;

    SWRaster(double precision, int min_cluster_size, int threshold, int window_size, int period_size);

    /**
     * Called from R with update()
     * 
     * @param data: Each row is a data point.
     */
    void cluster(Rcpp::NumericMatrix data);
};