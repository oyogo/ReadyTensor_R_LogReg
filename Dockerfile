FROM rocker/r-ver:4.2.1

USER root

WORKDIR /home/modellingLogistic

RUN apt-get update -y && apt-get install apt-utils libudunits2-dev libproj-dev lbzip2  -y --no-install-recommends 

RUN R -e "install.packages('dplyr', dependencies=T)"
RUN R -e "install.packages('data.table', dependencies=T)"
RUN R -e "install.packages('readr', dependencies=T)"
RUN R -e "install.packages('rjson', dependencies=T)"

COPY train.R /home/modellingLogistic/train.R
COPY testing.R /home/modellingLogistic/testing.R

# The two scripts (train.R and testing.R) need to be run in succession. testing.R should be run only after 
# training.R is successful. To achieve that we use && 
CMD R -e "source('/home/modellingLogistic/train.R')" && R -e "source('/home/modellingLogistic/testing.R')"

#CMD R -e "source('/home/modellingLogistic/testing.R')"