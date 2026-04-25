from django.core.management.base import BaseCommand
from apps.utils.notifications import broadcast_test_push
from apps.users.models import DeviceToken

class Command(BaseCommand):
    help = 'Sends a test push notification to all registered devices'

    def handle(self, *args, **options):
        self.stdout.write('🔍 Finding registered devices...')
        tokens_count = DeviceToken.objects.count()
        
        if tokens_count == 0:
            self.stdout.write(self.style.WARNING('⚠️ No registered device tokens found in the database.'))
            self.stdout.write('Note: Ensure the app has requested permission and saved the token to the backend.')
            return

        self.stdout.write(f'🚀 Sending test notification to {tokens_count} devices...')
        
        success_count = broadcast_test_push()
        
        if success_count > 0:
            self.stdout.write(self.style.SUCCESS(f'✅ Successfully sent {success_count} notifications!'))
        else:
            self.stdout.write(self.style.ERROR('❌ Failed to send notifications. Check server logs for details.'))
