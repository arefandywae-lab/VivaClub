import os
import sys

# Define base path to get config
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
import django
django.setup()

from django.conf import settings
print("Configured REDIS_URL:", settings.CHANNEL_LAYERS['default']['CONFIG']['hosts'][0])
