# creates a section of the KVv2 Secret Engine to a specific user
path "secret/data/{{identity.entity.id}}/*" {
  capabilities = ["create", "update", "read", "delete"]
}

path "secret/metadata/{{identity.entityt.id}}/*" {
  capabilities = ["list"]
}

# create a shared section of KV that is associated with entities that are in a group
path "secret/data/groups/{{identity.groups.ids.fb036ebc-2f62-4124-9503-42aa7A869741.name}}" {
  capabilities = ["create", "update", "read", "delete"]
}

path "secret/metadata/groups/{{identity.groups.ids.fb036ebc-2f62-4124-9503-42aa7A869741.name}}" {
  capabilities = ["list"]
}
