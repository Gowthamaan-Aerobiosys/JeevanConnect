from django.db import models
from django.contrib.postgres.fields import ArrayField

from authentication.models import Workspace

class PatientManager(models.Manager):
    def create(self, patient_id, name, gender, age, blood_group, contact, aadhar, abha, workspace):
        if not patient_id:
            raise ValueError('Patient must have a patient id')
        if not gender:
            raise ValueError('Patient must have a gender')
        if not age:
            raise ValueError('Patient must have a age')
        if not blood_group:
            raise ValueError('Patient must have a blood group')
        if not contact:
            raise ValueError('Patient must have a contact')
        
        patient = self.model(
            patient_id = patient_id,
            name = name,
            gender = gender,
            age = age,
            blood_group = blood_group,
            contact =  contact,
            aadhar = aadhar,
            abha = abha,
            workspace = workspace
        )
        patient.save(using=self._db)
        return patient     

class Patient(models.Model):
    patient_id = models.CharField(max_length=20, blank=False, null=False, unique=True, primary_key=True)
    name = models.CharField(max_length=255, blank=False, null=False)
    gender = models.CharField(max_length=10, blank=False, null=False)
    age = models.IntegerField(null=False, blank=False)
    blood_group = models.CharField(max_length=10, null=True, blank=False, default=None)
    contact = models.BigIntegerField(null=True, blank=True, default=None)
    
    active = models.BooleanField(default=True)
    
    aadhar = models.CharField(max_length=20, null=True, blank=True, default=None)
    abha = models.CharField(max_length=20, null=True, blank=True, default=None)
    
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name='patients', blank=False, null=False,)
    
    created_at = models.DateTimeField(auto_now_add=True)
    modified_at = models.DateTimeField(auto_now=True)
    
    objects = PatientManager()
    
    def __str__(self):
        return f"{self.patient_id}--{self.name}"

class AdmissionRecord(models.Model):
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE, related_name='visits')
    height = models.IntegerField(null=True, blank=False)
    weight = models.IntegerField(null=True, blank=False)
    ibw = models.DecimalField(decimal_places=2, max_digits= 5, null=True, blank=False, default=None)
    bmi = models.DecimalField(decimal_places=2, max_digits= 5, null=True, blank=False, default=None)   
    admission_date = models.DateTimeField (blank=True, null=True, default=None)
    reason_for_admission = models.CharField(blank=True, null=True, default=None)
    reason_for_ventilation = models.CharField(blank=True, null=True, default=None)
    history_of_diabetes = models.BooleanField(default=False)
    tags = models.CharField(blank=True, null=True, default=None)
    history_of_bp = models.BooleanField(default=False)
    current_status = models.CharField(blank=True, default="")
    is_discharged = models.BooleanField(default=False)
    discharge_date = models.DateTimeField(blank=True, null=True, default=None)
    created_at = models.DateTimeField(auto_now_add=True)
    modified_at = models.DateTimeField(auto_now=True)   

class ClinicalAdvice(models.Model):
    record = models.ForeignKey(AdmissionRecord, on_delete=models.CASCADE, related_name='clinical_advices')
    content = models.CharField()
    added_by = models.CharField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.id}-{self.record.patient.patient_id}-{self.content} at {self.created_at}"
    
class ABGReport(models.Model):
    record = models.ForeignKey(AdmissionRecord, on_delete=models.CASCADE, related_name='abg_reports')
    created_at = models.DateTimeField(auto_now_add=True)
    pH = models.FloatField()
    pCO2 = models.FloatField()
    pO2 = models.FloatField()
    hCO3 = models.FloatField()
    base_excess = models.FloatField()
    sO2 = models.FloatField()
    lactate = models.FloatField(default=0.0)
    comments = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"ABG Report {self.id} - {self.created_at}"

    class Meta:
        ordering = ['-created_at']