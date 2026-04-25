from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    AssessmentViewSet, OpdNoteViewSet, PersonalNoteViewSet,
    DoctorViewSet, TimeSlotViewSet, AppointmentViewSet, 
    SOSCallViewSet, DoctorReviewViewSet, LiveKitWebhookView
)

router = DefaultRouter()
router.register(r'assessments', AssessmentViewSet, basename='assessments')
router.register(r'opd-notes', OpdNoteViewSet, basename='opd_notes')
router.register(r'personal-notes', PersonalNoteViewSet, basename='personal_notes')
router.register(r'doctors', DoctorViewSet, basename='doctors')
router.register(r'timeslots', TimeSlotViewSet, basename='timeslots')
router.register(r'appointments', AppointmentViewSet, basename='appointments')
router.register(r'sos', SOSCallViewSet, basename='sos')
router.register(r'reviews', DoctorReviewViewSet, basename='reviews')

urlpatterns = [
    path('livekit-webhook/', LiveKitWebhookView.as_view(), name='livekit-webhook'),
    path('', include(router.urls)),
]
