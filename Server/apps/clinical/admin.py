from django.contrib import admin
from .models import Assessment, OpdNote, PersonalNote

@admin.register(Assessment)
class AssessmentAdmin(admin.ModelAdmin):
    list_display = ('patient', 'risk_level', 'total_score', 'created_at')
    list_filter = ('risk_level',)
    readonly_fields = ('answers',)

@admin.register(OpdNote)
class OpdNoteAdmin(admin.ModelAdmin):
    list_display = ('id', 'doctor', 'patient_id', 'created_at')
    # Encrypted content shouldn't be editable directly comfortably, but good for overview

@admin.register(PersonalNote)
class PersonalNoteAdmin(admin.ModelAdmin):
    list_display = ('id', 'patient', 'created_at')
