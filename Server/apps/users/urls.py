from django.urls import path
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from rest_framework.permissions import AllowAny
from .views import RegisterView, ProfileView, AdminUserListView, AdminUserActionView, AdminCleanupTestDataView, DeviceTokenViewSet
from .serializers import CustomTokenObtainPairSerializer

router = DefaultRouter()
router.register(r'device-tokens', DeviceTokenViewSet, basename='device-token')

# SimpleJWT views inherit DRF global DEFAULT_PERMISSION_CLASSES (IsAuthenticated).
# Wrap them so login/refresh are publicly accessible.
class PublicTokenObtainPairView(TokenObtainPairView):
    permission_classes = (AllowAny,)
    serializer_class = CustomTokenObtainPairSerializer

class PublicTokenRefreshView(TokenRefreshView):
    permission_classes = (AllowAny,)


urlpatterns = router.urls + [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', PublicTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', PublicTokenRefreshView.as_view(), name='token_refresh'),
    path('profile/', ProfileView.as_view(), name='profile'),
    path('admin/users/', AdminUserListView.as_view(), name='admin_users'),
    path('admin/users/<uuid:pk>/<str:action>/', AdminUserActionView.as_view(), name='admin_user_action'),
    path('admin/cleanup-test-data/', AdminCleanupTestDataView.as_view(), name='admin_cleanup_test_data'),
]


