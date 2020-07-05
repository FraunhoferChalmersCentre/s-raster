S-RASTER: Contraction Clustering for Evolving Data Streams
(c) 2016 - 2020 Fraunhofer-Chalmers Research Centre
                for Industrial Mathematics (FCC), Gothenburg, Sweden

Research and development by Gregor Ulm, Simon Smith, Adrian Nilsson,
Emil Gustavsson, and Mats Jirstrand.

This repository contains artifacts related to our paper "S-RASTER: Contraction
Clustering for Evolving Data Streams."

The content is as follows:

\benchmark
 Copy of our internal benchmark setup, including an implementation of S-RASTER
 for use in the standard stream processing benchmarking utility 'rstream'. The
 provided scripts make it possible to reproduce the results presented in our
 paper. The input data need to be generated with the provided data generator
 first (see below).

\data_generator
 Python script for generating synthetic data containing dense clusters that are
 spread out on a 2D canvas.

\raster_py:
 Complete reference implementation of RASTER for batch data, written in Python.

\sraster_kt:
 Prototypal implementations of the three nodes described in our paper on
 RASTER for evolving data streams (S-RASTER), i.e. 'projection', 'accumulation', 
 and 'clustering'. This is not a complete implementation but nonetheless helpful
 for illustrating how our algorithm works.