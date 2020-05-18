SHELL := /bin/bash 

all: 
	svn checkout https://github.com/amzn/ion-c/trunk/ionc/include/ionc c_src/qldbex/ion
