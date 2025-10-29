from django.contrib import admin

from .models import Patient, AdmissionRecord, ClinicalAdvice, ABGReport

class PatientAdmin(admin.ModelAdmin):
    list_display = ('patient_id', 'name', 'age', 'gender', 'active',)
    fieldsets = (
        ('Personal Details', {'fields': ('patient_id', 'name', 'age', 'gender', 'blood_group', 'contact',)}),
        ('Status', {'fields': ('active',)}),
        ('Identity', {'fields': ('aadhar', 'abha',)}),
    )
    readonly_fields = ('patient_id', 'name', 'age', 'gender', 'blood_group', 'contact', 'active', 'aadhar', 'abha',)
    search_fields = ('patient_id',)
    ordering = ('patient_id',)
    filter_horizontal = ()

admin.site.register(Patient, PatientAdmin)
admin.site.register(AdmissionRecord)
admin.site.register(ClinicalAdvice)
admin.site.register(ABGReport)