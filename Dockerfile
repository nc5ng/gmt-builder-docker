## Development and CI/CD Dockerfile for GenericMappingTools/GMT
##
## Approach: Build-last and do not rebuild layers on file changes
##
## 1. Install Build and Bin Dependencies
## 2. Fetch DCW/GSSHG data
## 3. Copy local repository and build
##
## Fetching DCW/GSSHG data and Dependencies early preserves layer cache
## for local developers. Editing a file in the repository should only
## trigger a rebuild without re-fetching data and dependencies.
##
## This is a development image so build dependencies and apt lists
## are left installed 
##
FROM ubuntu:16.04
LABEL maintainer="akshmakov@nc5ng.org"

## Part 1: Base Image and Dependencies
## BIN_DEPS and BUILD_DEPS split for verboseness
##
## Universe not installed by default in ubuntu images so we enable it
##
ARG BIN_DEPS="wget libnetcdf11 libgdal1i libfftw3-3 libpcre3 liblapack3 graphicsmagick liblas3"
ARG BUILD_DEPS="build-essential cmake libcurl4-gnutls-dev \
	    libnetcdf-dev libgdal1-dev libfftw3-dev libpcre3-dev \
	    liblapack-dev libblas-dev"
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update					 &&\
    apt-get install -y					   \
    	    software-properties-common 			   \
	    python-software-properties 			   \
	    $BIN_DEPS					 &&\
    add-apt-repository universe  			 &&\
    apt-get update					 &&\
    apt-get install -y					   \
    	    $BUILD_DEPS
	    
## Part 2: GSHHG and DCW Base Data

ARG GSHHG_VERSION=2.3.7
ARG DCW_VERSION=1.1.4
ARG GMT_INSTALL_DIR=/opt/gmt
ENV GMT_DCW_FTP=ftp://ftp.soest.hawaii.edu/dcw/dcw-gmt-$DCW_VERSION.tar.gz \
    GMT_GSHHG_FTP=ftp://ftp.soest.hawaii.edu/gshhg/gshhg-gmt-$GSHHG_VERSION.tar.gz

RUN   mkdir -p $GMT_INSTALL_DIR				 &&\
      cd $GMT_INSTALL_DIR			 	 &&\
      wget $GMT_DCW_FTP					 &&\
      wget $GMT_GSHHG_FTP		 		 &&\
      tar -xzf gshhg-gmt-$GSHHG_VERSION.tar.gz 		 &&\
      tar -xzf dcw-gmt-$DCW_VERSION.tar.gz 		 &&\
      rm -f *.tar.gz                       		   