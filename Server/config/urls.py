"""
URL configuration for config project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from django.http import JsonResponse

from apps.core_views import MobileTestView, MobileTestV2View

urlpatterns = [
    path('admin/', admin.site.urls),
    path('mobile-test/', MobileTestView.as_view(), name='mobile_test'),
    path('mobile-v2/', MobileTestV2View.as_view(), name='mobile_test_v2'),
    path('api/auth/', include('apps.users.urls')),
    path('api/bookings/', include('apps.bookings.urls')),
    path('api/clinical/', include('apps.clinical.urls')),
    path('api/community/', include('apps.community.urls')),
    path('health/', lambda request: JsonResponse({'status': 'ok'}), name='health'),
]
