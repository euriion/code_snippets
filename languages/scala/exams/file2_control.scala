import Control._

using(io.Source.fromFile("test.csv")) {
	source => {
		for (line <- source.getLlines) {
			println(line)
		}
	}
}