#TODO: refactor methods including having filter multi-call possible; gui for inputs (see constants below), kv of dest-depart for matrix of possibilities, check cache timestamp for update, track prices over time (how to match same dest/depart date), availability might be nice, https://amadeus4dev.github.io/amadeus-python/#shopping-hotels; use pandas?

import re
from datetime import date
import datetime
from amadeus import Client
import ruamel.yaml as yaml


class FlightTracker(object):
    """tool to retrieve and track flight prices

    currently assume origin is atl, carrier is dl, and segments is 1"""

    # constructor
    def __init__(self, dest = 'MIA', date = '2019-12-23', debug = True):
        # retrieve or grab data
        # set credentials
        creds = yaml.safe_load(open('/home/matt/.amadeus/creds').read())

        if debug:
            self.__data = yaml.safe_load(open('cache.txt').read())
        else:
            # initialize client
            amadeus = Client(client_id=creds['api_key'], client_secret=creds['api_secret'])

            # configure request and assign response
            response = amadeus.shopping.flight_offers.get(
                origin='ATL',
                destination=DEST,
                departureDate=DATE
            )

            # store response data
            self.__data = response.data

            # cache response data
            open('cache.txt', 'w+').write(yaml.dump(self.__data))

    # displays history of prices for selected destination and depart date
    def display_flights(self):
        # initialize filtered array of offers
        filtered = []

        # iterate through retrieved offers
        for offer in self.__data:
            # add offer if direct flight and carrier is delta
            if len(offer['offerItems'][0]['services'][0]['segments']) == 1 and offer['offerItems'][0]['services'][0]['segments'][0]['flightSegment']['carrierCode'] == 'DL':
                filtered.append(offer['offerItems'][0])

        # output origin, dest, date
        print('Origin:', 'ATL', 'Destination:', DEST, 'Date:', DATE, 'Today:', date.today())

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
