#include "add_service/AddServiceHandler.h"
#include <iostream>
int main() {
  auto server = std::make_unique<AddService::AddServiceHandler>();
  std::cout << "Hello from a C++ Buck2 program!" << std::endl;
}
