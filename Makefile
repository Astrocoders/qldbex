SHELL := /bin/bash 

all:
	cd ion-c &&./build-release.sh
	cp -R ./ion-c/ionc/include/ionc ./c_src/qldbex/ion
	cp -R ./ion-c/decNumber/include/decNumber ./c_src/qldbex/decNumber
	mkdir ./c_src/qldbex/c_libs
	cp -R ./ion-c/build/release/decNumber/ ./c_src/qldbex/c_libs/decNumber
	cp -R ./ion-c/build/release/ionc/ ./c_src/qldbex/c_libs/ionc

clean:
	rm -rf ./ion-c ./c_src/qldbex/ion ./c_src/qldbex/decNumber ./c_src/qldbex/c_libs
