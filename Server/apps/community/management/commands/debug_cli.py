from django.core.management.base import BaseCommand
from apps.users.models import User
from apps.community.models import Room
from django.utils import timezone
import logging

class Command(BaseCommand):
    help = 'Interactive CLI for debugging Users and Rooms'

    def handle(self, *args, **options):
        # Silence SQL logs
        logging.getLogger('django.db.backends').setLevel(logging.ERROR)
        
        while True:
            self.stdout.write(self.style.SUCCESS('\n================ DEBUG CLI ================'))
            self.stdout.write('1. List Active Rooms')
            self.stdout.write('2. Delete Room (by ID)')
            self.stdout.write('3. Delete ALL Rooms (Cleanup)')
            self.stdout.write('4. List Users')
            self.stdout.write('5. Delete User')
            self.stdout.write('6. Exit')
            self.stdout.write('==========================================')
            
            choice = input("Select option: ")
            
            if choice == '1':
                self.list_rooms()
            elif choice == '2':
                self.delete_room()
            elif choice == '3':
                self.delete_all_rooms()
            elif choice == '4':
                self.list_users()
            elif choice == '5':
                self.delete_user()
            elif choice == '6':
                break
            else:
                self.stdout.write(self.style.WARNING("Invalid choice"))

    def list_rooms(self):
        rooms = Room.objects.filter(is_active=True).order_by('-created_at')
        count = rooms.count()
        
        if count == 0:
            self.stdout.write(self.style.WARNING("\nNo active rooms found."))
            return

        self.stdout.write(f"\nFound {count} active rooms:")
        header = f"{'ID':<38} | {'Title':<20} | {'Who':<20} | {'Listeners'}"
        self.stdout.write("-" * len(header))
        self.stdout.write(header)
        self.stdout.write("-" * len(header))
        
        for r in rooms:
            host_name = r.host.display_name if r.host else "Unknown"
            title = (r.title[:17] + '..') if len(r.title) > 17 else r.title
            row = f"{str(r.id):<38} | {title:<20} | {host_name:<20} | {r.listeners_count}"
            self.stdout.write(row)

    def delete_room(self):
        room_id = input("Enter Room ID to delete: ").strip()
        if not room_id: return
        try:
            Room.objects.filter(id=room_id).delete()
            self.stdout.write(self.style.SUCCESS(f"Room {room_id} deleted."))
        except Exception as e:
            self.stdout.write(self.style.ERROR(f"Error: {e}"))

    def delete_all_rooms(self):
        confirm = input("Are you sure you want to DELETE ALL active rooms? (y/n): ")
        if confirm.lower() == 'y':
            count, _ = Room.objects.all().delete()
            self.stdout.write(self.style.SUCCESS(f"Deleted {count} rooms."))

    def list_users(self):
        users = User.objects.all().order_by('-date_joined')[:20]
        self.stdout.write(f"\nLast 20 Users:")
        header = f"{'Username':<20} | {'Role':<10} | {'Date Joined'}"
        self.stdout.write("-" * len(header))
        self.stdout.write(header)
        self.stdout.write("-" * len(header))
        
        for u in users:
            date_str = u.date_joined.strftime("%Y-%m-%d %H:%M")
            row = f"{u.username:<20} | {u.role:<10} | {date_str}"
            self.stdout.write(row)

    def delete_user(self):
        username = input("Enter Username to delete: ").strip()
        if not username: return
        try:
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
