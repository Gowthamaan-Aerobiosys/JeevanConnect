from rest_framework import response

_CODE = "CODE"
_INFO = "INFO"
_DATA = "DATA"

class ERROR_CODES():
    ENTITY_NOT_FOUND = "ENTITY NOT FOUND"
    ENTITY_ALREADY_EXISTS = "ENTITY ALREADY EXISTS"
    INVALID_CREDENTIALS = "INVALID CREDENTIALS"
    INVALID_REQUEST = "INVALID REQUEST"
    INTERNAL_ERROR = "INTERNAL ERROR"
    NOT_IMPLEMENTED = "NOT IMPLEMENTED"
    CONFLICT = "CONFLICT"
    SERVICE_UNAVAILABLE = "SERVICE UNAVAILABLE"
    CANNOT_PROCESS_REQUEST = "CANNOT PROCESS REQUEST"

class SUCCESS_CODES():
    SUCCESS = "SUCCESS"

def Response(status_code, response_code, info, data={}):
    responseJson = {}
    responseJson[_CODE]=response_code
    responseJson[_INFO]=info
    responseJson[_DATA]=data
    return response.Response(responseJson, status= status_code)
