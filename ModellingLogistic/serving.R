#!/usr/bin/env Rscript
library(data.table)
library(rjson)
#* Perform a prediction by submitting in the body of a POST request
#* @post /getprediction 
getprediction <- function(req) {
  df <- req$postBody
  parsed_df <- jsonlite::fromJSON(df)
  model <- readRDS("./../ml_vol/model/artifacts/model.rds")
  predicted <- predict(model, new_data = bake(rec, parsed_df),type="response")
  predicted <- data.table(predicted)
  names(predicted) <- "probabilities"
  #cbind(parsed_df,predicted)
  # where the probabilities returned are <0.5 put 0 otherwise 1.
  predicted <- predicted[, predictions:=0][probabilities>0.5, predictions:=1]

}