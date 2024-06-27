# RPC Demo
Finally a demo that shows how to build a thrift/gRPC service with Buck2.

## Dependencies
### Thrift
* thrift
* boost
### gRPC
* abseil
* protobuf
* grpc


## Build
Install buck
```
rustup install nightly-2024-03-17
cargo +nightly-2024-03-17 install --git https://github.com/facebook/buck2.git buck2
```
Initialize the prelude submodule
```
git submodule update --init --recursive prelude
```
Buck build
```
buck2 build //...
```

## Running the C++ server
```
buck2 run //:server-thrift
```
or
```
buck2 run //:server-grpc
```

## Running the python client
```
buck2 run //:client-thrift
```
or
```
buck2 run //:client-grpc
```
