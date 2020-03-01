path "secret/foo" {
  capabilities  = ["read"]
  # enterprise feature
  control_group = {
    factor "ops_manager" {
      identity {
        group_names = ["managers"]
        approvals   = 1
      }
    }
  }
}

path "secret/foo" {
  capabilities = ["create", "update"]
  control_group = {
    ttl = "4h"
    factor "tech leads" {
      identity {
        group_names = ["managers", "leads"]
        approvals   = 2
      }
    }
    factor "super users" {
      identity {
        group_names = ["superusers"]
        approvals   = 1
      }
    }
  }
}
