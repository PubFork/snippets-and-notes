// do cpp/hpp combos first

#include <string>
#include "role/role.hpp"

int main() {
  auto infra = Infrastructure();
  auto plat = Platform();
  // auto prov = Provision();
  auto soft = "gitlab";
  auto config = Configure();
  auto addon = Addon();
  auto valid = Validate();

  auto role = CodeRepository(infra, plat, soft, config, addon, valid);
  CodeRepository.delegator();

  return 0;
};
