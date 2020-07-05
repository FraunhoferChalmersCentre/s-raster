/*
S-RASTER: Prototypal Implementation of the 'Count' Node
(c) 2019 Fraunhofer-Chalmers Research Centre for Industrial Mathematics

This is a complete implementation of the core of S-RASTER, i.e. the 'count' node,
which maintains a record of significant tiles as they evolve over time. The missing
parts are the nodes 'project' and 'cluster'. However, these can be directly adapted
from our previous source code release on RASTER.

The source code in this file is written in the JVM language Kotlin. To execute it,
assuming you have both the JVM and Kotlin installed, execute the following two
commands, which combines compilation and execution:

> kotlinc alpha.kt -include-runtime -d alpha.jar && java -jar alpha.jar

*/

val threshold   : Int =  4  // threshold for significant tile
val window_size : Int =  3  // size of sliding window


// Input stream of format (x, y, day)

// sample input 1
val inputs =  listOf(
  Triple(10, 10, 0),
  Triple(10, 10, 1),
  Triple(10, 10, 1),
  Triple(10, 10, 2), // (10, 10) is now a significant tile
  Triple(99, 99, 3),
  Triple(10, 10, 4),
  Triple(10, 10, 4),
  Triple(10, 10, 5),
  Triple(10, 10, 6),
  Triple(99, 99, 7),
  Triple(99, 99, 8)
  )

/*
// sample input 2
val inputs =  listOf(
  Triple(10, 10, 0),
  Triple(10, 10, 1),
  Triple(10, 10, 1),
  Triple(10, 10, 2),
  Triple(99, 99, 3),
  Triple(10, 10, 3),
  Triple(10, 10, 3),
  Triple(10, 10, 3),
  Triple(10, 10, 3),
  Triple(99, 99, 4),
  Triple(99, 99, 4)
  )
*/

/*
// sample input 3
// Interpolate missing days
val inputs =  listOf(
  Triple(10, 10, 0),
  Triple(10, 10, 1),
  Triple(10, 10, 1),
  Triple(10, 10, 2),
  // days 3 to 5 missing
  Triple(10, 10, 6),
  Triple(99, 99, 7),
  Triple(99, 99, 8)
  )
*/

var day : Int = -1  // global state: current day

// running total of all tiles; key: (x, y), value: count
var totals = mutableMapOf<Pair<Int, Int>, Int>()

// sliding window; key: day, value: map with key: (x, y), value: count
var window = mutableMapOf<Int, MutableMap<Pair<Int, Int>, Int>>()

fun main(args: Array<String>) {

  println("------------------------------------------------------------")
  println("Illustration of the workflow of the 'count' node of S-RASTER")
  println("------------------------------------------------------------")

  for ((x, y, d) in inputs) {

    if (d < day) {
      throw Exception("Days need to be non-strictly increasing")
    }

    if (d == day + 1) {
      newDay(x, y, d)
    }

    if (d > day + 1) {
      println("************************************************************")
      println("Need to interpolate days:")
      println("Last day: " + day + "; current day: " + d)

      // advance sliding window day by day:
      var tmp = day + 1
      while (tmp < d) {
        println("*** Interpolate Day: " + tmp)
        newDay(x, y, tmp)
        tmp += 1
      }
      println("Interpolation done; continuing with input value")
      println("************************************************************")
      day = d
      newDay(x, y, d)
    }

    // update totals; assumes that threshold > 1
    if (totals.containsKey(Pair(x, y))) {
      var old = totals.get(Pair(x, y))!! // throws NPE if null
      var new = old + 1
      if (new == threshold) {
        println("** Tile " + Pair(x, y) + " now significant")
        // Integration w/ 'cluster': send tuple (x, y, -1)
        println("Send (" + x + ", " + y + ", -1) to node 'cluster')")
      }
      totals.put(Pair(x, y), new)
    } else {
      totals.put(Pair(x, y), 1)
    }

    // update window
    if (window.containsKey(day)) {
      var dayEntry = window.get(day)!!
      if (dayEntry.containsKey(Pair(x, y))) {
        var tmp = dayEntry.get(Pair(x, y))!!
        dayEntry.put(Pair(x, y), tmp + 1)
      } else {
        dayEntry.put(Pair(x, y), 1)
      }
      window.put(day, dayEntry)
    } else {
      var tmp = mutableMapOf(Pair(x, y) to 1)
      window.put(day, tmp)
    }


    println("Updated totals, after (" + x + ", " + y + ", " + d + "):")
    printTotals()
  }
  println("------------------------------------------------------------")
  println("Final totals:")
  printTotals()
  println("Final window:")
  printWindow()
  println("------------------------------------------------------------")
}


fun printTotals() {
  for (x in totals) {
    println(x)
  }
}

fun printWindow() {
  for (x in window) {
    println(x)
  }
}


// pune sliding window and update 'totals' accordingly
fun pruneWindow(key: Int) {

  if (window.containsKey(key)) {

  val day_map: MutableMap<Pair<Int, Int>, Int>? = window.get(key)
  window.remove(key)
  val daymapKeys = day_map!!.keys

  for ( (x, y) in daymapKeys ) {
    val t = day_map.get(Pair(x, y))
    var old_total = totals.get(Pair(x, y))

    if ((t != null) && (old_total != null)) {
      val new_total = old_total - t
      totals[Pair(x, y)] = new_total

      if (old_total >= threshold && new_total < threshold) {
        println("** Tile " + Pair(x, y) + " no longer significant")
        // Integration w/ 'cluster': send tuple (x, y, -1)
        println("Send (" + x + ", " + y + ", -1) to node 'cluster')")
      }
      // if total == 0, remove entry (x, y) from 'totals':
      if (new_total == 0) {
        totals.remove(Pair(x, y))
      }
    }
  }
 }
}


fun newDay(x: Int, y: Int, d: Int) {
  println("============================================================")
  println("New day: " + d)
  println("============================================================")
  // Integration w/ 'cluster':
  // send tuple (x, y, true) to trigger re-clustering
  // x, y are sent to keep the input of 'cluster' uniform
  println("Send (" + x + ", " + y + ", 0) to node 'cluster')")
  println("-> triggers re-clustering")

  day = d

  // update 'totals' if number of days > length of window
  if (day >= window_size) {
    println("Updating window...")
    println("Old window:")
    printWindow()

    println("Old totals:")
    printTotals()

    val key = day - window_size
    pruneWindow(key)
    println("New window:")
    printWindow()

    print("New totals:\n")
    printTotals()
  } else {
    println("Number of days < window size. No need to purge any data.")
  }
  println("------------------------------------------------------------")

}
