#include "AddServiceHandler.h"
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>

namespace AddService {
int32_t AddServiceHandler::add(const int32_t n1, const int32_t n2) {
  return n1 + n2;
}
int32_t AddServiceHandler::plus_plus(const int32_t num) {
  return num + 1;
}
void AddServiceHandler::ping() {
  std::cout << "ping" << std::endl;
}
void AddServiceHandler::ad(std::string& ret) {
  std::ifstream input("./mads-test-high-test.jpg", std::ios::binary);
  std::stringstream buf;
  buf << input.rdbuf();
  ret = buf.str();
}
} // namespace AddService
