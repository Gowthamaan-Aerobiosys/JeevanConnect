import geoip2.database
import os

def get_location_info(ip_address):
    try:
        dbpath = os.path.join(os.getcwd(), 'shared\\GeoLite2-City.mmdb')
        with geoip2.database.Reader(dbpath) as reader:
            response = reader.city(ip_address)
            return {
                'country': response.country.name,
                'city': response.city.name,
            }
    except Exception as exception:
        print(exception)
        return {'country': None, 'city': None}