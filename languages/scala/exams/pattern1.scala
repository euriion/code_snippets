// --------------------------------------------------------
// -- Scala example code
// -- pattern extraction (regular expression)
// -- Seonghak Hong (euriion@gmail.com)
// --------------------------------------------------------

val pattern1  = "[0-9]+".r  // define regular expression
val source_text = "My phone number is 123-4567-8901. please call me"  // assing a string
println(pattern1.findFirstIn(source_text).get)  // should use 'get' because the return object is Some()
pattern1.findAllIn(source_text).foreach(println)  // return Iterator. so should use foreach or others such as mkString

import scala.util.matching.Regex  // import Regex

val pattern2 = new Regex("[0-9]+")  // make an object of Regex
pattern2.findAllIn(source_text).foreach(println)  // do same with previous exam code

val matches = pattern2.findAllIn(source_text)
println(matches.mkString("\t"))
