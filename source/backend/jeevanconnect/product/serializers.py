from rest_framework.serializers import ModelSerializer

from .models import Ventilator, ServiceTicket, ServiceLog
from authentication.serializers import WorkspaceSerializer

class VentilatorSerializer(ModelSerializer):
    workspace = WorkspaceSerializer(many=False, read_only=True)
    class Meta:
        model = Ventilator
        fields = '__all__'
        read_only_fields = ('created_at', 'modified_at')

class ServiceTicketSerializer(ModelSerializer):
    ventilator = VentilatorSerializer(many=False, read_only=True)
    class Meta:
        model = ServiceTicket
        fields = '__all__'

class ServiceLogSerializer(ModelSerializer):
    class Meta:
        model = ServiceLog
        fields = '__all__'