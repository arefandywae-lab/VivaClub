import os
import django
import sys

# Set up Django environment
sys.path.append('/Users/audi/Desktop/333/Server')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from apps.users.models import User
from apps.clinical.models import TimeSlot
from django.utils import timezone
from datetime import timedelta

def seed_doctor():
    print("🌱 Seeding a verified doctor and time slots...")
    
    # Create Doctor
    doctor, created = User.objects.get_or_create(
        username='test_doctor_demo',
        defaults={
            'email': 'doctor@vivaclub.com',
            'display_name': 'Dr. Somsak Viva',
            'role': User.Role.DOCTOR,
            'specialty': 'Psychiatrist',
            'verified_at': timezone.now(),
            'is_online': True
        }
    )
    if not created:
        doctor.verified_at = timezone.now()
        doctor.role = User.Role.DOCTOR
        doctor.save()
    
    doctor.set_password('password123')
    doctor.save()
    log_msg = "Created" if created else "Updated"
    print(f"✅ {log_msg} verified doctor: {doctor.username}")

    # Create Time Slots for the next 20 days
    now = timezone.now()
    for i in range(1, 21):
        start_time = (now + timedelta(days=i)).replace(hour=10, minute=0, second=0, microsecond=0)
        end_time = start_time + timedelta(hours=1)
        
        slot, s_created = TimeSlot.objects.get_or_create(
            doctor=doctor,
            start_time=start_time,
            end_time=end_time,
            defaults={'price': 500.00}
        )
        if s_created:
            print(f"✅ Created slot: {start_time}")

    print("🏁 Seeding completed.")

if __name__ == "__main__":
    seed_doctor()
