#!/usr/bin/env python
"""
Script to retrieve users and their properties from Active Directory domain.
"""
import pyad
import json


def main():
    """Main function providing necessary functionality."""
    # set default authentication for ad connection
    pyad.set_defaults(ldap_server={{ ad_server }}, username={{ ad_username }}, password={{ ad_password }})
    # make ad connection and execute query for workspaces group
    group = pyad.ADGroup.from_dn({{ ad_dn }})
    # place the users in an array
    users = [user.displayName for user in group.get_members()]
    # output json to be consumed by ansible
    print json.dumps(users)


if __name__ == '__main__':
    main()
