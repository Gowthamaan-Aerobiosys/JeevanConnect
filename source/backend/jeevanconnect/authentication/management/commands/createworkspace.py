from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from authentication.models import Workspace

class Command(BaseCommand):
    help = 'Creates a default workspace for the owner user created by createowner.py'

    def handle(self, *args, **options):
        # Get the user that was created in createowner.py
        email = "gowthamaan.palani@aerobiosys.com"
        User = get_user_model()
        
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            self.stdout.write(self.style.ERROR(f'User with email {email} does not exist. Please run createowner command first.'))
            return
            
        # Check if workspace already exists for this user
        if Workspace.objects.filter(default_user=user).exists():
            self.stdout.write(self.style.WARNING(f'Workspace already exists for user {email}'))
            return
            
        # Default workspace details
        workspace_name = "Aerobiosys Workspace"
        registered_id = "AERO2023"
        street_address = "123 Tech Park"
        city = "Puducherry"
        state = "Puducherry"
        country = "India"
        postal_code = "605001"
        website = "https://www.aerobiosys.com"
        contact = "9894157949"
        
        try:
            # Create the workspace
            workspace = Workspace.objects.create_workspace(
                name=workspace_name,
                registered_id=registered_id,
                email=email,
                user=user,
                street_address=street_address,
                city=city,
                state=state,
                postal_code=postal_code,
                website=website,
                contact=contact,
                country=country
            )
            
            # Set workspace as confirmed and active
            workspace.confirmed = True
            workspace.active = True
            workspace.save()
            
            self.stdout.write(self.style.SUCCESS(f'Successfully created workspace "{workspace_name}" for {user.get_full_name()}'))
            
        except Exception as e:
            self.stdout.write(self.style.ERROR(f'Failed to create workspace: {str(e)}'))