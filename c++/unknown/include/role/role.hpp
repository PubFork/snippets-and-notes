#pragma once

#include <string>
#include <memory>

#include "addon/addon.hpp"
#include "configure/configure.hpp"
#include "infrastructure/infrastructure.hpp"
#include "platform/platform.hpp"
#include "provision/provision.hpp"
#include "validate/validate.hpp"

// base class for all roles to inherit
class Role {
protected:
  Infrastructure m_infra;
  Platform m_plat;
  Provision m_prov;
  std::string m_soft;
  Configure m_config;
  Addon m_addon;
  Validate m_valid;

public:
  // constructor that uses platform to install and configure software
  Role(const Infrastructure &infra, const Platform &plat, std::string soft, const Configure &config, const Addon &addon, const Validate &valid): m_infra{infra}, m_plat{plat}, m_soft{soft}, m_config{config}, m_addon{addon}, m_valid{valid} {};

  // constructor that uses provision to install and configure software
  Role(const Infrastructure &infra, const Provision &prov, std::string soft, const Configure &config, const Addon &addon, const Validate &valid): m_infra{infra}, m_prov{prov}, m_soft{soft}, m_config{config}, m_addon{addon}, m_valid{valid} {};

  ~Role() {};

  int delegator();
};
