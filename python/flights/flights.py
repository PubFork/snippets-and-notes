#TODO: interface for inputs (see constants below), kv of dest-depart for matrix of possibilities, store response data in file and check timestamp for update, track prices over time, availability might be nice, https://amadeus4dev.github.io/amadeus-python/#shopping-hotels

import re
from amadeus import Client
import ruamel.yaml as yaml


ORIGIN = 'ATL'
DEST = 'MIA'
DATE = '2019-12-23'
DEBUG = True

# set credentials
creds = yaml.safe_load(open('/home/matt/.amadeus/creds').read())

if DEBUG:
    data = open('debug.txt').read().to_dict()
else:
    # initialize client
    amadeus = Client(client_id=creds['api_key'], client_secret=creds['api_secret'])

    # configure request and assign response
    response = amadeus.shopping.flight_offers.get(
        origin=ORIGIN,
        destination=DEST,
        departureDate=DATE
    )

    # store response data
    data = response.data

# initialize filtered array of offers
filtered = []

# iterate through retrieved offers
for offer in data:
    # add offer if direct flight and carrier is delta
    if len(offer['offerItems'][0]['services'][0]['segments']) == 1 and offer['offerItems'][0]['services'][0]['segments'][0]['flightSegment']['carrierCode'] == 'DL':
        filtered.append(offer['offerItems'][0])

# output origin, dest, date
print('Origin:', ORIGIN, 'Destination:', DEST, 'Date:', DATE)

# output time and price
for offer in filtered:
    # easier to read
    depart = offer['services'][0]['segments'][0]['flightSegment']['departure']['at']
    depart_time = re.sub(r'-.*', '', re.sub(r'.*T', '', depart))
    price = offer['price']['total']
    number = offer['services'][0]['segments'][0]['flightSegment']['number']
    plane = offer['services'][0]['segments'][0]['flightSegment']['aircraft']['code']
    # output info
    print('Number:', number, 'Departure Time:', depart_time, 'Price:', price, 'Plane:', plane)
