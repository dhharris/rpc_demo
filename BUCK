# A list of available rules and their signatures can be found here: https://buck2.build/docs/api/rules/

cxx_binary(
    name = "server-thrift",
    srcs = ["main_thrift.cpp"],
    deps = ["//add_service:add_service-thrift"],
    compiler_flags = [
      "-std=c++20",
    ],
)

python_binary(
  name = "client-thrift",
  main = "client_thrift.py",
  deps = ["//add_service/if:if-thrift-py"],
)

cxx_binary(
    name = "server-grpc",
    srcs = ["main_grpc.cpp"],
    deps = ["//add_service:add_service-grpc"],
    compiler_flags = [
      "-std=c++20",
    ],
)

python_binary(
  name = "client-grpc",
  main = "client_grpc.py",
  deps = ["//add_service/if:if-proto-grpc-py"],
)
