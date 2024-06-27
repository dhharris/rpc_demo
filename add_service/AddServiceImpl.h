#include <grpcpp/grpcpp.h>

#include "add_service/if/gen-cpp/add_service.grpc.pb.h"

namespace AddService {
class AddServiceImpl final : public AddService::Service {
 public:
  AddServiceImpl() = default;
  virtual ~AddServiceImpl() {}
  virtual grpc::Status
  Add(grpc::ServerContext* context,
      const AddRequest* request,
      AddResponse* response) override;
  virtual grpc::Status PlusPlus(
      grpc::ServerContext* context,
      const PlusPlusRequest* request,
      AddResponse* response) override;
  virtual grpc::Status Ping(
      grpc::ServerContext* context,
      const PingRequest* /*request*/,
      PingResponse* /*response*/) override;
};
} // namespace AddService
