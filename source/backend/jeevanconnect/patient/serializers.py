from rest_framework.serializers import ModelSerializer

from .models import Patient, AdmissionRecord, ABGReport, ClinicalAdvice
from authentication.serializers import WorkspaceSerializer

class PatientSerializer(ModelSerializer):
    workspace = WorkspaceSerializer(many=False, read_only=True)
    class Meta:
        model = Patient
        fields = '__all__'
        read_only_fields = ('created_at', 'modified_at')

class AdmissionRecordSerializer(ModelSerializer):
    patient = PatientSerializer(many=False, read_only=True)
    class Meta:
        model = AdmissionRecord
        fields = '__all__'

class ABGReportSerializer(ModelSerializer):
    class Meta:
        model = ABGReport
        fields = '__all__'
        
class ClinicalAdviceSerializer(ModelSerializer):
    class Meta:
        model = ClinicalAdvice
        fields = '__all__'