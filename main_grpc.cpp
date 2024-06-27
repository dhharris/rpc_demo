#include <grpcpp/grpcpp.h>

#include "add_service/AddServiceImpl.h"

using AddService::AddServiceImpl;
using grpc::Server;
using grpc::ServerBuilder;

int main() {
  AddServiceImpl service;
  ServerBuilder builder;
  builder.AddListeningPort("0.0.0.0:9001", grpc::InsecureServerCredentials());
  builder.RegisterService(&service);
  std::unique_ptr<Server> server(builder.BuildAndStart());
  server->Wait();
  return 0;
}
