from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from apps.community.models import GhostProfile
from apps.bookings.models import AppointmentSlot
from django.utils import timezone
from datetime import timedelta

User = get_user_model()

class Command(BaseCommand):
    help = 'Seeds database with initial test data'

    def handle(self, *args, **kwargs):
        self.stdout.write('Seeding data...')

        # 1. Create Patient
        patient, created = User.objects.get_or_create(
            username='patient1',
            defaults={
                'email': 'patient1@example.com',
                'role': 'patient',
                'display_name': 'Somchai Patient'
            }
        )
        if created:
            patient.set_password('password123')
            patient.save()
            # Ghost Profile auto-created by signal/serializer usually, but let's ensure
            GhostProfile.objects.get_or_create(user=patient, defaults={'display_name': 'Sad Panda', 'is_active': True})
            self.stdout.write(self.style.SUCCESS(f'Created user: {patient.username}'))
        else:
            self.stdout.write(f'User {patient.username} already exists')

        # 2. Create Doctor
        doctor, created = User.objects.get_or_create(
            username='doctor1',
            defaults={
                'email': 'doctor1@example.com',
                'role': 'doctor',
                'display_name': 'Dr. Strange',
                'license_id': 'MD12345',
                'specialty': 'Psychiatrist',
                'is_online': True
            }
        )
        if created:
            doctor.set_password('password123')
            doctor.save()
            GhostProfile.objects.get_or_create(user=doctor, defaults={'display_name': 'Dr. Ghost', 'is_active': True})
            self.stdout.write(self.style.SUCCESS(f'Created user: {doctor.username}'))
        else:
             self.stdout.write(f'User {doctor.username} already exists')

        # 3. Create Slots
        start = timezone.now().replace(minute=0, second=0, microsecond=0) + timedelta(hours=1)
        for i in range(3):
            slot_start = start + timedelta(hours=i)
            slot_end = slot_start + timedelta(minutes=50)
            
            AppointmentSlot.objects.get_or_create(
                doctor=doctor,
                start_time=slot_start,
                defaults={
                    'end_time': slot_end,
                    'cost': 500.00,
                    'status': 'AVAILABLE'
                }
            )
        self.stdout.write(self.style.SUCCESS('Created appointment slots'))

        self.stdout.write(self.style.SUCCESS('Data seeding complete!'))
