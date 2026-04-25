from rest_framework import serializers
from .models import Assessment, OpdNote, PersonalNote, TimeSlot, Appointment, SOSCall, DoctorReview
from django.contrib.auth import get_user_model

User = get_user_model()

class UserMinimalSerializer(serializers.ModelSerializer):
    avg_rating = serializers.FloatField(read_only=True)
    review_count = serializers.IntegerField(read_only=True)

    class Meta:
        model = User
        fields = ['id', 'display_name', 'specialty', 'is_online', 'avg_rating', 'review_count', 'current_mood', 'streak_count']

class AssessmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Assessment
        fields = ['id', 'patient', 'total_score', 'answers', 'risk_level', 'created_at']
        read_only_fields = ['id', 'patient', 'risk_level', 'created_at']

    def create(self, validated_data):
        score = validated_data.get('total_score', 0)
        if score >= 20: 
            validated_data['risk_level'] = Assessment.RiskLevel.SEVERE
        elif score >= 10:
            validated_data['risk_level'] = Assessment.RiskLevel.MODERATE
        else:
            validated_data['risk_level'] = Assessment.RiskLevel.LOW
            
        return super().create(validated_data)

class TimeSlotSerializer(serializers.ModelSerializer):
    class Meta:
        model = TimeSlot
        fields = '__all__'
        read_only_fields = ['id', 'doctor']

class AppointmentSerializer(serializers.ModelSerializer):
    doctor_detail = UserMinimalSerializer(source='doctor', read_only=True)
    patient_detail = UserMinimalSerializer(source='patient', read_only=True)
    slot_detail = TimeSlotSerializer(source='slot', read_only=True)
    
    # Aliases for Dashboard Compatibility
    patient_name = serializers.CharField(source='patient.display_name', read_only=True)
    doctor_name = serializers.CharField(source='doctor.display_name', read_only=True)
    scheduled_at = serializers.DateTimeField(source='slot.start_time', read_only=True)

    class Meta:
        model = Appointment
        fields = '__all__'
        read_only_fields = ['id', 'patient', 'doctor', 'created_at', 'updated_at']

class SOSCallSerializer(serializers.ModelSerializer):
    patient_detail = UserMinimalSerializer(source='patient', read_only=True)
    
    class Meta:
        model = SOSCall
        fields = '__all__'
        read_only_fields = ['id', 'patient', 'priority_score', 'created_at']

class DoctorReviewSerializer(serializers.ModelSerializer):
    class Meta:
        model = DoctorReview
        fields = '__all__'
        read_only_fields = ['id', 'patient', 'created_at']

class OpdNoteSerializer(serializers.ModelSerializer):
    class Meta:
        model = OpdNote
        fields = ['id', 'appointment', 'doctor', 'patient', 'encrypted_content', 'iv', 'created_at']
        read_only_fields = ['id', 'doctor', 'created_at']

class PersonalNoteSerializer(serializers.ModelSerializer):
    class Meta:
        model = PersonalNote
        fields = ['id', 'patient', 'encrypted_content', 'created_at']
        read_only_fields = ['id', 'patient', 'created_at']
