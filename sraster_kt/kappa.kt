/*
S-RASTER: Prototypal Implementation of the 'Clustering' Node
(c) 2019 Fraunhofer-Chalmers Research Centre for Industrial Mathematics

The source code in this file is written in the JVM language Kotlin. To execute it,
assuming you have both the JVM and Kotlin installed, execute the following two
commands, which combines compilation and execution:

> kotlinc kappa.kt -include-runtime -d kappa.jar && java -jar kappa.jar

*/

import kotlin.system.exitProcess

// sample input
var tiles: MutableSet<Pair<Int, Int>> =  mutableSetOf(
  Pair(10011, 10011),
  Pair(10011, 10012),
  Pair(10012, 10011),
  Pair(10012, 10012),
  Pair(54000, 20500),
  Pair(90000, 10001),
  Pair(90000, 10002),
  Pair(90000, 10003))

val min_size: Int    = 2
val prec    : Double = 3.0


fun neighbors(pos: Pair<Int, Int>): MutableSet<Pair<Int, Int>>{

  val x: Int = pos.first
  val y: Int = pos.second

  // D_Chebyshev(x, y) = 1
  val neighbors = setOf(Pair(x + 1, y    ),
                        Pair(x - 1, y    ),
                        Pair(x    , y + 1),
                        Pair(x    , y - 1),
                        Pair(x + 1, y - 1),
                        Pair(x + 1, y + 1),
                        Pair(x - 1, y - 1),
                        Pair(x - 1, y + 1))

  var result: MutableSet<Pair<Int, Int>> = mutableSetOf()

  for (n in neighbors) {
    if (tiles.contains(n)) {
      tiles.remove(n) // remove 'n' right away
      result.add(n)
    }
  }
  return result
}


fun clustering(size: Int){
  var clusters: MutableList<MutableSet<Pair<Int, Int>>> = mutableListOf()

  while (tiles.size > 0) {
    var cluster: MutableSet<Pair<Int, Int>> = mutableSetOf()
    val seed: Pair<Int, Int> = tiles.random()
    tiles.minus(seed)
    var visit: MutableSet<Pair<Int, Int>> = mutableSetOf()
    visit.add(seed)
    tiles.remove(seed)

    while (visit.size > 0) {
      val next = visit.random()
      visit.remove(next)
      cluster.add(next)
      visit.addAll(neighbors(next))

    }
    println("--------------------------------------------------------------")
    println("Found potential cluster:")
    println(cluster)
    if (cluster.size >= size) {
      clusters.add(cluster)
      println("Cluster meets threshold")
    } else {
      println("Cluster size below threshold; discarded")
    }

  }

  var id : Int = 1

  println("--------------------------------------------------------------")
  println("Final clusters, with rescaled coordinates:")
  for (c in clusters) {
    println("--------------------------------------------------------------")
    println("Cluster " + (id++) + ":")
    for (tile in c.toList()) {
      print("\t" + tile)
      println(" -> " + rescale(tile))
    }
  }

}


fun rescale(p: Pair<Int, Int>): Pair<Double, Double> {
  val scalar: Double = Math.pow(10.0, prec)

  val a: Double = (p.first).toDouble()  / scalar
  val b: Double = (p.second).toDouble() / scalar

  return Pair(a, b)
}


fun main(args: Array<String>) {
  println("--------------------------------------------------------------")
  println("Illustration of the workflow of the 'cluster' node of S-RASTER")
  println("--------------------------------------------------------------")
  println("Input:")
  println(tiles)
  println("--------------------------------------------------------------")
  println("Start clustering tiles:")
  println("(Threshold for clusters: " + min_size + " tiles.)")
  clustering(min_size)
  // adding/removing elements from set of significant tiles not implemented
}