from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import GhostProfileViewSet, GhostSubscriptionViewSet, RoomViewSet

router = DefaultRouter()
router.register(r'ghosts', GhostProfileViewSet, basename='ghosts')
router.register(r'following', GhostSubscriptionViewSet, basename='following')
router.register(r'rooms', RoomViewSet, basename='rooms')

urlpatterns = [
    path('', include(router.urls)),
]
