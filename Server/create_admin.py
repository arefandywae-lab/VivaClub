import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.contrib.auth import get_user_model
User = get_user_model()

username = "admin"
password = "vivaclub_admin_1234"
email = "admin@vivaclubs.site"

if User.objects.filter(username=username).exists():
    user = User.objects.get(username=username)
    user.set_password(password)
    user.is_staff = True
    user.is_superuser = True
    user.save()
    print(f"Updated existing user '{username}' with new password: {password}")
else:
    user = User.objects.create_superuser(username=username, email=email, password=password)
    print(f"Created new superuser '{username}' with password: {password}")
