import os
import sys
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.contrib.auth import get_user_model
User = get_user_model()

username = sys.argv[1] if len(sys.argv) > 1 else 'audi'
password = sys.argv[2] if len(sys.argv) > 2 else 'Alfata0232'
email = f"{username}@vivaclubs.site"

try:
    if User.objects.filter(username=username).exists():
        user = User.objects.get(username=username)
        user.is_staff = True
        user.is_superuser = True
        user.set_password(password)
        user.save()
        print(f"SUCCESS: Existing user '{username}' promoted to Admin/Staff with updated password.")
    else:
        user = User.objects.create_superuser(username, email, password)
        print(f"SUCCESS: New superuser '{username}' created.")
except Exception as e:
    print(f"ERROR: {str(e)}")
