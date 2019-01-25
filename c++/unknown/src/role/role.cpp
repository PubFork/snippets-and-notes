#include "role/role.hpp"

int Role::delegator() {
  // create infrastructure
  m_infra.create();
  // establish base software install with platform or provision
  if (m_plat != NULL)
    m_plat.install(m_soft);
  else if (m_prov != NULL)
    m_prov.install(m_soft);
  else
    // error
  // configure the installation
  m_config.customize();
  // enhance with any addons
  m_addon.enhance();
  // validate the portion of the stack
  m_valid.validate();
};
