import scala.io.Source

val filename = "test.csv"

// var i = 1
// for (line <- Source.fromFile(filename).getLines) {
// 	print(s"line no($i):\t")
// 	i += 1
// 	println(line)
// }
// println(i)

// val lines = Source.fromFile(filename).getLines.toList

// for (line <- lines) {
// 	println(line)
// }

// val lines2 = Source.fromFile(filename).getLines.toArray

// for (line <- lines2) {
// 	println(line)
// }

// mkString을 이용한 변환
val s = Source.fromFile(filename)
var i = 1
for (line <- s.getLines) {
	print(s"line no($i):\t")
	i += 1
	println(line.split("\t").mkString(","))
}
s.close
println(s"Total lines: ${i - 1}")

