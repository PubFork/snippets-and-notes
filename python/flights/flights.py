#TODO: refactor methods; gui for inputs (see constants below), kv of dest-depart for matrix of possibilities, availability might be nice, https://amadeus4dev.github.io/amadeus-python/#shopping-hotels; use pandas (probably invevitable given desire for sorting functionality)?

import re
from pathlib import Path
from datetime import date

from amadeus import Client
import ruamel.yaml as yaml


class FlightTracker(object):
    """tool to retrieve and track flight prices

    currently assume origin is atl, carrier is dl, and segments is 1"""

    # constructor
    def __init__(self, dest='MIA', depart='2019-12-23'):
        # set instance vars
        self.__dest = dest
        self.__depart = depart
        self.__data = []

        # set cache name
        cache = f"{self.__dest}-{self.__depart}-{date.today()}.txt"

        # retrieve or load data
        if Path(cache).is_file():
            # load cached file for today's prices
            print('Using cached data retrieved today for prices.')
        else:
            # query and store response data
            print('Querying Amadeus endpoint for today\'s prices.')
            today_data = self.__amadeus_client()

            # cache date and response data
            open(cache, 'w').write(yaml.dump([date.today()]))
            open(cache, 'a').write(yaml.dump(today_data))

        # add in additional cached data
        for cached in Path('.').glob(f"{self.__dest}-{self.__depart}-*.txt"):
            # read in cached data as string (cached is object and must be cast)
            cached_data = open(str(cached)).read()
            # load cached data from yaml and add to data dict
            self.__data.extend(yaml.safe_load(cached_data))

        #self.__data = self.__data.sort(key=lambda offer: offer['services'][0]['segments'][0]['flightSegment']['number'])

    # queries amadeus for prices
    def __amadeus_client(self):
        # set credentials
        creds = yaml.safe_load(open('/home/matt/.amadeus/creds').read())

        # initialize client
        amadeus = Client(client_id=creds['api_key'], client_secret=creds['api_secret'])

        # configure request and assign response
        response = amadeus.shopping.flight_offers.get(
            origin='ATL',
            destination=self.__dest,
            departureDate=self.__depart
        )

        # run returned query data through preferences filter
        data = self.__filter_data(response.data)

        return data

    # filter the results from amadeus for preferences (currently hardcoded delta and direct)
    def __filter_data(self, data):
        # initialize filtered array of offers
        filtered = []

        # iterate through retrieved offers
        for offer in data:
            # add offer if direct flight and carrier is delta
            if len(offer['offerItems'][0]['services'][0]['segments']) == 1 and offer['offerItems'][0]['services'][0]['segments'][0]['flightSegment']['carrierCode'] == 'DL':
                filtered.append(offer['offerItems'][0])

        # TODO: sort by number

        return filtered


    # TODO: need to output retrieval date for each set of prices
    # displays history of prices for selected destination and depart date
    def display_flights(self):
        # output origin, dest, date
        print('Origin:', 'ATL', '\tDestination:', self.__dest, '\tDate:', self.__depart)

        # output time and price
        for offer in self.__data:
            # if element is string then it is the retrieval date
            if isinstance(offer, str):
                print('Retrieval Date:', offer)
                continue

            # easier to read
            depart = offer['services'][0]['segments'][0]['flightSegment']['departure']['at']
            depart_time = re.sub(r'-.*', '', re.sub(r'.*T', '', depart))
            price = offer['price']['total']
            number = offer['services'][0]['segments'][0]['flightSegment']['number']
            plane = offer['services'][0]['segments'][0]['flightSegment']['aircraft']['code']
            # output info
            print('Number:', number, '\tDeparture Time:', depart_time, '\tPrice:', price, '\tPlane:', plane)


# main method
def main():
    """main method for flight tracker"""
    # construct class object
    flight = FlightTracker()

    # display results
    flight.display_flights()

    return 0


# execute flight tracker
main()
