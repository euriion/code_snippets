# ======================================================================
# 참고자료: http://wiki.nexrcorp.com/display/RHive/Workflow+Model
# 원본데이터 경로: /HKMC_VRM/converted/csv/vrm.merged.final.csv
# 컬럼정보: /HKMC_VRM/converted/csv/desc_columns.csv
# 로컬데이터 경로: vrm.merged.final.csv
# ======================================================================

# 콘트롤부터 생성
control <- setRefClass (
  "control",
  fields = list (
    id = "character",
    to = "list"
  ),

  methods = list (
    initialize = function (id = make.id(), ...) {
      callSuper(...)
      id <<- id
    },

    #' .self -> p -> t의 pipeline 생성
    #' @param t control 객체
    #' @param p transformation.chain 객체
    connect = function (t, p) {
      stopifnot(inherits(t, "control"))
      stopifnot(inherits(p, "transformation.chain"))

      to <<- c(to, list(list(to = t, process = p)))
    }
  )
)

input.source <- setRefClass (
  "input.source",
   contains = "control",

   methods = list (
     read = function (...) {
       list()
     }
   )
)

output.target <- setRefClass (
  "output.target",
  contains = "control",

  methods = list (
    write = function (l) {
      invisible()
    }
  )
)


s <- mem.source$new(data = list(x = 1:100))