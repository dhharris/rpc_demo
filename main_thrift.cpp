#include <iostream>

#include <memory>
#include <thrift/protocol/TBinaryProtocol.h>
#include <thrift/server/TThreadedServer.h>
#include <thrift/transport/TServerSocket.h>
#include <thrift/transport/TTransportUtils.h>

#include "add_service/AddServiceHandler.h"
#include "add_service/if/gen-cpp/AddService.h"

using AddService::AddServiceHandler;
using apache::thrift::protocol::TBinaryProtocolFactory;
using apache::thrift::server::TThreadedServer;
using apache::thrift::transport::TBufferedTransportFactory;
using apache::thrift::transport::TServerSocket;

int main() {
  auto handler = std::make_shared<AddServiceHandler>();
  TThreadedServer server(
      std::make_shared<AddServiceProcessor>(handler),
      std::make_shared<TServerSocket>(9090 /*port*/),
      std::make_shared<TBufferedTransportFactory>(),
      std::make_shared<TBinaryProtocolFactory>());

  server.serve();
}
