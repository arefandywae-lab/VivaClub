from django.core.management.base import BaseCommand
from django.utils import timezone
from datetime import timedelta
from apps.community.models import Room

class Command(BaseCommand):
    help = 'Deletes rooms that have been empty for more than 1 minute'

    def handle(self, *args, **options):
        one_minute_ago = timezone.now() - timedelta(minutes=1)
        
        # Find rooms that are active, empty, and haven't been active for > 1 minute
        empty_rooms = Room.objects.filter(
            is_active=True,
            listeners_count=0,
            last_active_at__lte=one_minute_ago
        )
        
        count = empty_rooms.count()
        for room in empty_rooms:
            self.stdout.write(f'Closing room: {room.title}')
            room.is_active = False
            room.save()
            
        self.stdout.write(self.style.SUCCESS(f'Successfully closed {count} empty rooms'))
