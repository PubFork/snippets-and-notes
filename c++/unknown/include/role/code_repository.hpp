#pragma once

#include <string>
#include "role/role.hpp"

class CodeRepository: Role {
private:

public:
  // constructor that uses platform to install and configure software
  CodeRepository(const Infrastructure &infra, const Platform &plat, std::string soft, const configization &config, const Addon &addon, const Validate &valid): Role(const Infrastructure &infra, const Platform &plat, std::string soft, const configization &config, const Addon &addon, const Validate &valid) {};

  // constructor that uses provision to install and configure software
  CodeRepository(const Infrastructure &infra, const Provision &prov, std::string soft, const configization &config, const Addon &addon, const Validate &valid): Role(const Infrastructure &infra, const Provision &prov, std::string soft, const configization &config, const Addon &addon, const Validate &valid) {};

  ~CodeRepository() {}
};
