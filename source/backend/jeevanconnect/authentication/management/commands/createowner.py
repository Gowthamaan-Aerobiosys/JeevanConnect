from django.core.management.base import BaseCommand, CommandError
from django.contrib.auth import get_user_model
import os

class Command(BaseCommand):

    def handle(self, *args, **options):
        email = "gowthamaan.palani@aerobiosys.com"
        password="12345678"
        first_name="Gowthamaan"
        last_name="Palani"
        designation="Developer"
        registered_id="ED23S037"
        contact = 9894157949
        
        User = get_user_model()
        if not User.objects.filter(email=email).exists():
            User.objects.create_superuser(email,password=password, first_name=first_name, last_name=last_name,
                                designation=designation, registered_id=registered_id, contact=contact)
            self.stdout.write(self.style.SUCCESS('Successfully created new super user'))