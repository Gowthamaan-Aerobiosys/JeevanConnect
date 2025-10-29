from django.db import models

from product.models import Ventilator
from patient.models import Patient
from authentication.models import Workspace

class VentilationSessionManager(models.Manager):
    def create(self, session_id = None, ventilator = None, workspace = None):
        session = self.model(
            session_id = session_id,
            ventilator = ventilator,
            workspace = workspace
        )
        session.save(using=self._db)
        return session
        

class VentilationSession(models.Model):
    session_id = models.CharField(max_length=255, blank=False, null=False, primary_key=True, unique=True)
    ventilator = models.ForeignKey(Ventilator, on_delete=models.CASCADE, blank=False, null=False, related_name="session_ventilator")
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, blank=False, null=False, related_name="session_workspace")
    patient = models.ForeignKey(Patient, on_delete=models.SET_NULL, null=True, blank=True, default=None, related_name="session_patient")
    is_archive = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    

class SessionLog(models.Model):
    sessions = models.ForeignKey(VentilationSession, on_delete=models.CASCADE, blank=False, null=False, related_name="logs")
    trend = models.FileField(blank=True, null=True, default=None, name="trend")
    alerts = models.FileField(blank=True, null=True, default=None, name="alerts")
    events = models.FileField(blank=True, null=True, default=None, name="events")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)