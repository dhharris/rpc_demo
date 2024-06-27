#include <iostream>
#include <stdint.h>

#include "add_service/if/gen-cpp/AddService.h"

namespace AddService {
class AddServiceHandler : public AddServiceIf {
 public:
  AddServiceHandler() = default;
  virtual ~AddServiceHandler() {}
  virtual int32_t add(const int32_t n1, const int32_t n2) override;
  virtual int32_t plus_plus(const int32_t num) override;
  virtual void ping() override;
};
} // namespace AddService
