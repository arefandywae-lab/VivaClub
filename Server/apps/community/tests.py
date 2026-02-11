from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from django.contrib.auth import get_user_model
from apps.community.models import Room, GhostProfile

User = get_user_model()

class RoomAPITest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(username='testuser', password='password123')
        self.client.force_authenticate(user=self.user)

    def test_create_room(self):
        """Test creating a new room"""
        data = {
            "title": "Test Room",
            "category": "general"
        }
        response = self.client.post('/api/community/rooms/', data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Room.objects.count(), 1)
        self.assertEqual(Room.objects.get().title, "Test Room")
        # Verify host is set
        room = Room.objects.get()
        self.assertEqual(room.host.user, self.user)

    def test_list_rooms(self):
        """Test listing active rooms"""
        # Create a ghost profile first (needed for room host)
        ghost = GhostProfile.objects.create(user=self.user, display_name="Host")
        Room.objects.create(title="Room 1", host=ghost, category="general")
        Room.objects.create(title="Room 2", host=ghost, category="depression")
        
        response = self.client.get('/api/community/rooms/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # Depending on pagination, but results should contain our rooms
        # If pagination is on, data might be in 'results'
        if 'results' in response.data:
            self.assertEqual(len(response.data['results']), 2)
        else:
            self.assertEqual(len(response.data), 2)

    def test_join_room_token(self):
        """Test joining a room returns a LiveKit token"""
        ghost = GhostProfile.objects.create(user=self.user, display_name="Host")
        room = Room.objects.create(title="LiveKit Room", host=ghost)
        
        url = f'/api/community/rooms/{room.id}/join/'
        response = self.client.post(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('token', response.data)
        self.assertIn('room_id', response.data)
        self.assertEqual(str(response.data['room_id']), str(room.id))
