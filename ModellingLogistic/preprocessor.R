
#####*****Preprocessing script*****######
#####* This is where we process the data, say imputing NA's with mean plus any other transformation that can be done. 
#####* This function will be sourced in the training script before fitting the model. 

library(data.table) # Opted for this, 1. Because its really fast 2. dplyr conflicted with plumber
library(rjson) # for handling json data
library(fastDummies)
library(dplyr)

ROOT_DIR <- dirname(getwd())
MODEL_INPUTS_OUTPUTS <- file.path(ROOT_DIR, 'model_inputs_outputs')
MODEL_ARTIFACTS_PATH <- file.path(MODEL_INPUTS_OUTPUTS, "model", "artifacts")
IMPUTATION_FILE <- file.path(MODEL_ARTIFACTS_PATH, 'imputation.rds')
OHE_ENCODER_FILE <- file.path(MODEL_ARTIFACTS_PATH, 'ohe.rds')

preprocessing <- function(df.tn){ 

    imputation_values <- list()
    columns_with_missing_values <- colnames(df.tn)[apply(df.tn, 2, anyNA)]
    
    for (column in columns_with_missing_values) {
      if (column %in% numeric_features) {
        value <- median(df[, column], na.rm = TRUE)
      } else {
        value <- df.tn[, column] %>% tidyr::replace_na()
        value <- value[1]
      }
      df.tn[, column][is.na(df.tn[, column])] <- value
      imputation_values[column] <- value
      
    }
    
    saveRDS(imputation_values, IMPUTATION_FILE)
    
    ids <- df.tn[, id_feature]
    target <- df.tn[, target_feature]
    df.tn <- df.tn %>% select(-all_of(c(id_feature, target_feature)))
    
    
    # One Hot Encoding
    if(length(categorical_features) > 0){
      top_3_map <- list()
      for(col in categorical_features) {
        # Get the top 3 categories for the column
        top_3_categories <- names(sort(table(df.tn[[col]]), decreasing = TRUE)[1:3])
        
        # Save the top 3 categories for this column
        top_3_map[[col]] <- top_3_categories
        # Replace categories outside the top 3 with "Other"
        df.tn[[col]][!(df.tn[[col]] %in% top_3_categories)] <- "Other"
      }
      
      df_encoded <- dummy_cols(df.tn, select_columns = categorical_features, remove_selected_columns = TRUE)
      encoded_columns <- setdiff(colnames(df_encoded), colnames(df.tn))
      saveRDS(encoded_columns, OHE_ENCODER_FILE)
      saveRDS(top_3_map, TOP_3_CATEGORIES_MAP)
      df <- df_encoded
    }
    
    # Label encoding target feature
    levels_target <- levels(factor(target))
    encoded_target <- as.integer(factor(target, levels = levels_target)) - 1
    saveRDS(levels_target, LABEL_ENCODER_FILE)
    saveRDS(encoded_target, ENCODED_TARGET_FILE)
    
    return(df)
  
}

