#include "AddServiceImpl.h"
#include <iostream>

using grpc::ServerContext;
using grpc::Status;

namespace AddService {
Status AddServiceImpl::Add(
    ServerContext* context,
    const AddRequest* request,
    AddResponse* response) {
  response->set_num(request->num1() + request->num2());
  return Status::OK;
}
Status AddServiceImpl::PlusPlus(
    ServerContext* context,
    const PlusPlusRequest* request,
    AddResponse* response) {
  response->set_num(request->num() + 1);
  return Status::OK;
}
Status AddServiceImpl::Ping(
    ServerContext* context,
    const PingRequest* request,
    PingResponse* response) {
  std::cout << "ping" << std::endl;
  return Status::OK;
}
} // namespace AddService
