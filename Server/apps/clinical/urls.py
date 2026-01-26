from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import AssessmentViewSet, OpdNoteViewSet, PersonalNoteViewSet

router = DefaultRouter()
router.register(r'assessments', AssessmentViewSet, basename='assessments')
router.register(r'opd-notes', OpdNoteViewSet, basename='opd_notes')
router.register(r'personal-notes', PersonalNoteViewSet, basename='personal_notes')

urlpatterns = [
    path('', include(router.urls)),
]
