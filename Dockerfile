FROM elixir:1.9.4-slim

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get update && apt-get install -y build-essential git libssl-dev libjson-c-dev make cmake valgrind

RUN git clone --recursive https://github.com/amzn/ion-c.git ion-c

COPY . .

# Build ion-c

RUN cd ion-c && ./build-release.sh

RUN cp ./ion-c/build/release/decNumber/libdecNumber.so /usr/lib/libdecNumber.so
RUN cp ./ion-c/build/release/ionc/libionc.so /usr/lib/libionc.so
RUN cp ./ion-c/build/release/ionc/libionc.so.1.0.3 /usr/lib/libionc.so.1.0.3

RUN rm -rf ion-c
