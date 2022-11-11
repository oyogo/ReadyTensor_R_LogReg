FROM rocker/r-ver:4.2.1

USER root

WORKDIR /home/modellingLogistic

RUN apt-get update -y && apt-get install apt-utils libudunits2-dev libproj-dev lbzip2  -y --no-install-recommends 

RUN R -e "install.packages('devtools', dependencies=T)"
RUN R -e "devtools::install_version('dplyr', dependencies=T)"
RUN R -e "devtools::install_version('data.table', dependencies=T)"
RUN R -e "devtools::install_version('readr', dependencies=T)"
RUN R -e "devtools::install_version('rjson', dependencies=T)"

COPY logreg.R /home/modellingLogistic/logreg.R

CMD R -e "source('/home/modellingLogistic/myscript.R')"