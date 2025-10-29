import channels.layers
from asgiref.sync import async_to_sync
from django.core.management.base import BaseCommand

class Command(BaseCommand):
    help = "Verify Redis Server"

    def handle(self, *args, **options):
        channel_layer = channels.layers.get_channel_layer()
        async_to_sync(channel_layer.send)('test_channel', {'ping': 'pong'})
        print(async_to_sync(channel_layer.receive)('test_channel'))