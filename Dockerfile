FROM rocker/r-ver:4.2.1

USER root

WORKDIR /home/modellingLogistic

RUN apt-get update -y && apt-get install apt-utils libudunits2-dev libproj-dev lbzip2  -y --no-install-recommends 

RUN R -e "install.packages('dplyr', dependencies=T)"
RUN R -e "install.packages('data.table', dependencies=T)"
RUN R -e "install.packages('readr', dependencies=T)"
RUN R -e "install.packages('rjson', dependencies=T)"

COPY logreg.R /home/modellingLogistic/logreg.R

CMD R -e "source('/home/modellingLogistic/logreg.R')"