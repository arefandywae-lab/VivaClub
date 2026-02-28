import os
import sys
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.contrib.auth import get_user_model
User = get_user_model()

username = "audi"

print("=========================================")
print(f"DATABASE DIAGNOSTICS FOR USER: {username}")
print("=========================================")

try:
    if User.objects.filter(username=username).exists():
        user = User.objects.get(username=username)
        print(f"User Found: {user.username} (ID: {user.id})")
        print(f"Role: {user.role}")
        print(f"Is Staff (Django Built-in): {user.is_staff}")
        print(f"Is Superuser (Django Built-in): {user.is_superuser}")
        
        # In our implementation, we also have a "role" field which might be taking precedence
        if user.role != User.Role.ADMIN:
             print(f"\nWARNING: user.role is '{user.role}', not 'admin'.")
             print("Fixing user.role to ADMIN...")
             user.role = User.Role.ADMIN
             user.save()
             print("Fixed role to ADMIN.")
             
        # Just to be absolutely sure
        user.is_staff = True
        user.is_superuser = True
        user.save()
        print("\nRe-applied is_staff=True and is_superuser=True just in case.")
        
    else:
        print(f"User '{username}' does NOT exist in the database.")
except Exception as e:
    print(f"ERROR: {str(e)}")

print("=========================================")
