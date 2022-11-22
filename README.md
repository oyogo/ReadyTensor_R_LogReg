# Automating Logistic Regression   

* The idea is to have a logistic regression run in a container and save the model back to the attached folder.   
* When running the container a volume needs to be attached which contains the csv files and the data schema.    

To try this locally on your pc see the steps below: 

1. Your data folder   
Note: ensure you name it : *ml_vol*      
should have your files with the following pattern     
```
*_train.csv
*_test.csv
*_schema.json 

```

2.  download the image from my dockerhub 

```
docker pull oyogo/logistic

```

3. spin the docker container   

note: 
 * oyogo/logistic is the docker image name as pulled from dockerhub   
 * ensure port 8000 is not in use     
 * this path _/home/modellingLogistic/ml_vol_ should be as it for that's how its predefined inside the container.   
 
```
docker run -dit --rm -p 8000:8000 -v "/path/to/your/ml_vol":"/home/modellingLogistic/ml_vol"  oyogo/logistic

```

4. Get the name of the container  

```
docker ps 

```
When you run the above command you'll get an output as below: 

```
CONTAINER ID   IMAGE      COMMAND   CREATED         STATUS         PORTS                    NAMES
9071340878d3   logistic   "R"       3 seconds ago   Up 2 seconds   0.0.0.0:8000->8000/tcp   optimistic_franklin

```

On the output above, pick the name of the container right under *NAMES*. For this case its _optimistic_franklin_   
Ensure you substitute the container name accordingly. 

5. Execute the train/test scripts in the container 
Using the container name, we can now execute the r scripts in the container as below:  

```
docker exec -it optimistic_franklin ./train /bash/sh

```
To run the test script substitute train with test.  


When you execute the train script, the container runs the model and saves it inside the */ml_vol/model/artifacts/* folder with the name : *model.rds*   
  

Running the test script we'll have an output as below: 

```
Running plumber API at http://0.0.0.0:8000
Running swagger Docs at http://127.0.0.1:8000/__docs__/

```

Take the _http://127.0.0.1:8000/__docs__/_ and post it on your browser, you should be able to see the swagger ui. Click on predict, then try_out and then execute. 
You can now check the testing_output folder inside the outputs folder of ml_vol. You should be able to see a test_predictions.csv file inside it.  


