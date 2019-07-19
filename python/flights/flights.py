#TODO: variable destination, variable departure date, store response data in file and check timestamp for update, track prices over time, number/code/duration/availability might be nice, sort by price, https://amadeus4dev.github.io/amadeus-python/#shopping-hotels

from amadeus import Client
import ruamel.yaml as yaml


# set credentials
creds = yaml.safe_load(open('/home/matt/.amadeus/creds').read())

# initialize client
amadeus = Client(client_id=creds['api_key'], client_secret=creds['api_secret'])

# configure request and assign response
response = amadeus.shopping.flight_offers.get(
    origin='ATL',
    destination='MIA',
    departureDate='2019-12-23'
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

# output time and price
for offer in filtered:
    print('Departure Time:', offer['services'][0]['segments'][0]['flightSegment']['departure']['at'], 'Price:', offer['price']['total'])
