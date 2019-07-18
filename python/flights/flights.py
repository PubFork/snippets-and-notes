#TODO: variable destination, variable departure date, filter output data to only dl/direct, store response data in file, https://amadeus4dev.github.io/amadeus-python/#shopping-hotels

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
print(response.data)
