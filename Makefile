SHELL := /bin/bash 

all:
	cd ion-c &&./build-release.sh
	cp -R ./ion-c/ionc/include/ionc ./c_src/qldbex/ion
	cp -R ./ion-c/decNumber/include/decNumber ./c_src/qldbex/decNumber
	cp -R ./ion-c/build/release/decNumber/ ./priv/decNumber
	cp -R ./ion-c/build/release/ionc/ ./priv/ionc

clean:
	rm -rf ./ion-c ./c_src/qldbex/ion ./c_src/qldbex/decNumber c_libs priv/ionc priv/decNumber
