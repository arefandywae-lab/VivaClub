from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import GhostProfileViewSet, GhostSubscriptionViewSet
from .livekit_views import LiveKitTokenView

router = DefaultRouter()
router.register(r'ghosts', GhostProfileViewSet, basename='ghosts')
router.register(r'following', GhostSubscriptionViewSet, basename='following')

urlpatterns = [
    path('', include(router.urls)),
    path('livekit/token/', LiveKitTokenView.as_view(), name='livekit_token'),
]
