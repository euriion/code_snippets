library(forecast) # need to install the package "forecast"

memory.usage.threshold              <- 100  # 100%
memory.usage.forecast.period        <- 30  # 30일
memory.usage.observations.startdate <- "2012-09-01"
memory.usage.observations           <- c(10,11,30,35,36,39,48,56,75,69,68,72) # 관측치 12일분

memory.usage.period      <- seq(as.Date(memory.usage.observations.startdate), length=length(memory.usage.observations), by="1 day") # 날짜세팅
memory.usage.df          <- data.frame(row.names=memory.usage.period, memory=memory.usage.observations) # data.frame으로 변환
memory.usage.ts          <- ts(data=memory.usage.df)  # time series 생성
memory.usage.model       <- auto.arima(memory.usage.ts)  # arima 모델 생성
memory.usage.forecast    <- forecast(memory.usage.model, h=memory.usage.forecast.period)  # forecast 결과 생성
memory.usage.forecast.df <- as.data.frame(memory.usage.forecast)  # forecast 결과 변환

d <- as.numeric(row.names(memory.usage.forecast.df[memory.usage.forecast.df$`Point Forecast` >= memory.usage.threshold,][1,]))  # 100이 넘는 최초 데이터 추출
if(is.na(d)) {
  print(sprintf("앞으로 %s일동안 100%% 초과하지 않음", memory.usage.forecast.period, d - length(memory.usage.observations)))  
} else {
  print(sprintf("%s일 후에 100%% 초과됨", d - length(memory.usage.observations))) 
}

# Plotting
plot(memory.usage.forecast)  # plotting
abline(h=100, col = "red", lty=3)