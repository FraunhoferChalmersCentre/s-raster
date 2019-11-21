/*
S-RASTER: Prototypal Implementation of the 'Project' Node
(c) 2019 Fraunhofer-Chalmers Research Centre for Industrial Mathematics

The source code in this file is written in the JVM language Kotlin. To execute it,
assuming you have both the JVM and Kotlin installed, execute the following two
commands, which combines compilation and execution:

> kotlinc pi.kt -include-runtime -d pi.jar && java -jar pi.jar

*/

// sample input
val xs =  listOf(
  Triple(13.5510374647126,  9.81155925882019, 1),
  Triple(10.9044627785444,  9.92509352657469, 1),
  Triple(12.8480031732858, 10.7837217268837 , 1))

val precision:Double = 3.0

fun project(xs: List<Triple<Double, Double, Int>>,
	        prec: Double){

  val scalar: Double = Math.pow(10.0, prec)
  println("Precision: " + prec)
  for ((x, y, p) in xs) {
    val x_pi: Int = (x * scalar).toInt()
    val y_pi: Int = (y * scalar).toInt()
    println("--------------------------------------------------------------")
    println("Input:  " + x + ", " + y + " , " + p)
    println("Output: " + x_pi + ", " + y_pi + " , " + p)
  }
}

fun main(args: Array<String>) {
  println("--------------------------------------------------------------")
  println("Illustration of the workflow of the 'project' node of S-RASTER")
  println("--------------------------------------------------------------")

  project(xs, precision)
}
