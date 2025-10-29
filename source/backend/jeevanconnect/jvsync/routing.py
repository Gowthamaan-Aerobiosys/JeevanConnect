from django.urls import re_path

from .consumers import UserConsumer, VentilatorConsumer

ws_urlpatterns = [
    re_path(r'ws/user/(?P<id>[0-9 -]+)/(?P<key>[a-zA-Z0-9 -]+)/$', UserConsumer.as_asgi(), name='user_consumer'),
    re_path(r'ws/ven/(?P<id>[0-9 -]+)/(?P<serial_number>[a-zA-Z0-9_-]+)/(?P<key>[a-zA-Z0-9 -]+)/$', VentilatorConsumer.as_asgi(), name='ventilator_consumer'),
]
