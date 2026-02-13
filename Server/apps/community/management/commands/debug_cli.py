from django.core.management.base import BaseCommand
from apps.users.models import User
from apps.community.models import Room
from django.utils import timezone

class Command(BaseCommand):
    help = 'Interactive CLI for debugging Users and Rooms'

    def handle(self, *args, **options):
        while True:
            self.stdout.write(self.style.SUCCESS('\n--- Debug CLI ---'))
            self.stdout.write('1. List Active Rooms')
            self.stdout.write('2. Delete Room')
            self.stdout.write('3. List Users')
            self.stdout.write('4. Delete User')
            self.stdout.write('5. Exit')
            
            choice = input("Select option: ")
            
            if choice == '1':
                self.list_rooms()
            elif choice == '2':
                self.delete_room()
            elif choice == '3':
                self.list_users()
            elif choice == '4':
                self.delete_user()
            elif choice == '5':
                break
            else:
                self.stdout.write(self.style.WARNING("Invalid choice"))

    def list_rooms(self):
        rooms = Room.objects.filter(is_active=True)
        self.stdout.write(f"\nFound {rooms.count()} active rooms:")
        for r in rooms:
            self.stdout.write(f"[{r.id}] {r.title} (Listeners: {r.listeners_count}, Host: {r.host.display_name})")

    def delete_room(self):
        room_id = input("Enter Room ID to delete: ")
        try:
            Room.objects.filter(id=room_id).delete() # Hard delete or soft delete? Let's just update to inactive for safety usually, but request said "delete". Let's do hard delete for debug.
            self.stdout.write(self.style.SUCCESS(f"Room {room_id} deleted."))
        except Exception as e:
            self.stdout.write(self.style.ERROR(f"Error: {e}"))

    def list_users(self):
        users = User.objects.all().order_by('-date_joined')[:20]
        self.stdout.write(f"\nLast 20 Users:")
        for u in users:
            self.stdout.write(f"[{u.id}] {u.username} (Role: {u.role})")

    def delete_user(self):
        username = input("Enter Username to delete: ")
        try:
            # Prevent deleting superuser easily
            u = User.objects.get(username=username)
            if u.is_superuser:
                 confirm = input("This is a superuser! Type 'yes' to confirm: ")
                 if confirm != 'yes': return
            
            u.delete()
            self.stdout.write(self.style.SUCCESS(f"User {username} deleted."))
        except User.DoesNotExist:
             self.stdout.write(self.style.ERROR("User not found."))
        except Exception as e:
            self.stdout.write(self.style.ERROR(f"Error: {e}"))
