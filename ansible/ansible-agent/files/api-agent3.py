"""Ansible API Agent: Remotely executes jobs from Ansible Tower"""

import urllib.request
import time
import configparser
import ssl

# read in settings from conf file
SETTINGS = configparser.ConfigParser().read('/etc/ansible/ansible-agent.conf')['Settings']

# establish variables to save time on lookups in loops
REQUEST = urllib.request.Request(SETTINGS['TowerURL'] + '/api/v' + SETTINGS['TowerAPI'] + '/job_templates/' + SETTINGS['JobTemplateID'] + '/' + SETTINGS['TowerCall'] + '/')
INTERVAL = int(SETTINGS['Interval'])
CERTIFY = SETTINGS['TowerCert']
CALL = SETTINGS['TowerCall']

# bypass ssl certfication
if CERTIFY == 'false':
    CONTEXT = ssl._create_unverified_context()

# prepare the credentials depending upon the call type
if CALL == 'callback':
    DATA = urllib.parse.urlencode({'host_config_key': SETTINGS['HostConfigKey']}).encode('utf-8')
else:
    DATA = urllib.parse.urlencode({'username': SETTINGS['Username'], 'password': SETTINGS['Password']}).encode('utf-8')

# loop infinitely since this will be a daemonized service
while True:
    # launch job with parameters
    if CERTIFY == 'true':
        urllib.request.urlopen(REQUEST, data=DATA)
    else:
        urllib.request.urlopen(REQUEST, data=DATA, context=CONTEXT)

    # pause for interval
    time.sleep(INTERVAL)
