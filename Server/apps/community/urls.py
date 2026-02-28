from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    GhostProfileViewSet, 
    GhostSubscriptionViewSet, 
    RoomViewSet,
    NotificationViewSet,
    FCMTokenView,
    RoomReportViewSet,
    UserTrustScoreView,
    BlockUserViewSet,
    LiveKitWebhookView,
    AdminRoomActionView
)

router = DefaultRouter()
router.register(r'ghosts', GhostProfileViewSet, basename='ghosts')
router.register(r'following', GhostSubscriptionViewSet, basename='following')
router.register(r'rooms', RoomViewSet, basename='rooms')
router.register(r'notifications', NotificationViewSet, basename='notifications')
router.register(r'reports', RoomReportViewSet, basename='reports')
router.register(r'blocks', BlockUserViewSet, basename='blocks')

urlpatterns = [
    path('', include(router.urls)),
    path('fcm-token/', FCMTokenView.as_view(), name='fcm-token'),
    path('trust-score/me/', UserTrustScoreView.as_view(), name='trust-score-me'),
    path('webhook/livekit/', LiveKitWebhookView.as_view(), name='webhook-livekit'),
    path('admin/rooms/<uuid:pk>/<str:action>/', AdminRoomActionView.as_view(), name='admin-room-action'),
]
