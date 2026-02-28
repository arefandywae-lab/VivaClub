import os
import sys
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.contrib.auth import get_user_model
User = get_user_model()

print("=========================================")
print("HARD RESETTING SUPERUSER ACCOUNTS")
print("=========================================")

try:
    # Delete potentially corrupted accounts
    print("1. Deleting old 'admin' and 'audi' accounts...")
    deleted, _ = User.objects.filter(username__iexact='admin').delete()
    print(f"   Deleted {deleted} 'admin' records.")
    
    deleted, _ = User.objects.filter(username__iexact='audi').delete()
    print(f"   Deleted {deleted} 'audi' records.")
    
    # Create the fresh admin account
    print("2. Creating fresh 'admin' superuser...")
    new_admin = User.objects.create_superuser(
        username='admin', 
        email='admin@vivaclubs.site', 
        password='AdminPassword123!'
    )
    
    # Force role mapping just in case
    new_admin.role = 'admin'
    new_admin.save()
    
    print("\nSUCCESS! Fresh admin account created.")
    print("-----------------------------------------")
    print("Username: admin")
    print("Password: AdminPassword123!")
    print("-----------------------------------------")
    
except Exception as e:
    print(f"ERROR: {str(e)}")
