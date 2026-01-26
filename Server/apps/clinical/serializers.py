from rest_framework import serializers
from .models import Assessment, OpdNote, PersonalNote

class AssessmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Assessment
        fields = ['id', 'patient', 'total_score', 'answers', 'risk_level', 'created_at']
        read_only_fields = ['id', 'patient', 'risk_level', 'created_at']

    def create(self, validated_data):
        # Calculate risk level logic here or simple pass
        score = validated_data.get('total_score', 0)
        if score >= 20: 
            validated_data['risk_level'] = Assessment.RiskLevel.SEVERE
        elif score >= 10:
            validated_data['risk_level'] = Assessment.RiskLevel.MODERATE
        else:
            validated_data['risk_level'] = Assessment.RiskLevel.LOW
            
        return super().create(validated_data)

class OpdNoteSerializer(serializers.ModelSerializer):
    class Meta:
        model = OpdNote
        fields = ['id', 'doctor', 'patient_id', 'encrypted_content', 'iv', 'created_at']
        read_only_fields = ['id', 'doctor', 'created_at']

class PersonalNoteSerializer(serializers.ModelSerializer):
    class Meta:
        model = PersonalNote
        fields = ['id', 'patient', 'encrypted_content', 'created_at']
        read_only_fields = ['id', 'patient', 'created_at']
