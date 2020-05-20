SHELL := /bin/bash 

all:
	cp -R ./ion-c/ionc/include/ionc ./c_src/qldbex/ion
	cp -R ./ion-c/decNumber/include/decNumber ./c_src/qldbex/decNumber

