# function to run the prediction 
library(data.table)

lets_predict <- function(){
  
  tdata <- fread("./data/spam_test.csv")
  
  ourmodel <- readRDS("model.rds")
  
  predictions <- predict()
  
  return(predictions)
}