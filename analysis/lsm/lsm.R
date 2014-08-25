# LSM R코드 예제

# 데이터를 입력하고 모두 rbind 한 후 matrix를 data.frame으로 변환한다
lsm.data <- as.data.frame(rbind(
  c(1, 2.1),
  c(3, 3.7),
  c(2.5, 3.4),
  c(3.9, 3.1)
))

colnames(lsm.data) <- c("xvalues", "yvalues")  # data.frame에 컬럼 이름을 지정한다
m <- lm(yvalues ~ xvalues, data=lsm.data)  # 선형회귀 모델을 구한다
m  # 결과값 출력

plot(lsm.data) # 플로팅하기
abline(m) # 추이선 그러기