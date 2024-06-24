
## Dependencies
* thrift
* boost

## Install
Install buck
```
rustup install nightly-2024-03-17
cargo +nightly-2024-03-17 install --git https://github.com/facebook/buck2.git buck2
```

## Running the C++ server
```
buck2 run //:main
```

## Running the python client
```
buck2 run //:client
```
