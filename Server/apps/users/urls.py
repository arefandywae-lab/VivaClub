from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from .views import RegisterView, ProfileView, AdminUserListView, AdminUserActionView, AdminCleanupTestDataView

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('profile/', ProfileView.as_view(), name='profile'),
    path('admin/users/', AdminUserListView.as_view(), name='admin_users'),
    path('admin/users/<uuid:pk>/<str:action>/', AdminUserActionView.as_view(), name='admin_user_action'),
    path('admin/cleanup-test-data/', AdminCleanupTestDataView.as_view(), name='admin_cleanup_test_data'),
]


