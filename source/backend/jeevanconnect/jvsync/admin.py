from django.contrib import admin

from .models import VentilationSession, SessionLog

admin.site.register(VentilationSession)
admin.site.register(SessionLog)
