#include <iostream>

#include <memory>
#include <thrift/protocol/TBinaryProtocol.h>
#include <thrift/server/TThreadedServer.h>
#include <thrift/transport/TServerSocket.h>
#include <thrift/transport/TTransportUtils.h>

#include "add_service/AddServiceHandler.h"
#include "add_service/if/gen-cpp/AddService.h"

int main() {
  auto handler = std::make_shared<AddService::AddServiceHandler>();
  apache::thrift::server::TThreadedServer server(
      std::make_shared<AddServiceProcessor>(handler),
      std::make_shared<apache::thrift::transport::TServerSocket>(9090 /*port*/),
      std::make_shared<apache::thrift::transport::TBufferedTransportFactory>(),
      std::make_shared<apache::thrift::protocol::TBinaryProtocolFactory>());

  server.serve();
}
