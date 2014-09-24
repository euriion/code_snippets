// ===================================
// 스칼라 문자열 처리 (예제)
// ===================================

// 문자열 객체의 메쏘드 호출
// println("Hello World!".getClass().getName())

// 문자열 객체의 메쏘드 호출 (괄호 생략)
// println("Hello World!".getClass.getName)

// 한글 문자열 객체의 메쏘드 호출
// println("안녕 세상아!".getClass.getName)

// 문자열내 문자 이터레이션
// "안녕 세상아!".foreach(println)

// 문자열내 문자 이터레이션 value이용
// val s = "안녕 세상아!"
// s.foreach(println)

// 문자열내 문자 이터레이션 for문
// for (c <- "안녕 세상아!") println(c)

// 문자열내 문자 이터레이션 for문
// for (c <- "안녕 세상아!") {
// 	println(c)
// }

// 문자열내 문자 제거
// println("안녕! 세상아!".filter(_ != "아"))  // 경고 후 오류

// 문자열내 문자 자르기
// println("안녕! 스칼라!".drop(2).take(4).capitalize)

// 문자열 더하기
// println("안"+"녕"+"!"+" "+"스"+"칼"+"라"+"!"+"")

// 문자열 동일 여부 확인
// val a = "Marisa"
// val b = "marisa"
// println(a.equalsIgnoreCase(b))

// -- 여러줄 문자열
// var s = """
// 여러줄 문자열
//    여러줄 문자열2
//    여러줄 문자열3
// """
// println(s)

// -- 여러줄 문자열 개행시 들여쓰기 지우기
// s = """
// 여러줄 문자열
//    |여러줄 문자열2
//    |여러줄 문자열3
//    #여러줄 문자열4
// """
// println(s.stripMargin)
// println(s.stripMargin('#'))
// println(s.replaceAll("\n", " "))

// -- 문자열 분리
// "값1, 값2, 값3, 값4, 값5, 값6, 값7".split(",").foreach(println)

// -- 문자열의 맵 매쏘드 호출
// 추출된 아이템들은 map으로 핸들할 수 있다.
// "값1, 값2, 값3, 값4, 값5, 값6, 값7".split(",").map(_.trim).foreach(println)

// -- 문자열 분리 정규표현식
// split은 정규 표현식을 지원한다.  white space 기준으로 나누기
// "hello    |    world, this is Al".split("\\s+").foreach(println)

// -- 문자열 포맷팅
// val val1 = "string1"
// val val2 = "string2"
// val int1 = 1
// val int2 = 2
// println(s"String interpolation $val1, $val2")
// println(s"add ${int1 + int2}")

// -- 문자열 포맷팅 객체 참조
// case class Student(name: String, score: Int)
// val aiden = new Student("aiden", 99)
// println(s"name is ${aiden.name}. score is ${aiden.score}")

// -- 문자열 포맷팅 각종 인터폴레이션
// val name = "aiden"
// val age = 33
// val height = 201.0

// println(f"$name%s is $height%2.5f meters tall")  // f사용하기
// println("%s is %d years old".format(name, age))
// println(raw"interpolation\ninterpolation")  // raw사용하기
// println("not interpolation\nnot interpolation")


// -- 문자 하나씩 다루기
// val upper1 = "hello, world".map(c => c.toUpper)
// println(upper1)
// val upper2 = "hello, world".map(_.toUpper)
// println(upper2)
// val upper3 = "hello, world".map(_.toUpper)
// println(upper3)

// -- yield 사용
// val upper = for (c <- "안녕 세상아!") yield c.toUpper
// println(upper)

// -- yield 사용 (더 헷갈리는 구문)
// val result = for {
// 	c <- "안녕. 세상아."
// 	if c != '.'
// } yield c.toUpper
// println(result)

// ----- map 활용법
// println("HELLO".map(c => (c.toByte+32).toChar))  // 대문자를 소문자로 바꾸기

// -- 괄호를 중괄호로 바꿈
// println(
// 	"HELLO".map{
// 		c => 
// 		(c.toByte+32).toChar
// 	}
// )

// -- 메쏘드선언 (map 사용을 위한 짧은 구문)
// def toLower(c: Char): Char = (c.toByte + 32).toChar
// println(toLower('A'))
// println("HELLO".map(toLower))

// -- 함수선언 (map 사용)
// def toLower = (c: Char) => (c.toByte + 32).toChar
// println(toLower('B'))
// println("HELLO".map(toLower))

// -- 더 쉽게
// "hello".getBytes.foreach(println)
// "hello".getBytes.map(_.toChar).foreach(println)

// ===== String pattern math =====
// -- 
val numPattern = "[0-9]+".r

