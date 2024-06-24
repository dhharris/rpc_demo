# A list of available rules and their signatures can be found here: https://buck2.build/docs/api/rules/

cxx_binary(
    name = "main",
    srcs = ["main.cpp"],
    deps = ["//add_service:add_service"],
    compiler_flags = [
      "-std=c++20",
    ],
)

python_binary(
  name = "client",
  main = "client.py",
  deps = ["//add_service/if:if-py"],
)
