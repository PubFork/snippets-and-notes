# Ansible Agent

travis-ci placeholder

A role for configuring an agent for scheduled jobs with Ansible Tower/AWX.

This role enables Ansible to become a configuration management tool. Since only one job template can be used with the agent, it is recommended to target a job template with a playbook and roles that will perform configuration management on the system.

## Requirements

Requires `tower-cli` to be installed on the server if you are using it as the interface.

## Role Variables

Available variables are listed below, along with default values (see [defaults](defaults/main.yml)):

    tower_interface: api

The interface to use with Tower/AWX. Available options are `api` (REST) and `cli` (Tower-CLI).

    tower_api: 2

(API only) The version of the Tower/AWX REST API to be used. Available options are `1` and `2`. If unsure, note that generally Tower `< 3.2` is `1` and Tower `>= 3.2` is `2`.

    tower_url: https://localhost

The URL of your Tower/AWX web server. This should be formatted like the above, with a leading `https://` URI and no trailing slash.

    tower_call: callback

(API only) The type of API call the agent will make to Tower/AWX. Available options are `callback` and `launch`. `callback` requires a `host_config_key` and `launch` requires a `password`(var name?).

    host_config_key: abcdefg1234

(API/Callback or CLI only) The `host_config_key` to use with the callback API or CLI call.

    username: admin

(API/Launch only) The username for the credential to use with the launch API call.

    password: password

(API/Launch only) The password for the credential to use with the launch API call.

    tower_cert: true

(API only) Whether or not to authenticate against the Tower/AWX certificate (`false` would be equivalent to a `-k` with a `curl` command).

    python_version: 3

The version of python you want to use the agent with. Available options are `2` and `3`.

    service_provider: systemd

The service provider you want to use the agent with. Available options are `systemd` and `upstart` (others possible if demand exists).

    interval: 3600

The scheduled interval between agent calls to Tower/AWX for scheduled job executions.

    job_template_id: 0

The job template for Tower/AWX to execute on the server when the agent calls for a job.

## Dependencies

None

## Example Playbook

```yaml
- hosts: client
  vars:
    tower_url: https://tower.company.com
    service_provider: upstart
    job_template: base-configuration-management
  roles:
    - role: ansible-agent
      become: true
```

## License

MIT
