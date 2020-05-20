SHELL := /bin/bash 

all:
	git clone --recursive https://github.com/amzn/ion-c.git ion-c
	cd ion-c &&./build-release.sh
	cp -R ./ion-c/ionc/include/ionc ./c_src/qldbex/ion
	cp -R ./ion-c/decNumber/include/decNumber ./c_src/qldbex/decNumber

clean:
	rm -rf ./ion-c ./c_src/qldbex/ion ./c_src/qldbex/decNumber c_libs
