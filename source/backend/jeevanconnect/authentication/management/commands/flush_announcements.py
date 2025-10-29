# management/commands/delete_old_announcements.py
from django.core.management.base import BaseCommand
from django.utils import timezone
from ...models import Announcement

class Command(BaseCommand):
    help = 'Deletes announcements older than 24 hours'

    def handle(self, *args, **kwargs):
        cutoff = timezone.now() - timezone.timedelta(days=1)
        old_announcements = Announcement.objects.filter(created_at__lt=cutoff)
        count = old_announcements.count()
        old_announcements.delete()
        self.stdout.write(self.style.SUCCESS(f'Successfully deleted {count} old announcements'))