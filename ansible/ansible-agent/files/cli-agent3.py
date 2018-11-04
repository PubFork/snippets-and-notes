"""Ansible CLI Agent: Remotely executes jobs from Ansible Tower"""

import configparser
import time
from tower_cli import get_resource

# read in settings from conf file
SETTINGS = configparser.ConfigParser().read('/etc/ansible/ansible-agent.conf')['Settings']

# establish variables to save time on lookups in loops TODO
# SETTINGS['TowerURL']
INTERVAL = int(SETTINGS['Interval'])
KEY = SETTINGS['HostConfigKey']
ID = SETTINGS['JobTemplateID']

# prep API
res = get_resource('job_template')

# loop infinitely since this will be a daemonized service
while True:
    # launch job with parameters
    res.callback(pk=ID, host_config_key=KEY)

    # pause for interval
    time.sleep(INTERVAL)
