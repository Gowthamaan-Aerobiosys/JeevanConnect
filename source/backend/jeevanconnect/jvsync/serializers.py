from rest_framework.serializers import ModelSerializer
from .models import VentilationSession

from product.serializers import VentilatorSerializer, WorkspaceSerializer
from patient.serializers import PatientSerializer

class VentilatorSessionSerializer(ModelSerializer):
    ventilator = VentilatorSerializer(many=False, read_only=True)
    workspace = WorkspaceSerializer(many=False, read_only=True)
    patient = PatientSerializer(many=False, read_only=True)
    
    class Meta:
        model = VentilationSession
        fields = "__all__"