from rest_framework import viewsets, permissions
from .models import Assessment, OpdNote, PersonalNote
from .serializers import AssessmentSerializer, OpdNoteSerializer, PersonalNoteSerializer

class AssessmentViewSet(viewsets.ModelViewSet):
    serializer_class = AssessmentSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role == 'doctor':
             # Doctors can see all assessments (In real app, filter by patient)
             return Assessment.objects.all()
        return Assessment.objects.filter(patient=user)

    def perform_create(self, serializer):
        serializer.save(patient=self.request.user)

class OpdNoteViewSet(viewsets.ModelViewSet):
    serializer_class = OpdNoteSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role == 'doctor':
            return OpdNote.objects.filter(doctor=user)
        # Patients can see their own OPD notes? Maybe read-only?
        # Usually OPD notes are doctor internal or shared. Let's assume shared for transparency but read-only.
        return OpdNote.objects.filter(patient_id=user.id)

    def perform_create(self, serializer):
        if self.request.user.role != 'doctor':
             raise permissions.PermissionDenied("Only doctors can write OPD notes.")
        serializer.save(doctor=self.request.user)

class PersonalNoteViewSet(viewsets.ModelViewSet):
    serializer_class = PersonalNoteSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return PersonalNote.objects.filter(patient=self.request.user)

    def perform_create(self, serializer):
        serializer.save(patient=self.request.user)
