#!/usr/bin/env python
"""
TODO
"""
import pyad
import json


def main():
    """Main function providing necessary functionality."""
    workspace_hostnames = {{ workspace_hostnames }} # TODO: populate var from task
    # set default authentication for ad connection
    pyad.set_defaults(ldap_server={{ ad_server }}, username={{ ad_username }}, password={{ ad_password }})
    # make ad connection and execute query for computer objects
    computer = pyad.from_dn({{ computer_dn }})
    for hostname in computer.hostnames: # TODO
        if hostname in workspace_hostnames:
            # {{ computer }}.update_attribute("description", "WorkSpace - {{ user.name }} ({{ user.username }})")
        else:
            computer.delete #TODO


if __name__ == '__main__':
    main()
