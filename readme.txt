S-RASTER: Contraction Clustering for Evolving Data Streams
(c) 2016 - 2020 Fraunhofer-Chalmers Research Centre
                for Industrial Mathematics (FCC), Gothenburg, Sweden

Research and development by Gregor Ulm, Simon Smith, Adrian Nilsson,
Emil Gustavsson, and Mats Jirstrand.

This repository contains artefacts related to our paper "S-RASTER: Contraction
Clustering for Evolving Data Streams."

The content is as follows:

\raster_py:
 Complete reference implementation of RASTER for batch data, written in Python.

\sraster_kt:
 Prototypal implementations of the three nodes described in our paper on
 RASTER for evolving data streams (S-RASTER), i.e. 'projection', 'accumulation', 
 and 'clustering'. This is not a complete implementation but nonetheless helpful
 for illustrating how our algorithm works. It should be straightforward to
 adapt the provided Kotlin source code for use with a standard stream processing
 framework.
