SHELL := /bin/bash 

all:
	cd ion-c &&./build-release.sh
	cp -R ./ion-c/ionc/include/ionc ./c_src/qldbex/ion
	cp -R ./ion-c/decNumber/include/decNumber ./c_src/qldbex/decNumber

