# Data agnostic Logistic Regression with docker compose and Plumber API  
## Project background
The idea of this project is to have a data agnostic logistic regression that trains, predicts and serves as a docker compose service.
So basically, the user just needs to attach the folder with the data with a binary response variable then run train script to train the model and save it as an artifact back to the attached volume, test the model to save the predictions as an output in the attached volume and run the serve script to run a plumber API which returns a json output of predictions.   
 
## System architecture
 Below are the contents of the main project folder:     
 
 ```
   * docker-compose.yaml   
   * Dockerfile     
   * model_inputs_outputs     
   * ModellingLogistic    
 
 ```
*docker-compose.yaml*: 
 This is the yaml file for docker compose which has specifications configuring the docker compose service, this includes configurations such as:     
 * name of the docker compose service.      
 * volume to attach and to which folder should it be attached inside the docker container.    
 * port number for the service.    
 
*Dockerfile*:    
 This is the file that has instructions for creating the docker image, this includes;    
 * libraries to be installed.   
 * folders and files to be copied into the container.   
 * specifying the working directory.   
 * making the train, predict and serve scripts executable.  
 
*model_inputs_outputs*:   
 This is a folder with the inputs and outputs of the service.   
 The folders below are within this folder.   
 
 ```
 inputs   
    - data  
        - testing 
        - training
    - schema
 model   
   - artifacts
        -predictor
 outputs
   - errors   
   - http_outputs
   - predictions
   - testing_outputs
 
 ```
*/inputs/data/*    
This folder has within it the testing and training folders where the training and testing csv data files are.     
Important to note the following;    
 - Both the csv files must have the following.     
      - id column    
      - target variable    
      - rest of the variables should either be numeric or categorical   
*/inputs/schema*    
The json format schema file sits in this folder and it needs to be structured as per the ReadyTensor specifications.     
In brief, this is where;   
  - the id variable is specified    
  - list of categorical and numeric variables are defined separately.    
  - the target variable is specified   
  
*/model/artifacts/*
The train script saves variables in .rds format into this folder. This includes the target levels, encoded version of it, imputation values and the predictor file inside the predictor folder.    

*ModellingLogistic*:   
 This where the executable scripts sit.    
   - train    
   - predict     
   - preprocessor.R   
   - server   
   - serving.R    
     
*train*   
Fits the model and saves it into the _/model/artifacts/predictor_ folder. This is besides other variables which are saved into the _/model/artifacts_ folder as explained in the */model/artifacts/* section above.     

*predict*    
This script runs batch predictions using the trained model saved in the _/model/artifacts/predictor/_ folder.    
The resulting predictions are saved into the _/outputs/prediction/_ folder in csv format.    

## Usage 

1. Edit the docker compose yml file below accordingly(path to your data directory). Put it in the project directory. 
```
version: "3"
services:
  logmodel:
    build: .
    volumes:
      - /path/to/data/dir/ml_vol:/modellingLogistic/ml_vol
    ports:
      - 8080:8080
    working_dir: /modellingLogistic
    command: tail -f /dev/null # keep the container running

```

2. Navigate to your project directory and run the following command.     

The command below starts your service. (the tag _-d_ is for running it in detached mode.)     

```
docker compose up -d

``` 

3. Running your script inside the container.     

```
docker compose exec -it logmodel ./train  

```
Note: _logmodel is the name of the service in docker compose yml._     

To run the prediction script you'll just replace ./train with ./predict     

4. Starting a web server   

```
docker compose exec -it logmodel ./serve   

```

Once the plumber API starts you can now open another terminal and paste the following:   

```
curl localhost:8080/infer --header "Content-Type: application/json" \
  --request POST \
  --data @/path/to/your/data/telco.json
```

_*Note: ensure you change the path to data and your test data accordingly!*_    

