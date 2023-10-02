
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
TOP_3_CATEGORIES_MAP <- file.path(MODEL_ARTIFACTS_PATH, "top_3_map.rds")
LABEL_ENCODER_FILE <- file.path(MODEL_ARTIFACTS_PATH, 'label_encoder.rds')
ENCODED_TARGET_FILE <- file.path(MODEL_ARTIFACTS_PATH, "encoded_target.rds")
TEST_ID <- file.path(MODEL_ARTIFACTS_PATH, 'test_id.rds')

preprocessing <- function(df.tn,df.test){ 
  if(df.test==0){
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
    
  } else{
    
    imputation_values <- readRDS(IMPUTATION_FILE)
    for (column in names(df.test)[sapply(df.test, function(col) any(is.na(col)))]) {
      df.test[, column][is.na(df.test[, column])] <- imputation_values[[column]]
    }
    
    # Saving the id column in a different variable and then dropping it.
    ids <- df.test[[id_feature]]
    saveRDS(ids,TEST_ID)
    df.test[[id_feature]] <- NULL
    
    # Encoding
    # We encode the data using the same encoder that we saved during training.
    if (length(categorical_features) > 0 && file.exists(OHE_ENCODER_FILE)) {
      top_3_map <- readRDS(TOP_3_CATEGORIES_MAP)
      encoder <- readRDS(OHE_ENCODER_FILE)
      for(col in categorical_features) {
        # Use the saved top 3 categories to replace values outside these categories with 'Other'
        df.test[[col]][!(df.test[[col]] %in% top_3_map[[col]])] <- "Other"
      }
      
      test_df_encoded <- dummy_cols(df.test, select_columns = categorical_features, remove_selected_columns = TRUE)
      encoded_columns <- readRDS(OHE_ENCODER_FILE)
      # Add missing columns with 0s
      for (col in encoded_columns) {
        if (!col %in% colnames(test_df_encoded)) {
          test_df_encoded[[col]] <- 0
        }
      }
      
      # Remove extra columns
      extra_cols <- setdiff(colnames(test_df_encoded), c(colnames(df.test), encoded_columns))
      df.test <- test_df_encoded[, !names(test_df_encoded) %in% extra_cols]
    }
    
    return(df.test)
    
  }
  
}

