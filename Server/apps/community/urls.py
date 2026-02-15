from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    GhostProfileViewSet, 
    GhostSubscriptionViewSet, 
    RoomViewSet,
    NotificationViewSet,
    FCMTokenView
)

router = DefaultRouter()
router.register(r'ghosts', GhostProfileViewSet, basename='ghosts')
router.register(r'following', GhostSubscriptionViewSet, basename='following')
router.register(r'rooms', RoomViewSet, basename='rooms')
router.register(r'notifications', NotificationViewSet, basename='notifications')

urlpatterns = [
    path('', include(router.urls)),
    path('fcm-token/', FCMTokenView.as_view(), name='fcm-token'),
]
